import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart'; // Import du service panier

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _productService = ProductService();
  final _cartService = CartService(); // Instance du service panier
  List<dynamic> _products = [];
  bool _isLoading = true;

  // Map pour stocker les quantités sélectionnées pour chaque produit
  Map<int, int> _selectedQuantities = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    try {
      final products = await _productService.fetchProducts();
      setState(() {
        _products = products;
        _isLoading = false;

        // Initialiser les quantités sélectionnées à 1 pour chaque produit
        for (var product in products) {
          _selectedQuantities[product['id']] = 1;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  void _addToCart(Map<String, dynamic> product, int quantity) async {
    try {
      await _cartService.addToCart(product, quantity); // Ajouter le produit au panier
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$quantity x ${product['nom']} ajouté(s) au panier !")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout au panier.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Produits")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final productId = product['id'];
                final selectedQuantity = _selectedQuantities[productId] ?? 1;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.network(
                          _productService.getProductImageUrl(productId),
                          height: 400,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product['nom'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Prix : ${product['prix']} €",
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Stock disponible : ${product['quantite'].toInt()}",
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Stepper pour choisir la quantité avec un TextField
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: selectedQuantity > 1
                                          ? () {
                                              setState(() {
                                                _selectedQuantities[productId] =
                                                    selectedQuantity - 1;
                                              });
                                            }
                                          : null,
                                    ),
                                    Container(
                                      width: 50,
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: TextEditingController(
                                          text: selectedQuantity.toString(),
                                        ),
                                        onSubmitted: (value) {
                                          final int? newQuantity = int.tryParse(value);
                                          if (newQuantity != null &&
                                              newQuantity > 0 &&
                                              newQuantity <= product['quantite']) {
                                            setState(() {
                                              _selectedQuantities[productId] = newQuantity;
                                            });
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Veuillez entrer une quantité valide (1-${product['quantite']})",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: selectedQuantity < product['quantite'].toInt()
                                          ? () {
                                              setState(() {
                                                _selectedQuantities[productId] =
                                                    selectedQuantity + 1;
                                              });
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_shopping_cart),
                                  color: Colors.teal,
                                  onPressed: () => _addToCart(product, selectedQuantity),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}