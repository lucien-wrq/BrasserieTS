import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

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

  List<Map<String, dynamic>> _reservations = [];

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
      _fetchUserReservations();
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

  Future<void> _fetchUserReservations() async {
    final userId = await _userService.getUserId();
    if (userId == null) {
      setState(() {
        _errorMessage = "Impossible de récupérer l'ID de l'utilisateur.";
      });
      return;
    }

    try {
      final reservations = await _userService.fetchUserReservations(userId);

      setState(() {
        _reservations = reservations;
      });

      // Charger les détails des réservations
      await _fetchReservationDetails();
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur : ${e.toString()}";
      });
    }
  }

  Future<void> _fetchReservationDetails() async {
    try {
      for (var reservation in _reservations) {
        final reservationId = reservation['id'];

        // Récupérer les détails de la réservation
        final details = await _userService.fetchReservationDetails(reservationId);

        // Ajouter les informations des produits
        for (var detail in details) {
          final productId = detail['produit']['id'];
          final product = await _userService.fetchProductDetails(productId);

          // Calculer le prix total pour ce produit
          final totalPrice = product['prix'] * detail['quantite'];

          // Ajouter les informations enrichies à la réservation
          detail['produit']['nom'] = product['nom'];
          detail['produit']['prix'] = product['prix'];
          detail['totalPrice'] = totalPrice;
        }

        // Ajouter les détails enrichis à la réservation
        reservation['details'] = details;
      }

      setState(() {
        _reservations = _reservations; // Mettre à jour l'état
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur : ${e.toString()}";
      });
    }
  }

  Future<void> _deleteReservation(String reservationId, List<Map<String, dynamic>> details) async {
    print("Appel de _deleteReservation avec reservationId : $reservationId");

    try {
      // Réajuster le stock des produits
      for (var detail in details) {
        final productId = detail['produit']['id'];
        final quantity = detail['quantite'];
        print("Incrémentation du stock pour le produit $productId avec quantité $quantity");
        await _userService.incrementStock(productId, quantity);
      }

      // Supprimer la réservation
      print("Suppression de la réservation avec ID : $reservationId");
      await _userService.deleteReservation(reservationId);

      // Actualiser les réservations
      await _fetchUserReservations();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Réservation supprimée avec succès.")),
      );
    } catch (e) {
      print("Erreur dans _deleteReservation : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
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
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Informations utilisateur
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
                    SizedBox(height: 30),
                    if (_isEditing)
                      ElevatedButton(
                        onPressed: _updateUserData,
                        child: Text("Enregistrer les modifications"),
                      ),
                    SizedBox(height: 20),
                    // Liste des réservations
                    Text(
                      "Mes Réservations",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ..._reservations.map((reservation) {
                      final details = reservation['details'] ?? [];
                      
                      // Calculer le prix total de la commande
                      final totalPrice = details.fold<double>(
                        0.0,
                        (double sum, dynamic detail) => sum + (detail['totalPrice']?.toDouble() ?? 0.0),
                      );

                      // Formater la date
                      final formattedDate = DateTime.parse(reservation['date']);
                      final formattedDateString =
                          "${formattedDate.day.toString().padLeft(2, '0')}-${formattedDate.month.toString().padLeft(2, '0')}-${formattedDate.year}";

                      // Récupérer le statut de la commande
                      final status = reservation['status']['etat'] ?? "Inconnu";

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ExpansionTile(
                          title: Text("Réservation"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Date : $formattedDateString"),
                              Text("Statut : $status"),
                              Text(
                                "Prix total : ${totalPrice.toStringAsFixed(2)} €",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          children: [
                            ...details.map<Widget>((detail) {
                              final product = detail['produit'];
                              return ListTile(
                                title: Text(product['nom']),
                                subtitle: Text("Quantité : ${detail['quantite']}"),
                                trailing: Text(
                                  "${(detail['totalPrice']?.toDouble() ?? 0.0).toStringAsFixed(2)} €",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            if (status == "En attente")
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Confirmation"),
                                          content: Text("Êtes-vous sûr de vouloir supprimer cette réservation ?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false), // Annuler
                                              child: Text("Non"),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true), // Confirmer
                                              child: Text("Oui"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm == true) {
                                      _deleteReservation(reservation['id'].toString(), details);
                                    }
                                  },
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  label: Text("Supprimer la réservation"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text("Se déconnecter"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}