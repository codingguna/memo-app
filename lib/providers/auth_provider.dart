// lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user.dart';
import '../models/hospital.dart';
import '../models/auth_response.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  Hospital? _hospital;
  String? _token;
  bool _isLoading = false;
  String? _error;
  final ApiService apiService = ApiService();

  final ApiService _apiService = ApiService();

  // Getters
  User? get user => _user;
  Hospital? get hospital => _hospital;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  // User role getters
  bool get isSuperuser => _user?.isSuperuser ?? false;
  bool get isStaff => isSuperuser; // Assuming staff == superuser
  bool get isApprover => _user?.isApprover ?? false;
  bool get isResponder => _user?.isResponder ?? false;
  bool get isCreator => _user?.isCreator ?? false;

  // Initialize auth state from SharedPreferences
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenStr = prefs.getString('authToken');
      final userStr = prefs.getString('user');
      final hospitalStr = prefs.getString('hospital');

      if (tokenStr != null && userStr != null && hospitalStr != null) {
        _token = tokenStr;
        _user = User.fromJson(jsonDecode(userStr));
        _hospital = Hospital.fromJson(jsonDecode(hospitalStr));
        _clearError();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to initialize authentication: \${e.toString()}');
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  // Login method
  Future<bool> login(String phoneNumber, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.login(phoneNumber, password);
      final authResponse = AuthResponse.fromJson(response);
      final rolename=authResponse.user.role;
      await _saveAuthData(authResponse);

      // Fetch roles and get roleId from role name
      final rolesResponse = await _apiService.getRoles(authResponse.hospital.id);
      final roles = rolesResponse['roles'] as List<dynamic>;
      final matchedRole = roles.firstWhere(
        (role) => role['name'].toString().toUpperCase() == roleName.toUpperCase(),
        orElse: () => null,
      );

      if (matchedRole == null || matchedRole['id'] == null) {
        throw Exception('Role ID not found for role: \${authResponse.user.role}');
      }

      final roleId = matchedRole['id'];

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await updateFCMToken(fcmToken, blockId: authResponse.user.currentBlockId, roleId: roleId);
      }

      return true;
    } catch (e) {
      _setError('Login failed: \${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set password method
  Future<bool> setPassword(String phoneNumber, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.setPassword(phoneNumber, password);
      final authResponse = AuthResponse.fromJson(response);

      await _saveAuthData(authResponse);
      return true;
    } catch (e) {
      _setError('Set password failed: \${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout method
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _apiService.logout();
    } catch (e) {
      debugPrint('Logout API call failed: \$e');
    }

    await _clearAuthData();
    _setLoading(false);
  }

  // Update FCM token
  Future<bool> updateFCMToken(String fcmToken, {int? blockId, required int roleId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final int? hospitalId = prefs.getInt('hospitalId') ?? _hospital?.id;
      final int? userId = _user?.id;
      final String? institutionId = _user?.institutionId;

      if (hospitalId == null || userId == null || institutionId == null) {
        _setError('Missing required user data to update FCM token');
        return false;
      }

      await _apiService.updateFCMToken(
        fcmToken,
        hospitalId,
        userId,
        roleId,
        institutionId,
      );

      if (_user != null) {
        _user = _user!.copyWith(
          fcmToken: fcmToken,
          fcmTokenUpdatedAt: DateTime.now(),
          currentBlockId: blockId ?? _user!.currentBlockId,
        );
        await _saveUserData(_user!);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to update FCM token: \${e.toString()}');
      return false;
    }
  }

  // Update current block
  Future<bool> updateCurrentBlock(int blockId, String blockName) async {
    try {
      if (_user != null) {
        _user = _user!.copyWith(
          currentBlockId: blockId,
          currentBlockName: blockName,
        );
        await _saveUserData(_user!);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Failed to update current block: \${e.toString()}');
      return false;
    }
  }

  // Private methods
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();

    _token = authResponse.token;
    _user = authResponse.user;
    _hospital = authResponse.hospital;

    await prefs.setString('authToken', authResponse.token);
    await prefs.setString('user', jsonEncode(authResponse.user.toJson()));
    await prefs.setString('hospital', jsonEncode(authResponse.hospital.toJson()));

    _clearError();
    notifyListeners();
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('user');
    await prefs.remove('hospital');

    _token = null;
    _user = null;
    _hospital = null;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  Future<bool> fetchUserData() async {
    _setLoading(true);
    _clearError();

    try {
      if (_user == null || _hospital == null) {
        throw Exception('User or hospital data not available');
      }

      final response = await _apiService.getUser(_hospital!.id, _user!.id);
      final updatedUser = User.fromJson(response);
      _user = updatedUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(updatedUser.toJson()));

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to fetch user data: \${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
