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

  // Récupérer les réservations de l'utilisateur
  Future<List<Map<String, dynamic>>> fetchUserReservations(int userId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/reservations'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Filtrer les réservations pour ne garder que celles de l'utilisateur
      final filteredReservations = List<Map<String, dynamic>>.from(data).where((reservation) {
        return reservation['utilisateur']['id'] == userId; // Accéder à l'ID utilisateur imbriqué
      }).toList();

      return filteredReservations;
    } else {
      throw Exception("Erreur lors de la récupération des réservations.");
    }
  }

  // Supprimer une réservation
  Future<void> deleteReservation(String reservationId) async {
    final token = await _getToken();

    try {
      print("ID de la réservation à supprimer : $reservationId");

      final response = await http.delete(
        Uri.parse('${Config.apiUrl}/reservations/$reservationId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Réponse de l'API pour la suppression : ${response.statusCode}");
      print("Corps de la réponse : ${response.body}");

      // Accepter les codes de statut 200 et 204 comme succès
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Réservation supprimée avec succès pour l'ID : $reservationId");
        return; // Succès, sortir de la méthode
      }

      // Si le code de statut n'est pas 200 ou 204, lever une exception
      throw Exception("Erreur lors de la suppression de la réservation.");
    } catch (e) {
      print("Erreur dans deleteReservation : $e");
      rethrow; // Relancer l'exception pour la gestion en amont
    }
  }

  // Récupérer les détails d'une réservation spécifique
  Future<List<Map<String, dynamic>>> fetchReservationDetails(int reservationId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/details-reservations'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final details = List<Map<String, dynamic>>.from(jsonDecode(response.body));

      // Filtrer les détails pour ne garder que ceux correspondant à la réservation
      final filteredDetails = details.where((detail) {
        return detail['reservation']['id'] == reservationId;
      }).toList();

      return filteredDetails;
    } else {
      throw Exception("Erreur lors de la récupération des détails de la réservation.");
    }
  }

  // Récupérer les informations d'un produit
  Future<Map<String, dynamic>> fetchProductDetails(int productId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/produits/$productId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de la récupération des informations du produit.");
    }
  }

  // Incrémenter le stock d'un produit
  Future<void> incrementStock(int productId, int quantity) async {
    final token = await _getToken();

    try {
      // Récupérer le stock actuel du produit
      print("Récupération des informations du produit $productId");
      final getResponse = await http.get(
        Uri.parse('${Config.apiUrl}/produits/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (getResponse.statusCode != 200) {
        print("Erreur lors de la récupération du produit : ${getResponse.body}");
        throw Exception("Erreur lors de la récupération du stock pour le produit $productId.");
      }

      final productData = jsonDecode(getResponse.body);
      final currentStock = productData['quantite'];

      if (currentStock == null) {
        throw Exception("Le champ 'quantite' est manquant ou invalide pour le produit $productId.");
      }

      print("Stock actuel du produit $productId : $currentStock");

      // Calculer le nouveau stock
      final newStock = currentStock + quantity;
      print("Nouveau stock calculé pour le produit $productId : $newStock");

      // Mettre à jour le stock
      final putResponse = await http.put(
        Uri.parse('${Config.apiUrl}/produits/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'quantite': newStock}),
      );

      print("Réponse de l'API pour la mise à jour du produit : ${putResponse.statusCode}");
      print("Corps de la réponse : ${putResponse.body}");

      // Accepter les codes de statut 200 et 204 comme succès
      if (putResponse.statusCode != 200 && putResponse.statusCode != 204) {
        throw Exception("Erreur lors de la mise à jour du stock pour le produit $productId.");
      }

      print("Stock mis à jour avec succès pour le produit $productId");
    } catch (e) {
      print("Erreur dans incrementStock : $e");
      rethrow;
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
    final userId = prefs.getString('userId'); // Vérifiez si l'ID est stocké en tant que String
    if (userId != null) {
      return int.tryParse(userId); // Convertir en int si nécessaire
    }
    return null; // Retourner null si l'ID n'est pas disponible
  }
}