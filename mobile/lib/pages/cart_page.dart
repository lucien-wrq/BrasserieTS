import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/user_service.dart'; // Import du service utilisateur

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cartService = CartService();
  final _orderService = OrderService();
  final _userService = UserService(); // Instance du service utilisateur
  List<Map<String, dynamic>> _cart = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() async {
    try {
      final cart = await _cartService.getCart();
      setState(() {
        _cart = cart;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement du panier.")),
      );
    }
  }

  void _validateReservation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Récupérer l'ID du client
      final userId = await _userService.getUserId();
      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible de récupérer l'ID du client.")),
        );
        return;
      }

      // Vérifier le stock disponible
      final stockDisponible = await _orderService.checkStock(_cart);
      if (!stockDisponible) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Stock insuffisant pour certains produits.")),
        );
        return;
      }

      // Créer la réservation
      await _orderService.createReservation(
        _cart,
        userId, // Utiliser l'ID du client récupéré
        1, // Remplacez par l'ID du statut approprié
      );

      // Vider le panier après validation
      await _cartService.clearCart();
      setState(() {
        _cart = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Réservation validée avec succès !")),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la validation de la réservation.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mon Panier")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _cart.isEmpty
              ? Center(
                  child: Text(
                    "Votre panier est vide.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final product = _cart[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['nom'] ?? 'Produit inconnu',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Prix : ${product['prix'] ?? 'N/A'} €",
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Quantité : ${product['quantite'] ?? 1}",
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: _cart.isNotEmpty ? _validateReservation : null,
                        child: Text("Valider la réservation"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}