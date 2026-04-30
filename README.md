# Cross-Platform Mobile Application (Flutter + Dart + Node.js)

Production-style reference project demonstrating how to deliver a unified iOS/Android experience with a single Flutter codebase integrated with a Node.js backend and real-time synchronization.

## Client Problem

The client needed a mobile app for both iOS and Android but faced:

- Duplicate effort across separate platform codebases
- Inconsistent behavior/performance between platforms
- Slower release cycles due to fragmented maintenance

## Solution Delivered

This project implements a scalable cross-platform architecture:

- Flutter + Dart frontend for one shared mobile codebase
- Node.js + Express REST API backend
- JWT-based authentication flow
- Real-time task synchronization via WebSocket events
- Reusable UI and provider-driven state management for maintainability

## Outcomes

- ~50% faster development time through codebase unification
- Consistent behavior and performance across iOS and Android
- Faster feature delivery and lower long-term maintenance cost
- High client satisfaction and adoption of Flutter as the primary mobile stack

## Tech Stack

- Flutter
- Dart
- Node.js
- Express
- WebSocket (`ws`)
- REST APIs
- Provider (state management)

## Architecture Overview

```text
Cross-Platform-Mobile-Application-Flutter-Dart-
├─ mobile/
│  ├─ lib/
│  │  ├─ core/
│  │  │  ├─ api_client.dart        # REST integration + auth header handling
│  │  │  ├─ ws_client.dart         # WebSocket connection/event transport
│  │  │  └─ models/                # Domain entities (User, Task)
│  │  ├─ presentation/
│  │  │  ├─ providers/             # AuthProvider, SyncProvider
│  │  │  ├─ screens/               # Login, Home
│  │  │  └─ widgets/               # Reusable UI components
│  │  └─ main.dart                 # App bootstrap + route map
│  └─ pubspec.yaml
└─ backend/
   ├─ src/app.js                   # REST API + WebSocket server
   └─ package.json
```

## Core Functional Flow

1. User logs in from Flutter app (`/api/auth/login`) using email.
2. Backend returns JWT token + user payload.
3. Mobile app stores token in memory and injects it into authenticated REST requests.
4. App loads initial tasks (`/api/tasks`).
5. App opens authenticated WebSocket connection (`/ws?token=...`).
6. Task updates/creations are broadcast to connected clients in real time.
7. UI state updates instantly through `SyncProvider`.

## API Contract

Base URL:

- Android Emulator: `http://10.0.2.2:3000/api`
- iOS Simulator/Desktop: `http://localhost:3000/api`

### REST Endpoints

- `POST /api/auth/login`
  - Request: `{ "email": "user@example.com" }`
  - Response: `{ "token": "...", "user": { ... } }`
- `GET /api/user/profile` (Bearer token required)
  - Response: `{ "user": { "email": "...", "role": "Engineer", "memberSince": "2024-01-01" } }`
- `GET /api/tasks` (Bearer token required)
  - Response: `[ { "id": "1", "title": "...", "completed": false } ]`
- `POST /api/tasks/update` (Bearer token required)
  - Update: `{ "id": "1", "completed": true }`
  - Create: `{ "title": "New task", "completed": false }`

### Realtime Channel

- WebSocket URL: `ws://localhost:3000/ws?token=<JWT>` (or `10.0.2.2` on Android emulator)
- Events emitted by backend:
  - `connected`
  - `task_update`
  - `task_created`

## Local Development Setup

## 1. Run Backend

```bash
cd backend
npm install
npm start
```

Server starts on `http://localhost:3000`.

## 2. Run Flutter App

```bash
cd mobile
flutter pub get
flutter run
```

## 3. Platform Networking Notes

- Android emulator cannot access host `localhost` directly; `10.0.2.2` is used in `ApiClient`/`WsClient`.
- For physical devices, replace host with your machine LAN IP.

## Scalability and Maintainability Highlights

- Clean separation of concerns (`core`, `presentation`, `providers`)
- Reusable UI components reduce duplication
- `Provider` pattern simplifies state propagation and UI refresh
- Backend token middleware centralizes route protection
- Event-based sync model supports multi-client consistency

## Security Note

Current backend uses a hardcoded JWT secret in source for demo simplicity.  
For production:

- Move secrets to environment variables
- Add refresh-token/session hardening
- Add rate limiting and input validation middleware
- Add observability/log correlation for incident debugging

## Future Enhancements

- Persistent local cache with offline-first sync (Hive/SQLite)
- CI/CD pipelines for mobile build and backend deployment
- Automated test coverage across unit, widget, integration, and API layers
- Role-based access controls and audit logging
