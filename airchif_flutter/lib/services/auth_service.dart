import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://airchif-backend.onrender.com/api/v1/auth';

  Future<bool> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'username': username, 'password': password}),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _storage.write(key: 'access_token', value: data['access_token']);
      await _storage.write(key: 'refresh_token', value: data['refresh_token']);
      return true;
    }
    return false;
  }

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> refreshToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null) return false;

    final res = await http.post(
      Uri.parse('$_baseUrl/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refresh}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _storage.write(key: 'access_token', value: data['access_token']);
      await _storage.write(key: 'refresh_token', value: data['refresh_token']);
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> getMe() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final res = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) return jsonDecode(res.body);

    if (res.statusCode == 401 && await refreshToken()) {
      return await getMe();
    }
    return null;
  }

  Future<bool> updateProfile({String? email, String? username}) async {
    final token = await getAccessToken();
    if (token == null) return false;

    final body = <String, dynamic>{};
    if (email != null && email.trim().isNotEmpty) body['email'] = email.trim();
    if (username != null && username.trim().isNotEmpty) body['username'] = username.trim();
    if (body.isEmpty) return true;

    final res = await http.patch(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final tokenObj = data['token'];
      if (tokenObj != null) {
        await _storage.write(key: 'access_token', value: tokenObj['access_token']);
        await _storage.write(key: 'refresh_token', value: tokenObj['refresh_token']);
      }
      return true;
    }

    if (res.statusCode == 401 && await refreshToken()) {
      return await updateProfile(email: email, username: username);
    }

    return false;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await getAccessToken();
    if (token == null) return false;

    final res = await http.post(
      Uri.parse('$_baseUrl/me/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (res.statusCode == 204) return true;

    if (res.statusCode == 401 && await refreshToken()) {
      return await changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    }

    return false;
  }
}
