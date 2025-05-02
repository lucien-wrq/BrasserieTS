import { useEffect, useState } from "react";
import Header from "../../components/Header";
import { useRouter } from "next/router";
import { apiClient } from "../../utils/apiClient"; // Import de la fonction utilitaire

export default function GestionClients() {
  const [clients, setClients] = useState([]);
  const router = useRouter();

  useEffect(() => {
    const fetchUtilisateurs = async () => {
      try {
        const data = await apiClient("/api/utilisateurs"); // Utilisation de apiClient
        setClients(data); // Charger les utilisateurs
      } catch (error) {
        console.error("Erreur lors de la récupération des utilisateurs :", error);
      }
    };

    fetchUtilisateurs();
  }, []);

  const handleAdd = () => {
    router.push("/admin/AjoutUtilisateurs");
  };

  const handleEdit = (id: number) => {
    router.push(`/admin/ModifierUtilisateurs?id=${id}`);
  };

  const handleDelete = async (id: number) => {
    if (confirm("Êtes-vous sûr de vouloir supprimer cet utilisateur ?")) {
      try {
        await apiClient(`/api/utilisateurs/${id}`, {
          method: "DELETE",
        });

        alert("Utilisateur supprimé avec succès !");
        const data = await apiClient("/api/utilisateurs"); // Rafraîchit la liste des utilisateurs
        setClients(data);
      } catch (error) {
        console.error("Erreur lors de la suppression de l'utilisateur :", error);
        alert("Une erreur est survenue lors de la suppression de l'utilisateur.");
      }
    }
  };

  const handleReset = async (id: number, nom: string, prenom: string) => {
    if (confirm("Êtes-vous sûr de vouloir réinitialiser le mot de passe de cet utilisateur ?")) {
      try {
        const newPassword = `BrasserieTS.${nom}.${prenom}`;
        await apiClient(`/api/utilisateurs/${id}`, {
          method: "PUT",
          body: JSON.stringify({ mdp: newPassword }),
        });

        alert("Mot de passe réinitialisé avec succès !");
      } catch (error) {
        console.error("Erreur lors de la réinitialisation du mot de passe :", error);
        alert("Une erreur est survenue lors de la réinitialisation du mot de passe.");
      }
    }
  };

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
        <h1 className="text-center mb-4">Gestion des Utilisateurs</h1>
        <button className="btn btn-primary mb-3" onClick={handleAdd}>
          Ajouter un client
        </button>
        <table className="table table-striped">
          <thead className="table-dark">
            <tr>
              <th className="text-center">Nom</th>
              <th className="text-center">Prénom</th>
              <th>Email</th>
              <th className="text-center">Rôle</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {clients.map((client: any) => (
              <tr key={client.id}>
                <td className="text-center">{client.nom}</td>
                <td className="text-center">{client.prenom}</td>
                <td>{client.email}</td>
                <td className="text-center">
                  {client.roles?.includes("ROLE_ADMIN") ? "Administrateur" : "Client"}
                </td>
                <td>
                  <button
                    className="btn btn-warning btn-sm me-2"
                    onClick={() => handleEdit(client.id)}
                    title="Modifier l'utilisateur"
                  >
                    <i className="fas fa-edit"></i>
                  </button>
                  <button
                    className="btn btn-primary btn-sm me-2"
                    onClick={() => handleReset(client.id, client.nom, client.prenom)}
                    title="Reset le mot de passe"
                  >
                    <i className="fas fa-key"></i>
                  </button>
                  <button
                    className="btn btn-danger btn-sm me-2"
                    onClick={() => handleDelete(client.id)}
                    title="Supprimer l'utilisateur"
                  >
                    <i className="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </main>
    </div>
  );
}