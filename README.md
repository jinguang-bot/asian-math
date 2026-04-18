# Asiamath V4.0 - Distributed Development Guide

Welcome to the **Asiamath** repository! 

This project has been explicitly designed and refactored for **Distributed (Concurrent) Development**. Multiple engineers or AI Agents can work on this repository simultaneously without ever running into a git merge conflict.

## 🏗️ Architecture & Zero-Conflict Routing

We have adopted an auto-discovery routing architecture for both Frontend and Backend to ensure you do not need to modify shared configuration files.

### 🌐 Frontend (`/frontend`)
- **Tech Stack:** React + Vite + TypeScript
- **Zero-Conflict Routing:** You **do not** need to edit `App.tsx` or any central router file.
- **How to add a new page:**
  Simply create a new `.tsx` file inside `frontend/src/pages/`.
  For example, creating `frontend/src/pages/Profile.tsx` will automatically register the route `http://localhost:5173/profile`.
- **To Start:** `cd frontend && npm install && npm run dev`

### ⚙️ Backend (`/backend`)
- **Tech Stack:** Node.js + Express + Prisma (SQLite) + Jest
- **Zero-Conflict Routing:** You **do not** need to edit `app.ts` to register your new controllers.
- **How to add a new API endpoint:**
  Simply create a new `.ts` file inside `backend/src/routes/`.
  For example, creating `backend/src/routes/profile.ts` will automatically mount all your routes under `http://localhost:3000/api/v1/profile`.
- **To Start:** `cd backend && npm install && npm run dev`

## 🛠️ The Development Workflow (Shift Work)

We follow the **Four-layer staggered parallel development** model. When claiming a task from the JSON planner (`docs/planning/asiamath-feature-list-v4.0-optimized.json`), please adhere to the following workflow:

1. **Verify (Smoke Test):** 
   Always run `npm run test:smoke` at the root of the project *before* and *after* your changes. This ensures the codebase is in a Clean State.
2. **Implement:** 
   Write your code within your isolated files (`frontend/src/pages/YourFeature.tsx` or `backend/src/routes/yourfeature.ts`).
3. **Test:** 
   Write Jest tests in `backend/tests/` for your backend features.
4. **Handoff:** 
   Update your feature's status in `asiamath-feature-list-v4.0-optimized.json` to `"status": "completed"` and `"passes": true`. Finally, append your session summary to `PROGRESS.md`.

## 📂 Key Directories

*   `docs/planning/` - The source of truth for all pending and completed Features.
*   `docs/specs/` - The source of truth for the OpenAPI Swagger contract. **(Always read this before coding an API)**
*   `frontend/` - React SPA codebase.
*   `backend/` - Node.js Express API codebase.
*   `backend/prisma/schema.prisma` - Database schema definitions.

Happy coding! If you follow the isolated file structure, you will never see a merge conflict.