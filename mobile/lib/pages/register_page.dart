import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _register() async {
    final nom = _nomController.text;
    final prenom = _prenomController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    // Validation des champs
    if (nom.isEmpty || prenom.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Tous les champs doivent être remplis.";
      });
      return;
    }

    // Préparation des données pour l'API
    final payload = {
      "nom": nom,
      "prenom": prenom,
      "email": email,
      "password": password, 
    };

    try {
      final response = await AuthService().register(payload);

      if (response) {
        // Succès : Rediriger vers la page de connexion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Compte créé avec succès !")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _errorMessage = "Une erreur est survenue lors de l'inscription.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur : ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Créer un compte"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/brasserie_logo.png',
                  height: 150,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Inscription",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 10),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 20),
              TextField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: "Nom",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _prenomController,
                decoration: InputDecoration(
                  labelText: "Prénom",
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _register,
                child: Text("Créer un compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}