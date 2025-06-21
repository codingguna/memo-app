// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseURL =
      'https://guna25.pythonanywhere.com'; // Change this to your API URL

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }

    return headers;
  }

  Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseURL$endpoint');
    final headers = await _getHeaders();

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PATCH':
        response = await http.patch(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Add this method to your ApiService class:

  Future<List<dynamic>> _makeListRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseURL$endpoint');
    final headers = await _getHeaders();

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      default:
        throw Exception('Unsupported HTTP method for list: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded;
      } else {
        throw Exception(
            'Expected list response but got: ${decoded.runtimeType}');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Auth endpoints

  Future<Map<String, dynamic>> login(
      String phoneNumber, String password) async {
    return await _makeRequest(
      '/api/token-auth/',
      method: 'POST',
      body: {
        'phone': phoneNumber,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> setPassword(
      String phoneNumber, String password) async {
    return await _makeRequest(
      '/api/set-password/', // Adjust endpoint as needed
      method: 'POST',
      body: {
        'phone': phoneNumber,
        'password': password,
      },
    );
  }

  Future<void> logout() async {
    try {
      await _makeRequest('/api/token-auth/logout/', method: 'POST');
    } catch (e) {
      // Handle logout error if needed
    }
  }

  // Hospital endpoints
  Future<Map<String, dynamic>> getHospital(int hospitalId) async {
    return await _makeRequest('/api/hospitals/$hospitalId/');
  }

  // Update FCM token
  Future<Map<String, dynamic>> updateFCMToken(
      String fcmToken, int hospitalId, int userId, int roleId, String institutionId) async {
    return await _makeRequest(
      '/api/hospitals/$hospitalId/users/$userId/',
      method: 'PATCH',
      body: {
        'institution_id':institutionId,
        'role':roleId,
        'fcm_token': fcmToken,
      },
    );
  }

  // get user data
  Future<Map<String, dynamic>> getUser(int hospitalId, int userId) async {
    return await _makeRequest('/api/hospitals/$hospitalId/users/$userId/');
  }

  // Users endpoints
  Future<Map<String, dynamic>> getUsers(int hospitalId) async {
    return await _makeRequest('/api/hospitals/$hospitalId/users/');
  }

  Future<Map<String, dynamic>> createUser(
      int hospitalId, Map<String, dynamic> userData) async {
    return await _makeRequest(
      '/api/hospitals/$hospitalId/users/',
      method: 'POST',
      body: userData,
    );
  }

  Future<Map<String, dynamic>> updateUser(
      int hospitalId, int userId, Map<String, dynamic> userData) async {
    return await _makeRequest(
      '/api/hospitals/$hospitalId/users/$userId/',
      method: 'PATCH',
      body: userData,
    );
  }

  Future<void> deleteUser(int hospitalId, int userId) async {
    await _makeRequest('/api/hospitals/$hospitalId/users/$userId/',
        method: 'DELETE');
  }

  // Roles endpoints
  Future<Map<String, dynamic>> getRoles(int hospitalId) async {
    return await _makeRequest('/api/hospitals/$hospitalId/roles/');
  }

  Future<Map<String, dynamic>> createRole(
      int hospitalId, Map<String, dynamic> roleData) async {
    return await _makeRequest(
      '/api/hospitals/$hospitalId/roles/',
      method: 'POST',
      body: roleData,
    );
  }

  Future<Map<String, dynamic>> updateRole(
      int hospitalId, int roleId, Map<String, dynamic> roleData) async {
    return await _makeRequest(
      '/api/hospitals/$hospitalId/roles/$roleId/',
      method: 'PATCH',
      body: roleData,
    );
  }

  Future<void> deleteRole(int hospitalId, int roleId) async {
    await _makeRequest('/api/hospitals/$hospitalId/roles/$roleId/',
        method: 'DELETE');
  }

  // Blocks endpoints
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1605316048.
  Future<List<dynamic>> getBlocks(int hospitalId) async {
    return await _makeListRequest('/api/hospitals/$hospitalId/blocks/');
  }

  Future<Map<String, dynamic>> createBlock(
      int hospitalId, Map<String, dynamic> blockData) async {
    return await _makeRequest(
      '/api/hospitals/$hospitalId/blocks/',
      method: 'POST',
      body: blockData,
    );
  }

  Future<Map<String, dynamic>> updateBlock(
      int hospitalId, int blockId, Map<String, dynamic> blockData) async {
    return await _makeRequest(
      '/api/hospitals/$hospitalId/blocks/$blockId/',
      method: 'PATCH',
      body: blockData,
    );
  }

  Future<void> deleteBlock(int hospitalId, int blockId) async {
    await _makeRequest('/api/hospitals/$hospitalId/blocks/$blockId/',
        method: 'DELETE');
  }

  // Shifts endpoints
  Future<Map<String, dynamic>> getShifts(int hospitalId) async {
    return await _makeRequest('/api/hospitals/$hospitalId/shifts/');
  }

  Future<Map<String, dynamic>> createShift(
      int hospitalId, Map<String, dynamic> shiftData) async {
    return await _makeRequest(
      '/api/hospitals/$hospitalId/shifts/',
      method: 'POST',
      body: shiftData,
    );
  }

  Future<Map<String, dynamic>> updateShift(
      int hospitalId, int shiftId, Map<String, dynamic> shiftData) async {
    return await _makeRequest(
      '/api/hospitals/$hospitalId/shifts/$shiftId/',
      method: 'PATCH',
      body: shiftData,
    );
  }

  Future<void> deleteShift(int hospitalId, int shiftId) async {
    await _makeRequest('/api/hospitals/$hospitalId/shifts/$shiftId/',
        method: 'DELETE');
  }

  Future<List<dynamic>> getWards(int hospitalId,
      {int? block, int? floor}) async {
    final endpoint =
        '/api/hospitals/$hospitalId/wards/${block != null && floor != null ? '?block=$block&floor=$floor' : ''}';
    return await _makeListRequest(endpoint);
  }

// Block/Ward switching endpoints
  Future<bool> switchBlock(int userId, int hospitalId, int newBlockId) async {
    try {
      await _makeRequest(
        '/api/users/$userId/switch-block/',
        method: 'POST',
        body: {
          'hospital_id': hospitalId,
          'new_block_id': newBlockId,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> switchWard(int userId, int hospitalId, int newWardId) async {
    try {
      await _makeRequest(
        '/api/users/$userId/switch-ward/',
        method: 'POST',
        body: {
          'hospital_id': hospitalId,
          'new_ward_id': newWardId,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
