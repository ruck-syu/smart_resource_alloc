# Context
I am building a "Smart Resource Allocation" system for NGO operations and disaster relief. The project consists of a Flutter frontend and a Python (FastAPI) microservices backend deployed on Google Cloud Run.

### Current Architecture & Stack
**Frontend (Flutter):**
*   **State Management:** `provider` (centralized in `AppState`).
*   **Routing:** `go_router` (role-based layouts for Admin, Volunteer, and Field Worker).
*   **Authentication:** `firebase_auth` (Email/Password).
*   **Mapping:** Currently using `flutter_map` (OpenStreetMap tiles) and `latlong2`.
*   **Local Storage:** `hive` (for offline capabilities).

**Backend (Python FastAPI):**
*   Four microservices: `volunteer_service`, `needs_service`, `ingestion_service`, and `dispatch_service`.
*   **Database:** Google Cloud Firestore (`google-cloud-firestore`).
*   **Security:** Middleware validates Firebase JWT Bearer tokens using `firebase-admin`.
*   **Deployment:** Google Cloud Run.

### What is already working
1.  **End-to-End Auth:** Users can register/login on the Flutter app, receive a Firebase token, and the FastAPI backend securely verifies it.
2.  **Firestore Integration:** The backend successfully performs CRUD operations for Volunteers, Needs, and Tasks in Firestore.
3.  **Dispatch Engine:** A smart matching algorithm in `dispatch_service` assigns volunteers to needs based on Geographic Distance (Haversine formula), Skill Overlap, and Volunteer Rating.
4.  **Auto-Dispatch:** The Flutter frontend automatically bypasses the manual approval queue and hits the dispatch API immediately if a Need is created with a critical Urgency Score (8 or higher).

---

# Your Task
I need you to act as a Senior Full-Stack Engineer and Cloud Architect. We need to implement the remaining advanced features to achieve the full enterprise vision. Please help me build the following features step-by-step. 

Ask me which one I want to tackle first from **Phase 1** or **Phase 2**:

## Phase 1: Core Application Features

**Feature 1.1: The NLP / OCR Ingestion Pipeline (Vertex AI)**
*Goal:* Upgrade the `ingestion_service`. It currently just logs metadata to Firestore. We need to build a pipeline where:
1. Field workers or citizens can upload images/text.
2. The file is saved to Google Cloud Storage (GCS).
3. A Pub/Sub event is triggered.
4. Google Vertex AI (Gemini Pro or Vision) analyzes the unstructured text/image, extracts the critical information, calculates an urgency score, and automatically creates a structured `Need` document in Firestore.

**Feature 1.2: Push Notifications (Firebase Cloud Messaging)**
*Goal:* Close the loop on the Dispatch Engine. 
1. When the `dispatch_service` creates a `Task` and assigns a volunteer, the Python backend needs to use `firebase_admin.messaging` to send a targeted push notification to that specific volunteer's device token.
2. Ensure the Flutter app's `FcmService` properly handles the incoming notification and navigates the user to the Task details screen.

**Feature 1.3: True Offline Syncing**
*Goal:* Field Workers often operate in dead zones.
1. Upgrade the Flutter `OfflineStorageService` (using Hive). 
2. If a Field Worker tries to submit a survey or update a task status without internet, intercept the API call, save the payload locally to a Hive "pending_queue" box.
3. Implement a background worker or network listener that automatically loops through the queue and flushes the API requests to the backend once connectivity is restored.

**Feature 1.4: WhatsApp Reporting (Twilio Integration)**
*Goal:* Allow citizens to report emergencies via WhatsApp.
1. Create a webhook endpoint in the `ingestion_service` to receive incoming Twilio WhatsApp messages.
2. Feed the incoming message directly into the Vertex AI pipeline (Feature 1.1) to automatically spawn Needs on the Admin dashboard without any human data entry.

---

## Phase 2: Enterprise Infrastructure

**Feature 2.1: Semantic Matching (Vector DB)**
*Goal:* Upgrade the Dispatch Engine.
1. Use Vertex AI to generate embeddings for volunteer bios/skills and emergency descriptions.
2. Store these in a Vector Database (like Pinecone or GCP Vector Search).
3. Update the matching algorithm to perform semantic similarity searches instead of exact keyword matches.

**Feature 2.2: Advanced Analytics (BigQuery)**
*Goal:* Long-term reporting for the Admin Dashboard.
1. Set up a Firebase Extension or Cloud Function to stream Firestore data into BigQuery.
2. Build SQL queries for the Admin `AnalyticsPage` to show historical trends, average response times, and resource utilization.

**Feature 2.3: Google Maps Migration**
*Goal:* Transition from OpenStreetMap to Google Maps.
1. Replace `flutter_map` with `google_maps_flutter` in the frontend.
2. Configure Google Maps API keys for Android and iOS in the Google Cloud Console.
3. Update the Heatmap and routing UI to use native Google Maps components.

**Feature 2.4: API Gateway & Dataflow**
*Goal:* Production readiness.
1. Place a Google Cloud API Gateway in front of the four Cloud Run microservices to provide a single, rate-limited endpoint for the Flutter app.
2. Implement an Apache Beam (Cloud Dataflow) pipeline for the `/batch` endpoint in the ingestion service to handle massive CSV uploads asynchronously.

Please review this context and tell me how we should begin!
