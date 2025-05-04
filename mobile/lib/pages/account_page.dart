import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); 
  bool _isEditing = false;
  String? _userId; 
  String? _errorMessage;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId'); 
    if (userId != null) {
      setState(() {
        _userId = userId;
      });
      _fetchUserData(userId);
    } else {
      setState(() {
        _errorMessage = "Impossible de récupérer l'ID utilisateur.";
      });
    }
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      final data = await _userService.fetchUserData(userId);
      setState(() {
        _nomController.text = data['nom'] ?? '';
        _prenomController.text = data['prenom'] ?? '';
        _emailController.text = data['email'] ?? '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur : ${e.toString()}";
      });
    }
  }

  Future<void> _updateUserData() async {
    if (_userId == null) return;

    final payload = {
      "nom": _nomController.text,
      "prenom": _prenomController.text,
      "email": _emailController.text,
    };

    if (_passwordController.text.isNotEmpty) {
      payload["mdp"] = _passwordController.text;
    }

    try {
      await _userService.updateUserData(_userId!, payload);
      setState(() {
        _isEditing = false;
        _passwordController.clear(); // Réinitialiser le champ mot de passe
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Informations mises à jour avec succès !")),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur : ${e.toString()}";
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprimer les données utilisateur
    Navigator.pushReplacementNamed(context, '/login'); // Rediriger vers la page de connexion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mon Compte"),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _errorMessage != null
            ? Center(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      labelText: "Nom",
                      prefixIcon: Icon(Icons.person),
                      enabled: _isEditing,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _prenomController,
                    decoration: InputDecoration(
                      labelText: "Prénom",
                      prefixIcon: Icon(Icons.person_outline),
                      enabled: _isEditing,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      enabled: _isEditing,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_isEditing)
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "Nouveau mot de passe",
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                  SizedBox(height: 30),
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: _updateUserData,
                      child: Text("Enregistrer les modifications"),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text("Se déconnecter"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}