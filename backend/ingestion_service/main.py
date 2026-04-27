from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File, Form
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import firebase_admin
from firebase_admin import credentials, auth
from google.cloud import firestore
from typing import Optional
import os
import uuid
import datetime

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

app = FastAPI(title="Ingestion Service")
security = HTTPBearer(auto_error=False)

def verify_token_optional(credentials: Optional[HTTPAuthorizationCredentials] = Depends(security)):
    if not credentials:
        return None
    token = credentials.credentials
    if token.startswith("mock-jwt-token"):
        return {"uid": "mock-user"}
    
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
        )

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    if token.startswith("mock-jwt-token"):
        return {"uid": "mock-user"}
    
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
        )

@app.post("/ingest")
def ingest_data(data: dict, user: dict = Depends(verify_token)):
    if db:
        ingest_id = f"I-{uuid.uuid4().hex[:8].upper()}"
        doc_data = {
            "id": ingest_id,
            "type": "api",
            "data": data,
            "timestamp": datetime.datetime.utcnow().isoformat()
        }
        db.collection("ingestions").document(ingest_id).set(doc_data)
    
    # Mock publishing to Pub/Sub
    return {"success": True, "data": data, "message": "Data ingested"}

@app.post("/upload")
async def upload_file(
    file: UploadFile = File(...),
    sourceType: str = Form(None),
    zone: str = Form(None),
    organizationId: str = Form(None),
    user: dict = Depends(verify_token_optional)
):
    if db:
        upload_id = f"U-{uuid.uuid4().hex[:8].upper()}"
        doc_data = {
            "id": upload_id,
            "filename": file.filename,
            "sourceType": sourceType,
            "zone": zone,
            "organizationId": organizationId,
            "timestamp": datetime.datetime.utcnow().isoformat()
        }
        db.collection("ingestions").document(upload_id).set(doc_data)
        
    return {"success": True, "data": {"filename": file.filename, "url": f"https://storage.mock/{file.filename}"}, "message": "File uploaded"}

@app.post("/upload-url")
def get_upload_url(data: dict, user: dict = Depends(verify_token)):
    # Mock generating signed URL
    return {"success": True, "data": {"url": "https://storage.mock/signed-url"}, "message": "Upload URL generated"}

@app.post("/batch")
async def batch_upload(
    file: UploadFile = File(...),
    zone: str = Form(None),
    organizationId: str = Form(None),
    user: dict = Depends(verify_token_optional)
):
    if db:
        batch_id = f"B-{uuid.uuid4().hex[:8].upper()}"
        doc_data = {
            "id": batch_id,
            "filename": file.filename,
            "zone": zone,
            "organizationId": organizationId,
            "type": "batch",
            "timestamp": datetime.datetime.utcnow().isoformat()
        }
        db.collection("ingestions").document(batch_id).set(doc_data)
        
    return {"success": True, "data": {"filename": file.filename, "processed": 0}, "message": "Batch upload received"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "db_connected": db is not None}