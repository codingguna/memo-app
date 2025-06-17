// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hospital_management/welcome.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
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
