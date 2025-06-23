# sync_together

# SyncTogether

SyncTogether is a cross-platform watch party app that allows users to watch their favorite shows and
movies in perfect sync with friends, no matter where they are. It supports **Android, iOS, and Web
**, and provides seamless room creation, real-time playback synchronization, in-room chat, and live
voice/video communication.

## 🚀 Features

### ✅ **MVP Features**

#### **User Authentication**

- [x] Email & Password Sign-up/Login
- [x] Anonymous Sign-In
- [ ] Google Sign-In (not yet implemented)

#### **Room Management**

- [x] Create and join watch party rooms with unique codes
- [x] Private room logic
- [x] Host can end the room manually or by leaving

#### **Playback Synchronization**

- [x] Real-time play, pause, and seek across devices
- [x] Firestore Realtime Sync (position + isPlaying)
- [x] Host auto-sync loop every 3 seconds
- [x] Guest sync and resync logic (JavaScript in WebView)

#### **In-Room Chat**

- [x] Text chat in real time
- [ ] Voice chat (not yet implemented)
- [ ] Video chat (not yet implemented)

#### **Cross-Platform Support**

- [x] Works on Android and iOS (fully tested)
- [ ] Web support in progress (YouTube only; no overlay)

### **Future Enhancements (Post-MVP)**

✅ **Google Sign-In**
✅ **Host permissions (kick users, change video)**
✅ **WebRTC-based low-latency playback sync**  
✅ **Smart TV support (Android TV, Apple TV, Fire TV)**  
✅ **Streaming platform integration (Netflix, YouTube, etc.)**  
✅ **Reactions and emoji-based interactions**  
✅ **Screen sharing for local videos**  
✅ **Advanced moderation & user management tools**

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Authentication, Firestore, Realtime Database)
- **State Management:** BLoC
- **Real-time Sync:** Firestore Realtime Updates (Future: WebRTC)
- **Authentication:** Firebase Auth (Email, Google, Anonymous)
- **Chat:** Firestore-backed messaging

## 🔧 Setup Guide

### **1. Clone the Repository**

```sh
git clone https://github.com/tsounguc/sync_together.git
cd sync_together
```

### **2. Install Dependencies**

```sh
flutter pub get
```

### **3. Configure Firebase**

- Go to [Firebase Console](https://console.firebase.google.com/)
- Create a project and enable Authentication (Email, Google, Anonymous Sign-In)
- Enable Firestore for real-time room management
- Enable Firebase Realtime Database for playback sync
- Download `google-services.json` (Android) & `GoogleService-Info.plist` (iOS) and place them in
  `android/app/` and `ios/Runner/` respectively

### **4. Run the App**

```sh
flutter run
```

## 📂 Project Structure

```
sync_together/
├── core/
│   ├── errors/
│   ├── network/
│   ├── usecases/
│   ├── utils/
│   ├── websocket/        # WebSocket-based signaling (for WebRTC)
│   ├── webrtc/           # Handles video & voice communication
│   ├── notifications/
│   └── deep_linking/
│
├── features/
│   ├── auth/             # Authentication (Email, Google, Anonymous)
│   ├── rooms/            # Room creation, joining, and management
│   ├── video_sync/       # Firestore-based video playback sync
│   ├── chat/             # Handles text, voice, and video chat
│   │   ├── data/
│   │   │   ├── data_sources/
│   │   │   ├── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   ├── usecases/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   ├── widgets/
│   │
│   ├── notifications/
│   ├── profiles/
│   └── settings/
│
└── main.dart
```

## 🏗️ Architecture Overview

SyncTogether follows **Clean Architecture** and **Test-Driven Development (TDD):**

- **Core Layer:** Shared utilities, networking, error handling, WebRTC/WebSockets, notifications,
  and deep linking.
- **Feature Layer:**
    - **Auth:** Manages user authentication and session persistence.
    - **Rooms:** Handles room creation, joining, and management.
    - **Video Sync:** Ensures real-time playback synchronization.
    - **Chat:** Provides in-room text, voice, and video communication.
    - **Notifications:** Handles push and local notifications.
    - **Profiles:** Manages user profiles and settings.
    - **Settings:** Manages app preferences.
- **Data Layer:** Handles Firebase interactions (Auth, Firestore, Realtime updates).
- **Domain Layer:** Manages business logic and app state.
- **Presentation Layer:** UI components (Screens, Widgets).

[//]: # (## 📜 License)

[//]: # (This project is licensed under the MIT License.)

[//]: # (## 🤝 Contributing)

[//]: # (Contributions are welcome! Open an issue or create a pull request.)

---

### 🔥 **Next Steps**

- [ ] Implement Firebase-backed room management
- [ ] Integrate WebRTC-based voice and video chat
- [ ] Improve UI with sleek design
- [ ] Explore WebRTC for low-latency playback sync

