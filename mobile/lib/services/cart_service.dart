import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartService {
  static const String _cartKey = 'user_cart';

  // Ajouter un produit au panier avec une quantité
  Future<void> addToCart(Map<String, dynamic> product, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getCart();

    // Vérifier si le produit existe déjà dans le panier
    final existingProductIndex = cart.indexWhere((item) => item['id'] == product['id']);
    if (existingProductIndex != -1) {
      // Si le produit existe, augmenter la quantité
      cart[existingProductIndex]['quantite'] += quantity;
    } else {
      // Sinon, ajouter le produit avec la quantité spécifiée
      product['quantite'] = quantity;
      cart.add(product);
    }

    // Sauvegarder le panier mis à jour
    await prefs.setString(_cartKey, jsonEncode(cart));
  }

  // Récupérer le panier
  Future<List<Map<String, dynamic>>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString(_cartKey);
    if (cartString != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cartString));
    }
    return [];
  }

  // Mettre à jour le panier
  Future<void> updateCart(List<Map<String, dynamic>> cart) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, jsonEncode(cart));
  }

  // Vider le panier
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  Future<void> updateProductQuantity(int productId, int newQuantity) async {
    // Implémentez la logique pour mettre à jour la quantité dans le backend ou localement
    final prefs = await SharedPreferences.getInstance();
    final cart = prefs.getStringList('cart') ?? [];

    final updatedCart = cart.map((item) {
      final product = jsonDecode(item);
      if (product['id'] == productId) {
        product['quantite'] = newQuantity;
      }
      return jsonEncode(product);
    }).toList();

    await prefs.setStringList('cart', updatedCart);
  }

  Future<void> removeProductFromCart(int productId) async {
    // Implémentez la logique pour supprimer un produit du panier
    final prefs = await SharedPreferences.getInstance();
    final cart = prefs.getStringList('cart') ?? [];

    final updatedCart = cart.where((item) {
      final product = jsonDecode(item);
      return product['id'] != productId;
    }).toList();

    await prefs.setStringList('cart', updatedCart);
  }
}