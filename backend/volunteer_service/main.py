from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import firebase_admin
from firebase_admin import credentials, auth
from google.cloud import firestore
import os
import uuid

# Initialize Firebase Admin (requires GOOGLE_APPLICATION_CREDENTIALS)
try:
    firebase_admin.initialize_app()
except ValueError:
    pass # Already initialized

# Initialize Firestore client
try:
    db = firestore.Client()
except Exception as e:
    print(f"Firestore initialization failed: {e}")
    db = None

app = FastAPI(title="Volunteer Service")
security = HTTPBearer()

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    # Mock validation for development without a real project:
    if token.startswith("mock-jwt-token"):
        return {"uid": "mock-user", "role": "volunteer"}
    
    # Real validation:
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
        )

@app.post("/volunteers")
def register_volunteer(data: dict, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
    
    vol_id = data.get("id") or f"V-{uuid.uuid4().hex[:8].upper()}"
    data["id"] = vol_id
    
    db.collection("volunteers").document(vol_id).set(data)
    return {"success": True, "data": data, "message": "Volunteer registered"}

@app.get("/volunteers")
def get_volunteers(status: str = None, skill: str = None, page: int = 1, limit: int = 20, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
    
    query = db.collection("volunteers")
    if status:
        query = query.where(filter=firestore.FieldFilter("status", "==", status))
    # Skill filtering in array requires specific query or client-side filtering if complex
    
    docs = query.limit(limit).stream()
    vols = [doc.to_dict() for doc in docs]
    
    # Basic skill filter in memory for now if provided
    if skill:
        vols = [v for v in vols if skill in v.get("skills", [])]
        
    return {"success": True, "data": vols, "message": "List of volunteers"}

@app.get("/volunteers/{id}")
def get_volunteer(id: str, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
    
    doc = db.collection("volunteers").document(id).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Volunteer not found")
        
    return {"success": True, "data": doc.to_dict(), "message": "Volunteer details"}

@app.put("/volunteers/{id}")
def update_volunteer(id: str, data: dict, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    doc_ref = db.collection("volunteers").document(id)
    if not doc_ref.get().exists:
        raise HTTPException(status_code=404, detail="Volunteer not found")
        
    doc_ref.update(data)
    # Fetch updated data
    updated_data = doc_ref.get().to_dict()
    return {"success": True, "data": updated_data, "message": "Volunteer updated"}

@app.patch("/volunteers/{id}/status")
def toggle_volunteer_status(id: str, data: dict, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    new_status = data.get("status")
    if not new_status:
        raise HTTPException(status_code=400, detail="Status is required")
        
    doc_ref = db.collection("volunteers").document(id)
    if not doc_ref.get().exists:
        raise HTTPException(status_code=404, detail="Volunteer not found")
        
    doc_ref.update({"status": new_status})
    return {"success": True, "data": {"id": id, "status": new_status}, "message": "Status updated"}

@app.get("/volunteers/search/nearby")
def get_nearby_volunteers(lat: float, lng: float, radius: float = 10, skill: str = None, user: dict = Depends(verify_token)):
    # Phase 1: Simple fetch and mock nearby logic
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    docs = db.collection("volunteers").where(filter=firestore.FieldFilter("status", "==", "available")).stream()
    vols = [doc.to_dict() for doc in docs]
    
    if skill:
        vols = [v for v in vols if skill in v.get("skills", [])]
        
    return {"success": True, "data": vols, "message": "Nearby volunteers"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "db_connected": db is not None}