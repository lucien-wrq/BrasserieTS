import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart'; 
import 'auth_service.dart';

class ProductService {
  final AuthService _authService = AuthService();

  // Méthode pour récupérer la liste des produits
  Future<List<dynamic>> fetchProducts() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/produits'), 
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de la récupération des produits.");
    }
  }

  // Méthode pour générer l'URL de l'image d'un produit
  String getProductImageUrl(int productId) {
    return '${Config.apiUrl}/images/$productId';
  }
}