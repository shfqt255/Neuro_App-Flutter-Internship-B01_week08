# Advanced Firebase & Real-time Flutter Apps

This repository contains four Flutter projects demonstrating advanced Firebase features, including **real-time chat**, **push notifications**, **Firestore queries with pagination**, and a **social user profile system**.

## Projects

### 1. Chat App – Real-time Messaging
A one-to-one chat application using Firestore for real-time messaging.

**Features:**
- Send and receive messages in real-time
- Typing indicators and online/offline status
- Message bubbles for sender and receiver
- Auto-scroll to latest message
- Timestamp formatting using `intl` package

### 2. Notifications App – Firebase Cloud Messaging
Demonstrates push notifications using Firebase Cloud Messaging.

**Features:**
- Foreground, background, and notification tap handling
- FCM token generation and storage
- Local notifications using `flutter_local_notifications`
- Notification badges and payload handling

### 3. Posts App – Firestore Queries & Pagination
Demonstrates advanced Firestore queries and infinite scrolling.

**Features:**
- Filter posts by category
- Sort posts by date or popularity
- Search posts by title
- Pagination using `limit()` and `startAfterDocument()`
- Infinite scroll with loading indicators

### 4. Social Profile App – User Profiles & Relationships
A social-style user profile system built with Firestore.

**Features:**
- User profile creation and update with image upload
- Followers and following system
- Follow/unfollow functionality
- Display user's posts in a grid layout
- Atomic operations using Firestore transactions

## Firebase Services Used
- Cloud Firestore
- Firebase Cloud Messaging (FCM)
- Firebase Storage
- Firebase Authentication (optional)

## Getting Started
1. Clone the repository:
   ```bash
   git clone <https://github.com/shfqt255/Neuro_App-Flutter-Internship-B01_week08.git>

2. Install dependencies:
```flutter pub get

3. Configure Firebase for each project following the official FlutterFire setup guide: https://firebase.flutter.dev/docs/overview

4. Run the app:
```flutter run