# 📱 Posts App - Complete Setup Guide

## What This App Does
- ✅ Loads posts from Firestore with **pagination** (5 posts at a time)
- ✅ **Infinite scroll** - automatically loads more as you scroll down
- ✅ **Filter** posts by category (Flutter, Firebase, Dart)
- ✅ **Search** posts by title (prefix search)
- ✅ **Sort** by newest first OR most liked
- ✅ **Loading indicators** while fetching data

---

## Step-by-Step Setup

### Step 1: Create a Flutter Project
```bash
flutter create posts_app
cd posts_app
```

### Step 2: Replace Files
Copy ALL files from this package into your project:
```
posts_app/
├── lib/
│   ├── main.dart               ← Replace existing
│   ├── models/
│   │   └── post_model.dart     ← Create this folder + file
│   ├── services/
│   │   └── firestore_service.dart ← Create this folder + file
│   ├── screens/
│   │   └── home_screen.dart    ← Create this folder + file
│   └── widgets/
│       └── post_card.dart      ← Create this folder + file
├── pubspec.yaml                ← Replace existing
└── firestore.rules             ← Use in Firebase Console
```

### Step 3: Create a Firebase Project
1. Go to **https://console.firebase.google.com**
2. Click **"Add project"**
3. Name it `posts-app` → Continue → Create project

### Step 4: Enable Firestore
1. In Firebase Console → Click **"Firestore Database"**
2. Click **"Create database"**
3. Select **"Start in test mode"** (for development)
4. Choose a location → Done

### Step 5: Add Firebase to Flutter

#### For Android:
1. In Firebase Console → Click the **Android icon** (⚙️)
2. Enter your package name (find it in `android/app/build.gradle`)
   - Look for `applicationId "com.example.posts_app"`
3. Download `google-services.json`
4. Place it in `android/app/` folder
5. In `android/build.gradle` add:
   ```gradle
   classpath 'com.google.gms:google-services:4.4.0'
   ```
6. In `android/app/build.gradle` add at bottom:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### OR use FlutterFire CLI (easier):
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure your app (run in project root)
flutterfire configure --project=YOUR_PROJECT_ID
```
This automatically creates `firebase_options.dart` - then update `main.dart`:
```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Step 6: Update Firestore Security Rules
1. Firebase Console → Firestore → **Rules** tab
2. Replace all content with the rules from `firestore.rules`
3. Click **Publish**

### Step 7: Install Dependencies
```bash
flutter pub get
```

### Step 8: Run the App
```bash
flutter run
```

---

## How to Use the App

### First Time Setup
1. Tap the **➕ button** in the top-right corner
2. This adds 12 sample posts to your Firestore database
3. Posts will appear immediately!

### Filtering by Category
- Tap **Flutter**, **Firebase**, or **Dart** chips to filter
- Tap **All** to see all posts

### Sorting
- Tap **📅 Newest First** to sort by date
- Tap **❤️ Most Liked** to sort by popularity

### Searching
- Type in the search bar to find posts by title
- Search uses **prefix matching** (e.g., "Flu" finds "Flutter...")
- Clear the search to go back to normal view

### Infinite Scroll
- Scroll to the bottom to automatically load more posts
- A loading spinner appears while fetching
- "All posts loaded!" appears when no more posts exist

---

## Understanding the Firestore Queries

### Basic Query (Filter + Sort + Limit)
```dart
// STEP 3: WHERE clause - filter by category
// STEP 4: ORDER BY - sort results
// STEP 5: LIMIT - only get 5 at a time
_postsCollection
  .where('category', isEqualTo: 'Flutter')  // Filter
  .orderBy('timestamp', descending: true)   // Sort
  .limit(5)                                  // Pagination size
  .get();
```

### Pagination (Next Page)
```dart
// STEP 6: Save last document from previous page
DocumentSnapshot lastDoc = snapshot.docs.last;

// STEP 7: Use startAfterDocument to get next page
_postsCollection
  .orderBy('timestamp', descending: true)
  .startAfterDocument(lastDoc)  // ← This is the magic!
  .limit(5)
  .get();
```

### Search (Prefix Search)
```dart
// STEP 9: Prefix search - finds titles starting with searchTerm
_postsCollection
  .orderBy('title')
  .where('title', isGreaterThanOrEqualTo: 'Flu')
  .where('title', isLessThanOrEqualTo: 'Flu\uf8ff')  // \uf8ff = end
  .limit(5)
  .get();
```

### Multiple Categories
```dart
// STEP 11: whereIn - match any of these categories
_postsCollection
  .where('category', whereIn: ['Flutter', 'Dart'])
  .get();
```

---

## Firestore Index Requirements

When you run with `where` + `orderBy` together, Firestore may ask you to create a **composite index**.

You'll see an error like:
```
[cloud_firestore/failed-precondition] The query requires an index.
You can create it here: https://console.firebase.google.com/...
```

**Just click the link in the error!** It will auto-create the index for you.

Common indexes needed:
| Collection | Fields | Order |
|------------|--------|-------|
| posts | category ASC, timestamp DESC | |
| posts | category ASC, likes DESC | |

---

## Project Structure Explained

```
lib/
├── main.dart              → App entry point, Firebase init
├── models/
│   └── post_model.dart    → Post data class
├── services/
│   └── firestore_service.dart  → All database queries
├── screens/
│   └── home_screen.dart   → Main UI with all features
└── widgets/
    └── post_card.dart     → Single post card widget
```

---

## Troubleshooting

**"No posts showing"**
→ Tap the ➕ button to add sample data first

**"Query requires an index" error**
→ Click the URL in the error message to auto-create the index

**"Failed to load posts" error**
→ Check your Firestore rules are set to test mode (allow read/write)

**App won't run / Firebase error**
→ Make sure `google-services.json` is in `android/app/` folder
→ Run `flutter clean` then `flutter pub get` then `flutter run`
