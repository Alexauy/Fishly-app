import 'package:flutter/widgets.dart';

import 'app.dart';
import 'firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  runApp(const FishlyApp());
}
