import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hospital_management/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupFCMTokenRefreshListener();
  }

 void _setupFCMTokenRefreshListener() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final prefs = await SharedPreferences.getInstance();
    final hospitalId = prefs.getInt('hospitalId');
    final userId = prefs.getInt('userId');
    final role = prefs.getString('role');
    final institutionId = prefs.getString('institutionId');

    if (hospitalId != null && userId != null && role != null && institutionId != null) {
      await ApiService().updateFCMToken(
        newToken,
        hospitalId,
        userId,
        role,
        institutionId,
      );
    }
  });
}


  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showMessage("Please enter phone and password.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService().login(phone, password);

      if (response.containsKey('token') &&
          response.containsKey('user_id') &&
          response.containsKey('hospital_id') &&
          response.containsKey('role') &&
          response.containsKey('institution_id')) {

        final prefs = await SharedPreferences.getInstance();
           await prefs.setString('authToken', response['token']);
           await prefs.setInt('userId', response['user_id']);
           await prefs.setInt('hospitalId', response['hospital_id']);
           await prefs.setString('role', response['role']);
           await prefs.setString('institutionId', response['institution_id']); // 👈 store as string

       final fcmToken = await FirebaseMessaging.instance.getToken();
       if (fcmToken != null) {
          await ApiService().updateFCMToken(
            fcmToken,
            response['hospital_id'],
            response['user_id'],
            response['role'],
            response['institution_id'], // 👈 use as string
    );
  }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        _showMessage("Invalid response from server.");
      }
    } catch (e) {
      _showMessage("Login error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login Info"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
