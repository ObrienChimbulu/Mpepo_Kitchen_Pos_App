import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final http.Client client = http.Client();
  String? _token;
  User? _currentUser;

  // Getters
  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null;

  Future<void> init() async {
    await _loadTokenFromStorage();
  }

  Future<void> _loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
    }
  }

  Future<void> _saveTokenToStorage(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', json.encode(user.toJson()));
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'username=$username&password=$password',
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        _token = authResponse.accessToken;
        _currentUser = authResponse.user;

        await _saveTokenToStorage(_token!, _currentUser!);
        return authResponse;
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['detail'] ?? 'Login failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<User> register({
    required String username,
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      final registerRequest = RegisterRequest(
        username: username,
        email: email,
        fullName: fullName,
        password: password,
      );

      final response = await client.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registerRequest.toJson()),
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['detail'] ?? 'Registration failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await _clearStorage();
  }

  Map<String, String> get authHeaders {
    if (_token == null) return {};
    return {'Authorization': 'Bearer $_token'};
  }
}
