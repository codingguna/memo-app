// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'home/home_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
   // await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds
    
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initializeAuth();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.isAuthenticated) {
                  return const HomeWrapper();
                } else {
                  return const LoginScreen();
                }
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //   backgroundColor: AppTheme.primaryColor,
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Icon(
    //           Icons.local_hospital_rounded,
    //           size: 100,
    //           color: Colors.white,
    //         ),
    //         const SizedBox(height: AppSpacing.lg),
    //         Text(
    //           'Hospital Management',
    //           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    //             color: Colors.white,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //         const SizedBox(height: AppSpacing.xl),
    //         const CircularProgressIndicator(
    //           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    //         ),
    //       ],
    //     ),
    //   ),
    body: SizedBox.shrink(),);
  }

}