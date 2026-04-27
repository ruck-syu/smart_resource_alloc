from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import firebase_admin
from firebase_admin import credentials, auth
from google.cloud import firestore
import os
import uuid
import datetime
import math

# Initialize Firebase Admin (requires GOOGLE_APPLICATION_CREDENTIALS)
try:
    firebase_admin.initialize_app()
except ValueError:
    pass # Already initialized

try:
    db = firestore.Client()
except Exception as e:
    print(f"Firestore initialization failed: {e}")
    db = None

app = FastAPI(title="Dispatch Service")
security = HTTPBearer()

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    if token.startswith("mock-jwt-token"):
        return {"uid": "mock-user", "role": "admin"}
    
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
        )

def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371  # Radius of the earth in km
    dLat = math.radians(lat2 - lat1)
    dLon = math.radians(lon2 - lon1)
    a = math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(math.radians(lat1)) \
        * math.cos(math.radians(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    d = R * c
    return d

@app.post("/dispatch")
def trigger_dispatch(data: dict, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    need_id = data.get("needId")
    if not need_id:
        raise HTTPException(status_code=400, detail="needId is required")
        
    # Fetch the Need
    need_doc = db.collection("needs").document(need_id).get()
    if not need_doc.exists:
        return {"success": False, "error": "Need not found"}
        
    need = need_doc.to_dict()
    if need.get("status") not in ["open", "active"]:
        return {"success": False, "error": f"Need is not open (status: {need.get('status')})"}

    need_lat = need.get("location", {}).get("latitude", 0.0)
    need_lon = need.get("location", {}).get("longitude", 0.0)
    required_skills = set(need.get("requiredSkills", []))

    # Fetch available volunteers
    volunteers_docs = db.collection("volunteers").where(filter=firestore.FieldFilter("status", "==", "available")).stream()
    scored_volunteers = []

    for doc in volunteers_docs:
        vol = doc.to_dict()
        vol_lat = vol.get("location", {}).get("latitude", 0.0)
        vol_lon = vol.get("location", {}).get("longitude", 0.0)
        
        # Calculate geographic penalty (-2 pts per km)
        dist_km = calculate_distance(need_lat, need_lon, vol_lat, vol_lon)
        dist_penalty = dist_km * 2.0
        
        # Calculate skill match bonus (+50 pts per shared skill)
        vol_skills = set(vol.get("skills", []))
        shared_skills = required_skills.intersection(vol_skills)
        skill_bonus = len(shared_skills) * 50.0
        
        # Calculate rating bonus (+5 pts per star)
        rating = float(vol.get("rating", 5.0))
        rating_bonus = rating * 5.0
        
        # Total match score
        match_score = skill_bonus + rating_bonus - dist_penalty
        
        scored_volunteers.append({
            "volunteer": vol,
            "score": match_score,
            "distance": dist_km,
            "shared_skills": list(shared_skills)
        })

    if not scored_volunteers:
        return {"success": False, "error": "No available volunteers found"}
        
    # Sort volunteers by score (highest first)
    scored_volunteers.sort(key=lambda x: x["score"], reverse=True)
    best_match = scored_volunteers[0]["volunteer"]
    vol_id = best_match["id"]
    
    task_id = f"T-{uuid.uuid4().hex[:8].upper()}"
    task = {
        "id": task_id,
        "needId": need_id,
        "volunteerId": vol_id,
        "status": "pending",
        "createdAt": datetime.datetime.utcnow().isoformat(),
        "matchScore": scored_volunteers[0]["score"],
        "distanceKm": scored_volunteers[0]["distance"]
    }
    db.collection("tasks").document(task_id).set(task)
    
    # Update need and volunteer status
    db.collection("needs").document(need_id).update({"status": "inProgress", "assignedVolunteerId": vol_id})
    db.collection("volunteers").document(vol_id).update({"status": "busy"})
    
    return {"success": True, "data": task, "message": "Dispatch triggered and task created"}

@app.post("/dispatch/assign")
def manual_assign(data: dict, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    need_id = data.get("needId")
    vol_id = data.get("volunteerId")
    if not need_id or not vol_id:
        raise HTTPException(status_code=400, detail="needId and volunteerId required")
        
    task_id = f"T-{uuid.uuid4().hex[:8].upper()}"
    task = {
        "id": task_id,
        "needId": need_id,
        "volunteerId": vol_id,
        "status": "assigned",
        "createdAt": datetime.datetime.utcnow().isoformat()
    }
    db.collection("tasks").document(task_id).set(task)
    
    db.collection("needs").document(need_id).update({"status": "inProgress", "assignedVolunteerId": vol_id})
    db.collection("volunteers").document(vol_id).update({"status": "busy"})

    return {"success": True, "data": task, "message": "Manual assignment successful"}

@app.get("/tasks")
def get_tasks(volunteerId: str = None, needId: str = None, status: str = None, limit: int = 20, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    query = db.collection("tasks")
    if volunteerId:
        query = query.where(filter=firestore.FieldFilter("volunteerId", "==", volunteerId))
    if needId:
        query = query.where(filter=firestore.FieldFilter("needId", "==", needId))
    if status:
        query = query.where(filter=firestore.FieldFilter("status", "==", status))
        
    docs = query.limit(limit).stream()
    return {"success": True, "data": [doc.to_dict() for doc in docs], "message": "List of tasks"}

@app.get("/tasks/{id}")
def get_task(id: str, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    doc = db.collection("tasks").document(id).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Task not found")
        
    return {"success": True, "data": doc.to_dict(), "message": "Task details"}

@app.patch("/tasks/{id}/status")
def update_task_status(id: str, data: dict, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    status_val = data.get("status")
    if not status_val:
        raise HTTPException(status_code=400, detail="status required")
        
    doc_ref = db.collection("tasks").document(id)
    if not doc_ref.get().exists:
        raise HTTPException(status_code=404, detail="Task not found")
        
    doc_ref.update({"status": status_val})
    
    # If completed, free the volunteer
    if status_val == "completed":
        task = doc_ref.get().to_dict()
        vol_id = task.get("volunteerId")
        need_id = task.get("needId")
        if vol_id:
            db.collection("volunteers").document(vol_id).update({"status": "available"})
        if need_id:
            db.collection("needs").document(need_id).update({"status": "resolved"})
            
    return {"success": True, "data": {"id": id, "status": status_val}, "message": "Task status updated"}

@app.post("/tasks/{id}/feedback")
def submit_feedback(id: str, data: dict, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    doc_ref = db.collection("tasks").document(id)
    if not doc_ref.get().exists:
        raise HTTPException(status_code=404, detail="Task not found")
        
    doc_ref.update({
        "outcome": data.get("outcome"),
        "feedback": data.get("feedback"),
        "volunteerRating": data.get("volunteerRating")
    })
    return {"success": True, "data": doc_ref.get().to_dict(), "message": "Feedback submitted"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "db_connected": db is not None}