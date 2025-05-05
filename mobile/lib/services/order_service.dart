import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';

class OrderService {
  // Vérifier le stock disponible pour chaque produit
  Future<bool> checkStock(List<Map<String, dynamic>> cart) async {
    final token = await _getToken();

    for (var item in cart) {
      final productId = item['id'];
      final requestedQuantity = item['quantite'];

      // Appeler l'API pour récupérer les informations du produit
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/produits/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final productData = jsonDecode(response.body);
        final availableQuantity = productData['quantite'];

        // Vérifier si la quantité demandée est disponible
        if (requestedQuantity > availableQuantity) {
          return false; // Stock insuffisant
        }
      } else {
        throw Exception("Erreur lors de la vérification du stock pour le produit $productId.");
      }
    }

    return true; // Stock suffisant pour tous les produits
  }

  // Créer une réservation
  Future<void> createReservation({
    required List<Map<String, dynamic>> cart,
    required int utilisateurId,
    required int statusId,
    required String date,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/reservations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'date': date,
        'utilisateur_id': utilisateurId,
        'status_id': statusId,
        'details': cart.map((item) {
          return {
            'produit_id': item['id'],
            'quantite': item['quantite'],
          };
        }).toList(),
      }),
    );

    if (response.statusCode == 201) {
      // Réservation créée avec succès
      return;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception("Erreur : ${errorData['message'] ?? 'Une erreur est survenue.'}");
    }
  }

  // Récupérer le token JWT depuis SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  // Décrémenter le stock d'un produit
  Future<void> decrementStock(int productId, int quantity) async {
    final token = await _getToken();

    // Récupérer le stock actuel du produit
    final getResponse = await http.get(
      Uri.parse('${Config.apiUrl}/produits/$productId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (getResponse.statusCode != 200) {
      throw Exception("Erreur lors de la récupération du stock pour le produit $productId.");
    }

    final productData = jsonDecode(getResponse.body);
    final availableQuantity = productData['quantite'];

    // Calculer le nouveau stock
    final newQuantity = availableQuantity - quantity;
    if (newQuantity < 0) {
      throw Exception("Stock insuffisant pour le produit $productId.");
    }

    // Mettre à jour le stock
    final putResponse = await http.put(
      Uri.parse('${Config.apiUrl}/produits/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'quantite': newQuantity}),
    );

    if (putResponse.statusCode != 200) {
      throw Exception("Erreur lors de la mise à jour du stock pour le produit $productId.");
    }
  }
}