import 'package:flutter/material.dart';
import '../pages/product_page.dart';
import '../pages/cart_page.dart'; // Page Panier
import '../pages/account_page.dart'; // Page Compte

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Liste des pages associées aux onglets
  final List<Widget> _pages = [
    ProductPage(), // Page Home
    CartPage(),    // Page Panier
    AccountPage(), // Page Compte
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Affiche la page correspondant à l'onglet sélectionné
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Compte',
          ),
        ],
        selectedItemColor: Colors.teal, // Couleur de l'onglet sélectionné
        unselectedItemColor: Colors.grey, // Couleur des onglets non sélectionnés
      ),
    );
  }
}