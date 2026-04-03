# Fishly

Fishly is a Flutter planner app with a gamified goal system, a customizable fish companion named Gubby, and Firebase-backed account and persistence support.

## What Is Included

- Daily planner with regular goals, big goals, and timed subgoals
- Coin rewards tied to task duration
- Shop system for Gubby accessories and tank decorations
- Monthly completion history
- Firebase Authentication with email/password
- Cloud Firestore persistence for profiles, tasks, coins, owned items, and equipped items

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

- [lib/main.dart](C:\Users\16194\Documents\New project\fishly_flutter\lib\main.dart)

## Firebase Setup Notes

This repository no longer includes live Firebase credentials.

Included in the repo:

- Placeholder Android Firebase config at [google-services.json](C:\Users\16194\Documents\New project\fishly_flutter\android\app\google-services.json)
- Firebase app bootstrap in [firebase_bootstrap.dart](C:\Users\16194\Documents\New project\fishly_flutter\lib\firebase\firebase_bootstrap.dart)
- Placeholder Firebase options in [firebase_options.dart](C:\Users\16194\Documents\New project\fishly_flutter\lib\firebase\firebase_options.dart)
- Firestore rules in [firestore.rules](C:\Users\16194\Documents\New project\fishly_flutter\firestore.rules)

What that means:

- If someone clones this repo, they must provide their own Firebase configuration before Firebase-backed features will work
- The committed config files are safe placeholders only
- Email/password and Firestore functionality require real local Firebase config values

## If Someone Wants Their Own Firebase Project

They should replace the current Firebase configuration with their own:

1. Create a Firebase project.
2. Add an Android app in Firebase.
3. Download a new `google-services.json`.
4. Replace [google-services.json](C:\Users\16194\Documents\New project\fishly_flutter\android\app\google-services.json).
5. Run FlutterFire configuration for their project.
6. Replace [firebase_options.dart](C:\Users\16194\Documents\New project\fishly_flutter\lib\firebase\firebase_options.dart).
7. Deploy Firestore rules from [firestore.rules](C:\Users\16194\Documents\New project\fishly_flutter\firestore.rules).

## Current Auth Support

Currently implemented:

- Email/password account creation
- Email/password sign-in

Not currently implemented:

- Google sign-in

## Notes

- Windows desktop builds may still depend on the local Visual Studio C++ toolchain because of Firebase plugins.
- Android emulator testing is the primary supported workflow right now.
