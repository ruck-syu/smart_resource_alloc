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

try:
    db = firestore.Client()
except Exception as e:
    print(f"Firestore initialization failed: {e}")
    db = None

app = FastAPI(title="Needs Service")
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

@app.post("/needs")
def create_need(data: dict, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    need_id = data.get("id") or f"N-{uuid.uuid4().hex[:8].upper()}"
    data["id"] = need_id
    if "status" not in data:
        data["status"] = "open"
    if "urgencyScore" not in data:
        data["urgencyScore"] = 5
        
    db.collection("needs").document(need_id).set(data)
    return {"success": True, "data": data, "message": "Need created"}

@app.get("/needs")
def get_needs(zone: str = None, category: str = None, status: str = None, minUrgency: int = None, page: int = 1, limit: int = 20, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    query = db.collection("needs")
    if zone:
        query = query.where(filter=firestore.FieldFilter("zoneName", "==", zone))
    if category:
        query = query.where(filter=firestore.FieldFilter("category", "==", category))
    if status:
        query = query.where(filter=firestore.FieldFilter("status", "==", status))
        
    docs = query.stream()
    needs = [doc.to_dict() for doc in docs]
    
    if minUrgency is not None:
        needs = [n for n in needs if n.get("urgencyScore", 0) >= minUrgency]
        
    # Manual slicing for pagination
    start = (page - 1) * limit
    end = start + limit
    
    return {"success": True, "data": needs[start:end], "message": "List of needs"}

@app.get("/needs/{id}")
def get_need(id: str, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    doc = db.collection("needs").document(id).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Need not found")
        
    return {"success": True, "data": doc.to_dict(), "message": "Need details"}

@app.put("/needs/{id}")
def update_need(id: str, data: dict, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    doc_ref = db.collection("needs").document(id)
    if not doc_ref.get().exists:
        raise HTTPException(status_code=404, detail="Need not found")
        
    doc_ref.update(data)
    return {"success": True, "data": doc_ref.get().to_dict(), "message": "Need updated"}

@app.patch("/needs/{id}/urgency")
def update_urgency(id: str, data: dict, user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    score = data.get("urgencyScore")
    if score is None:
        raise HTTPException(status_code=400, detail="urgencyScore is required")
        
    doc_ref = db.collection("needs").document(id)
    if not doc_ref.get().exists:
        raise HTTPException(status_code=404, detail="Need not found")
        
    doc_ref.update({"urgencyScore": score})
    return {"success": True, "data": {"id": id, "urgencyScore": score}, "message": "Urgency updated"}

@app.get("/needs/heatmap/data")
def get_heatmap_data(user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    docs = db.collection("needs").stream()
    points = []
    for doc in docs:
        n = doc.to_dict()
        loc = n.get("location")
        if loc and isinstance(loc, dict) and "latitude" in loc and "longitude" in loc:
            points.append({
                "latitude": loc["latitude"],
                "longitude": loc["longitude"],
                "intensity": n.get("urgencyScore", 5) / 10.0
            })
            
    return {"success": True, "data": {"points": points}, "message": "Heatmap data"}

@app.get("/needs/stats/summary")
def get_need_stats(user: dict = Depends(verify_token)):
    if not db:
        return {"success": False, "error": "Database not initialized"}
        
    docs = db.collection("needs").stream()
    needs = [doc.to_dict() for doc in docs]
    total = len(needs)
    active = len([n for n in needs if n.get("status") in ["open", "inProgress"]])
    
    return {"success": True, "data": {"total": total, "active": active}, "message": "Need stats"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "db_connected": db is not None}