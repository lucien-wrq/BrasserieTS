import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'widgets/main_navigation.dart'; 
import 'pages/cart_page.dart'; // Page Panier

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brasserie BTS',
      theme: AppTheme.lightTheme, 
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => MainNavigation(), 
        '/cart': (context) => CartPage(),
      },
    );
  }
}

