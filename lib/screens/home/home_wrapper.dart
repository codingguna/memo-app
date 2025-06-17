// lib/screens/home/home_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'admin_home_screen.dart';
import '../auth/login_screen.dart';

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        
        if (user == null) {
          return const Scaffold(
            body: LoginScreen(),
          );
        }

        // Check if user is superuser or staff
        if (user.isSuperuser) {
          return const AdminHomeScreen();
        }
        
        // Default dashboard for other users
        return const DashboardScreen();
      },
    );
  }
}