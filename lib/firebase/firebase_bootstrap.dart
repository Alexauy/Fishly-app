import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<void> initialize() async {
    if (!_supportsFirebaseOnCurrentPlatform()) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static bool _supportsFirebaseOnCurrentPlatform() {
    if (kIsWeb) {
      return true;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return false;
    }
  }
}
