import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hospital_management/welcome.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Initialize Firebase
  await _requestNotificationPermissions(); // 🔒 Optional: ask for permissions
  runApp(const MyApp());
}

Future<void> _requestNotificationPermissions() async {
  await FirebaseMessaging.instance.requestPermission();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Hospital Management',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: WelcomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
