# ⚡ Kinetic Fusion — Fitness & Health Tracker

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A high-performance, offline-first mobile fitness and health tracking application built with Flutter, Firebase, and a modern Warm Off-White / Pastel Red design system.**

[Screenshots](#-app-screenshots) • [Features](#-key-features) • [Architecture](#-system-architecture) • [Getting Started](#-getting-started) • [Author](#-author)

</div>

---

## 📱 App Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center" width="25%">
        <b>🔐 Sign In</b><br/><br/>
        <img src="assets/screenshots/auth_login.png" width="240" alt="Sign In Screen" />
      </td>
      <td align="center" width="25%">
        <b>📝 Create Account</b><br/><br/>
        <img src="assets/screenshots/auth_register.png" width="240" alt="Create Account Screen" />
      </td>
      <td align="center" width="25%">
        <b>🏋️ Train & Workouts</b><br/><br/>
        <img src="assets/screenshots/workouts_screen.png" width="240" alt="Workouts Screen" />
      </td>
      <td align="center" width="25%">
        <b>🍽️ Macros & Nutrition</b><br/><br/>
        <img src="assets/screenshots/macros_screen.png" width="240" alt="Macros & Nutrition Screen" />
      </td>
    </tr>
    <tr>
      <td align="center" width="25%">
        <b>🏃 Runs & Cardio</b><br/><br/>
        <img src="assets/screenshots/runs_cardio.png" width="240" alt="Runs & Cardio Screen" />
      </td>
      <td align="center" width="25%">
        <b>📈 Progress & Stats</b><br/><br/>
        <img src="assets/screenshots/progress_screen.png" width="240" alt="Progress & Stats Screen" />
      </td>
      <td align="center" width="25%">
        <b>👤 Account & Overview</b><br/><br/>
        <img src="assets/screenshots/account_overview.png" width="240" alt="Account & Overview Screen" />
      </td>
      <td align="center" width="25%">
        <b>🚪 Sign Out Dialog</b><br/><br/>
        <img src="assets/screenshots/sign_out_dialog.png" width="240" alt="Sign Out Dialog" />
      </td>
    </tr>
  </table>
</div>

---

## ✨ Key Features

### 🏋️ 1. Train & Workout Tracker
- **Set Logging**: Record exercise sets with weight in Kilograms (**kg**), reps, and completion checkboxes.
- **Routines & Templates**: Save and load custom workout splits and exercises.
- **1RM Strength Estimation**: Automatic Brzycki 1RM progression formulas.
- **Volume Calculations**: Total accumulated volume lifted per session.

### 🍽️ 2. Macros & Nutrition
- **Visual Calorie Ring**: Real-time circular progress gauge tracking daily target vs consumed calories.
- **Macronutrient Split**: Progress breakdown for Protein, Carbohydrates, and Fats.
- **Meal Organization**: Breakfast, Lunch, Dinner, and Snacks categorization.
- **AI Food Logger**: Natural language meal estimator powered by offline AI heuristic parsing.

### 🏃 3. Runs & Cardio Tracking
- **Outdoor GPS Run**: Real-time route, distance (miles), duration, and pace tracking.
- **Indoor Treadmill Run**: Built-in pedometer step counter sensor tracking.
- **Activity History**: Cumulative distance and calorie expenditure analytics.

### 📈 4. Progress & Analytics
- **Bodyweight Tracking**: Metric weight tracking in Kilograms (**kg**).
- **Interactive Graphs**: Smooth curved line chart visualizing weight trends over time using `fl_chart`.
- **Strength Analytics**: Monthly lift progression tracking across compound movements (Bench Press, Back Squat, Deadlift, Overhead Press).

### 👤 5. Account & Overview
- **Profile Photo Picker**: Interactive avatar supporting **Camera capture** and **Phone library** photo uploads via `image_picker`.
- **Daily Metric Snapshots**: Real-time summary cards for Nutrition, Workout Sets, Bodyweight, and Cardio.
- **Nutrition & Fitness Targets**: Customizable calorie targets, protein, carbs, and fat goals.
- **Cloud Sync Status**: Real-time cloud sync indicator.

---

## 🔒 Authentication & Security

- **Hybrid Authentication Engine**: Full Firebase Authentication integration with Cloud Firestore cloud backup.
- **Local Fallback Encryption**: Client-side **SHA-256 cryptographic password hashing** via `crypto` and `flutter_secure_storage`.
- **Session Persistence**: Automatic encrypted token restoration on app launch.
- **Guest Mode**: Offline guest access for immediate offline usability.

---

## 🛠️ System Architecture & Tech Stack

```
flutter_app/
├── lib/
│   ├── models/           # Data models (Exercise, Meal, RunRecord, UserModel, etc.)
│   ├── providers/        # State management (AuthProvider, WorkoutProvider, MacroProvider, etc.)
│   ├── screens/          # UI views (AuthGate, LoginPage, RegisterPage, HomePage, Workouts, etc.)
│   ├── services/         # Firebase, SecureStorage, OfflineStorage, Connectivity, Biometrics
│   ├── theme/            # Kinetic Fusion Color Palette, Typography & Theme Tokens
│   └── widgets/          # Reusable 48px pill buttons, 32px pill inputs, cards
└── android/              # Native Android configuration, permissions & build scripts
```

| Technology | Purpose |
|---|---|
| **Flutter & Dart** | Cross-platform mobile application framework |
| **Provider** | Reactive state management |
| **Firebase Auth & Firestore** | Cloud authentication and database synchronization |
| **Flutter Secure Storage** | Key-value encrypted storage for cryptographic hashes |
| **Shared Preferences** | Local offline storage cache |
| **Image Picker** | Camera and Gallery media access |
| **FL Chart** | Interactive charting and visualization |
| **Connectivity Plus** | Network state and online/offline monitoring |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24.0 or newer)
- [Android Studio](https://developer.android.com/studio) / Android SDK
- Java JDK 17+

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mohhdmufeed/Fitness-App.git
   cd Fitness-App/flutter_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on connected device / emulator**:
   ```bash
   flutter run
   ```

4. **Build release APK**:
   ```bash
   flutter build apk --release
   ```

---

## 👨‍💻 Author

<div align="center">

**Mohd Mufeed**

GitHub: [@mohhdmufeed](https://github.com/mohhdmufeed)  
Repository: [mohhdmufeed/Fitness-App](https://github.com/mohhdmufeed/Fitness-App)

</div>

---

## 📄 License

This project is licensed under the MIT License — see the LICENSE file for details.
