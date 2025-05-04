import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart'; // Import de la configuration

class AuthService {
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/login'), 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Stocker le token JWT
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwtToken', data['token']);

      // Récupérer l'ID de l'utilisateur et le stocker en tant que String
      final userId = data['utilisateur']['id'].toString();
      await prefs.setString('userId', userId);

      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprimer toutes les données utilisateur
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // Récupérer l'ID utilisateur en tant que String
  }

  Future<bool> register(Map<String, String> payload) async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/utilisateurs'), 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      return true; // Succès
    } else {
      throw Exception("Erreur lors de l'inscription : ${response.body}");
    }
  }
}