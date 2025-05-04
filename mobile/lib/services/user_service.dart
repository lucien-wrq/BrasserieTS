import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';

class UserService {
  // Récupérer les informations de l'utilisateur
  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/utilisateurs/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de la récupération des données utilisateur.");
    }
  }

  // Mettre à jour les informations de l'utilisateur
  Future<void> updateUserData(String userId, Map<String, String> payload) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('${Config.apiUrl}/utilisateurs/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    // Vérifier les codes de statut HTTP acceptés comme succès
    if (response.statusCode == 200 || response.statusCode == 204) {
      // Succès, rien à faire
      return;
    } else {
      // En cas d'erreur, analyser la réponse
      final errorData = jsonDecode(response.body);
      throw Exception("Erreur : ${errorData['message'] ?? 'Une erreur est survenue.'}");
    }
  }

  // Récupérer le token JWT depuis SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  // Récupérer l'ID de l'utilisateur depuis SharedPreferences
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId'); // Assurez-vous que l'ID est stocké sous cette clé
  }
}