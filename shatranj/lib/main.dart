import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}
// AIzaSyCvv5OXy4sJI6ho6wO0ZP_WMNhlPwz40x4