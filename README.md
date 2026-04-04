# Fishly

Fishly is a Flutter planner app with a gamified goal system, a customizable fish companion named Gubby, and Firebase-backed account and persistence support.

## What Is Included

- Daily planner with regular goals, big goals with subgoals, and focus time
- Coin rewards tied to task duration
- Shop system for Gubby accessories and tank decorations
- Monthly completion history
- Firebase Authentication with email/password
- Firebase-backed account deletion flow for removing user accounts and stored planner data
- Cloud Firestore persistence for profiles, tasks, coins, owned items, and equipped items

## HTML Prototype

A separate high-fidelity HTML prototype is included for design review and presentation purposes.

- Prototype entry point: `design-prototype/index.html`
- Prototype screens and assets are fully separated from the Flutter app
- These files are included as design/reference material and do not affect Flutter runtime behavior

## Running The App

### Requirements

- Flutter installed
- Android Studio installed
- An Android emulator or Android device available

### Local Run Steps

From the project folder:

```powershell
cd "C:\path\to\fishly_flutter"
flutter pub get
flutter run
```

If you want to target a specific emulator or device:

```powershell
flutter devices
flutter run -d <device-id>
```

The main app entry point is:

- `lib/main.dart`

## Firebase Setup Notes

This repository no longer includes live Firebase credentials.

Included in the repo:

- Placeholder Android Firebase config at `android/app/google-services.json`
- Firebase app bootstrap in `lib/firebase/firebase_bootstrap.dart`
- Placeholder Firebase options in `lib/firebase/firebase_options.dart`
- Firestore rules in `firestore.rules`

What that means:

- If someone clones this repo, the Flutter project and UI can still be reviewed normally
- Live Firebase-backed features will only work after local Firebase configuration is added
- The committed config files are safe placeholders only
- Email/password and Firestore functionality require real local Firebase config values

1. Create a Firebase project.
2. Add an Android app in Firebase.
3. Download a new `google-services.json`.
4. Replace `android/app/google-services.json`.
5. Run FlutterFire configuration for their project.
6. Replace `lib/firebase/firebase_options.dart`.
7. Deploy Firestore rules from `firestore.rules`.

## Legal

A privacy policy and account deletion page are included in `docs/` for public hosting and Google Play compliance.
