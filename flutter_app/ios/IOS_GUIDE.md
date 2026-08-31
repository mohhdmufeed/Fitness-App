# 🍏 Kinetic Fusion — iOS & iPhone Deployment Guide

This project is **fully configured and ready for iOS & iPhone deployment**.

---

## 📁 iOS Project Structure

```
flutter_app/
├── ios/
│   ├── Runner/
│   │   ├── Info.plist               # Configured with Camera, Photos, GPS & Motion permissions
│   │   ├── AppDelegate.swift        # iOS app lifecycle delegate
│   │   └── Assets.xcassets/         # App icons & launch splash assets
│   ├── Runner.xcodeproj/            # Xcode project file
│   ├── Runner.xcworkspace/          # Xcode workspace file
│   └── Podfile                      # CocoaPods configuration (iOS 13.0+ target)
├── lib/                             # Core cross-platform Flutter application code
└── pubspec.yaml                     # Dependencies with iOS platform support
```

---

## ⚙️ Configured iOS Permissions (`Info.plist`)

| Permission | iOS Key | Purpose in App |
|---|---|---|
| 📷 **Camera** | `NSCameraUsageDescription` | Taking workout & profile photos directly |
| 🖼️ **Photo Library** | `NSPhotoLibraryUsageDescription` | Uploading profile avatars from phone storage |
| 📍 **GPS Location** | `NSLocationWhenInUseUsageDescription` | Route, distance, and pace tracking for Outdoor Runs |
| 🏃 **Motion / Sensor** | `NSMotionUsageDescription` | Counting steps during indoor treadmill sessions |
| 🔐 **Biometrics** | `NSFaceIDUsageDescription` | Face ID / Touch ID secure health data protection |

---

## 🚀 How to Run & Build on iOS / iPhone

### Option 1: Using Xcode (macOS)
1. Open the iOS workspace in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. In Xcode:
   - Select your connected **iPhone** or an **iOS Simulator** (e.g. iPhone 15 / 16 Pro) as the target.
   - Go to **Signing & Capabilities** -> Select your Apple Developer Team.
   - Click **Run** (`Cmd + R`) to launch the app.

---

### Option 2: Using Flutter CLI (macOS terminal)
1. Install CocoaPods dependencies:
   ```bash
   cd ios
   pod install
   cd ..
   ```
2. Run on iPhone / Simulator:
   ```bash
   flutter run -d iphone
   ```
3. Build iOS release bundle / IPA:
   ```bash
   flutter build ipa --release
   ```

---

### Option 3: Cloud Build without a Mac (Codemagic / GitHub Actions)
If you are developing on Windows and want to distribute an `.ipa` to your iPhone:
1. You can push this folder to Codemagic (https://codemagic.io).
2. Codemagic automatically executes `flutter build ipa` on a cloud macOS machine.
3. Install the resulting `.ipa` on your iPhone using **TestFlight** or **Apple Developer Ad-Hoc distribution**.

---

## 🔒 Local Retention Note
As requested, this folder is maintained **strictly on your local machine** and is not pushed to GitHub.
