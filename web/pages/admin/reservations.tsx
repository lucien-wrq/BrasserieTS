import React, { useEffect, useState } from "react";
import Header from "../../components/Header";

export default function ReservationsClient() {
  const [reservations, setReservations] = useState([]);
  const [detailsReservations, setDetailsReservations] = useState([]);
  const [produits, setProduits] = useState<Record<number, { nom: string; prix: number }>>({});
  const [utilisateurs, setUtilisateurs] = useState<Record<number, { nom: string; prenom: string }>>({});

  useEffect(() => {
    const fetchReservations = async () => {
      const token = localStorage.getItem("jwtToken"); // Récupérer le token JWT

      if (!token) {
        console.error("Token JWT manquant.");
        return;
      }

      try {
        const response = await fetch("/api/reservations", {
          headers: {
            Authorization: `Bearer ${token}`, // Ajouter le token JWT dans l'en-tête
          },
        });

        if (!response.ok) {
          throw new Error("Erreur lors du chargement des réservations.");
        }

        const data = await response.json();
        setReservations(data); // Charger les réservations
      } catch (error) {
        console.error("Erreur lors du chargement des réservations :", error);
      }
    };

    fetchReservations();
  }, []);

  useEffect(() => {
    const fetchDetailsReservations = async () => {
      const token = localStorage.getItem("jwtToken");

      if (!token) {
        console.error("Token JWT manquant.");
        return;
      }

      try {
        const response = await fetch("/api/details-reservations", {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (!response.ok) {
          throw new Error("Erreur lors du chargement des détails des réservations.");
        }

        const data = await response.json();
        setDetailsReservations(data);
      } catch (error) {
        console.error("Erreur lors du chargement des détails des réservations :", error);
      }
    };

    fetchDetailsReservations();
  }, []);

  useEffect(() => {
    // Charger les produits
    const fetchProduits = async () => {
      const produitsMap: any = {};
      const uniqueProduitIds = new Set(
        detailsReservations.map((detail: any) => detail.produit.id)
      );

      for (const produitId of uniqueProduitIds) {
        const response = await fetch(`/api/produits/${produitId}`);
        const produit = await response.json();
        produitsMap[produitId] = produit;
      }

      console.log("Données des produits :", produitsMap);
      setProduits(produitsMap);
    };

    if (detailsReservations.length > 0) {
      fetchProduits();
    }
  }, [detailsReservations]);

  useEffect(() => {
    // Charger les utilisateurs
    const fetchUtilisateurs = async () => {
      const utilisateursMap: any = {};
      const uniqueUtilisateurIds = new Set(
        reservations.map((reservation: any) => reservation.utilisateur.id)
      );

      for (const utilisateurId of uniqueUtilisateurIds) {
        const response = await fetch(`/api/utilisateurs/${utilisateurId}`);
        const utilisateur = await response.json();
        utilisateursMap[utilisateurId] = utilisateur;
      }

      console.log("Données des utilisateurs :", utilisateursMap);
      setUtilisateurs(utilisateursMap);
    };

    if (reservations.length > 0) {
      fetchUtilisateurs();
    }
  }, [reservations]);

  const handleMettreEnAttente = async (id: number) => {
    try {
      const response = await fetch(`/api/reservations/${id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ etat: "En attente" }), // Envoi de l'état "En attente"
      });

      if (!response.ok) {
        const errorData = await response.json();
        alert(`Erreur : ${errorData.error || "Impossible de mettre à jour la réservation."}`);
        return;
      }

      alert(`La réservation avec l'ID ${id} a été mise en attente avec succès.`);
      // Recharger les réservations pour refléter les modifications
      fetch("/api/reservations")
        .then((res) => res.json())
        .then((data) => {
          setReservations(data);
        });
    } catch (error) {
      console.error("Erreur lors de la mise en attente de la réservation :", error);
      alert("Une erreur est survenue. Veuillez réessayer.");
    }
  };

  const handleCancel = async (id: number) => {
    if (!window.confirm(`Êtes-vous sûr de vouloir supprimer cette réservation ?`)) {
      return; // Annule l'action si l'utilisateur clique sur "Annuler"
    }

    try {
      const response = await fetch(`/api/reservations/${id}`, {
        method: "DELETE",
      });

      if (!response.ok) {
        const errorData = await response.json();
        alert(`Erreur : ${errorData.error || "Impossible de supprimer la réservation."}`);
        return;
      }

      alert(`La réservation avec l'ID ${id} a été supprimée avec succès.`);
      // Recharger les réservations pour refléter les modifications
      fetch("/api/reservations")
        .then((res) => res.json())
        .then((data) => {
          setReservations(data);
        });
    } catch (error) {
      console.error("Erreur lors de la suppression de la réservation :", error);
      alert("Une erreur est survenue. Veuillez réessayer.");
    }
  };

  const handleConfirmer = async (id: number) => {
    try {
      const response = await fetch(`/api/reservations/${id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ etat: "Confirmée" }), // Envoi de l'état "En attente"
      });

      if (!response.ok) {
        const errorData = await response.json();
        alert(`Erreur : ${errorData.error || "Impossible de mettre à jour la réservation."}`);
        return;
      }

      alert(`La réservation avec l'ID ${id} a été Confirmée avec succès.`);
      // Recharger les réservations pour refléter les modifications
      fetch("/api/reservations")
        .then((res) => res.json())
        .then((data) => {
          setReservations(data);
        });
    } catch (error) {
      console.error("Erreur lors de la mise en attente de la réservation :", error);
      alert("Une erreur est survenue. Veuillez réessayer.");
    }
  };

  const handleAnnuler = async (id: number) => {
    try {
      const response = await fetch(`/api/reservations/${id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ etat: "Annulée" }), // Envoi de l'état "En attente"
      });

      if (!response.ok) {
        const errorData = await response.json();
        alert(`Erreur : ${errorData.error || "Impossible de mettre à jour la réservation."}`);
        return;
      }

      alert(`La réservation avec l'ID ${id} a été Annulée avec succès.`);
      // Recharger les réservations pour refléter les modifications
      fetch("/api/reservations")
        .then((res) => res.json())
        .then((data) => {
          setReservations(data);
        });
    } catch (error) {
      console.error("Erreur lors de la mise en attente de la réservation :", error);
      alert("Une erreur est survenue. Veuillez réessayer.");
    }
  };

  const calculateTotalPrice = (reservationId: number) => {
    const details = detailsReservations.filter(
      (detail: any) => detail.reservation.id === reservationId
    );
    return details.reduce((total: number, detail: any) => {
      const produit = produits[detail.produit.id as number];
      return total + (produit?.prix || 0) * detail.quantite;
    }, 0).toFixed(2);
  };

  const formatDateTime = (dateTime: string) => {
    const date = new Date(dateTime);
    return `${date.toLocaleDateString("fr-FR")} à ${date.toLocaleTimeString("fr-FR", {
      hour: "2-digit",
      minute: "2-digit",
    })}`;
  };

  // Filtrer les réservations confirmées
  const confirmedReservations = reservations.filter(
    (reservation: any) => reservation.status?.etat === "Confirmée"
  );

  // Filtrer les autres réservations
  const otherReservations = reservations.filter(
    (reservation: any) => reservation.status?.etat !== "Confirmée"
  );

  return (
    <div className="container">
      <link
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
        rel="stylesheet"
      ></link>
      {/* Header */}
      <Header />

      {/* Contenu principal */}
      <main className="my-5">
        <h1 className="text-center mb-4">Liste des réservations</h1>

        <div style={{ marginBottom: "50px" }}></div>

        {/* Tableau des réservations confirmées */}
        <h3 className="text-center mb-4">Réservations Confirmées</h3>
        <table className="table table-striped">
          <thead className="table-dark">
            <tr>
              <th className="text-center">Utilisateur</th>
              <th>Date</th>
              <th>Produits</th>
              <th className="text-center">Quantité</th>
              <th className="text-center">Prix total</th>
            </tr>
          </thead>
          <tbody>
            {confirmedReservations.map((reservation: any) => (
              <tr key={reservation.id}>
                <td className="text-center">
                  {utilisateurs[reservation.utilisateur.id]?.nom || "Chargement..."}{" "}
                  {utilisateurs[reservation.utilisateur.id]?.prenom || ""}
                </td>
                <td>{formatDateTime(reservation.date)}</td>
                <td>
                  <ul>
                    {detailsReservations
                      .filter(
                        (detail: any) => detail.reservation.id === reservation.id
                      )
                      .map((detail: any) => {
                        const produit = produits[detail.produit.id];
                        return (
                          <li key={detail.id}>
                            Produit : {produit?.nom || "Chargement..."} - Prix :{" "}
                            {produit?.prix || "N/A"} € - Quantité : {detail.quantite}
                          </li>
                        );
                      })}
                  </ul>
                </td>
                <td className="text-center">
                  {detailsReservations
                    .filter(
                      (detail: any) => detail.reservation.id === reservation.id
                    )
                    .reduce((total: number, detail: any) => total + detail.quantite, 0)}
                </td>
                <td className="text-center">{calculateTotalPrice(reservation.id)} €</td>
              </tr>
            ))}
          </tbody>
        </table>

        <div style={{ marginBottom: "50px" }}></div>

        {/* Tableau des autres réservations */}
        <h3 className="text-center mb-4">Autres Réservations</h3>
        <table className="table table-striped">
          <thead className="table-dark">
            <tr>
              <th className="text-center">Utilisateur</th>
              <th>Date</th>
              <th>Produits</th>
              <th className="text-center">Quantité</th>
              <th className="text-center">Prix total</th>
              <th className="text-center">Statut</th>
              <th className="text-center">Actions</th>
            </tr>
          </thead>
          <tbody>
            {otherReservations.map((reservation: any) => (
              <tr key={reservation.id}>
                <td className="text-center">
                  {utilisateurs[reservation.utilisateur.id]?.nom || "Chargement..."}{" "}
                  {utilisateurs[reservation.utilisateur.id]?.prenom || ""}
                </td>
                <td>{formatDateTime(reservation.date)}</td>
                <td>
                  <ul>
                    {detailsReservations
                      .filter(
                        (detail: any) => detail.reservation.id === reservation.id
                      )
                      .map((detail: any) => {
                        const produit = produits[detail.produit.id];
                        return (
                          <li key={detail.id}>
                            Produit : {produit?.nom || "Chargement..."} - Prix :{" "}
                            {produit?.prix || "N/A"} € - Quantité : {detail.quantite}
                          </li>
                        );
                      })}
                  </ul>
                </td>
                <td className="text-center">
                  {detailsReservations
                    .filter(
                      (detail: any) => detail.reservation.id === reservation.id
                    )
                    .reduce((total: number, detail: any) => total + detail.quantite, 0)}
                </td>
                <td className="text-center">{calculateTotalPrice(reservation.id)} €</td>
                <td className="text-center">{reservation.status?.etat || "Chargement..."}</td>
                <td className="text-center">
                  <button
                    className="btn btn-warning btn-sm me-2"
                    onClick={() => handleMettreEnAttente(reservation.id)}
                    title="Mettre en attente"
                  >
                    <i className="fas fa-clock"></i>
                  </button>
                  <button
                    className="btn btn-primary btn-sm me-2"
                    onClick={() => handleConfirmer(reservation.id)}
                    title="Valider"
                  >
                    <i className="fas fa-check"></i>
                  </button>
                  <button
                    className="btn btn-danger btn-sm me-2"
                    onClick={() => handleAnnuler(reservation.id)}
                    title="Annuler"
                  >
                    <i className="fas fa-ban"></i>
                  </button>
                  {new Date().getTime() - new Date(reservation.date).getTime() > 15 * 24 * 60 * 60 * 1000 && (
                    <button
                      className="btn btn-danger btn-sm me-2"
                      onClick={() => handleCancel(reservation.id)}
                      title="Supprimer"
                    >
                      <i className="fas fa-trash"></i>
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </main>
    </div>
  );
}