import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _baseUrl = 'http://127.0.0.1:8000/api/v1/auth'; // dein Backend

  Future<bool> signUp({required String email, required String username, required String password}) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (res.statusCode == 200) return true;
    return false;
  }

  Future<bool> login({required String email, required String password}) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _storage.write(key: 'jwt', value: data['access_token']);
      return true;
    }
    return false;
  }

  Future<String?> getToken() async => await _storage.read(key: 'jwt');

  Future<void> logout() async => await _storage.delete(key: 'jwt');
}
