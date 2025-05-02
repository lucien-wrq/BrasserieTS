import { useState } from "react";
import { useRouter } from "next/router";
import Header from "../../components/Header";
import { apiClient } from "../../utils/apiClient"; // Import de la fonction utilitaire

export default function AjoutUtilisateurs() {
  const [newClient, setNewClient] = useState<{
    nom: string;
    prenom: string;
    email: string;
    mdp: string;
    roles: string[];
  }>({
    nom: "",
    prenom: "",
    email: "",
    mdp: "",
    roles: [], // Les rôles sont maintenant un tableau
  });

  const [error, setError] = useState<string | null>(null); // Stocke les erreurs
  const router = useRouter();

  // Liste statique des rôles
  const rolesDisponibles = ["ROLE_USER", "ROLE_ADMIN"];

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target as HTMLInputElement;
    const checked = (e.target as HTMLInputElement).checked;

    // Gestion des rôles (multi-sélection)
    if (name === "roles") {
      const selectedRoles = Array.from(
        (e.target as HTMLSelectElement).selectedOptions,
        (option) => option.value
      );
      setNewClient((prev) => ({
        ...prev,
        roles: selectedRoles,
      }));
    } else {
      setNewClient((prev) => ({
        ...prev,
        [name]: type === "checkbox" ? checked : value,
      }));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!newClient.nom || !newClient.prenom || !newClient.email || !newClient.mdp || newClient.roles.length === 0) {
      setError("Tous les champs doivent être remplis.");
      return;
    }

    const payload = {
      nom: newClient.nom,
      prenom: newClient.prenom,
      email: newClient.email,
      password: newClient.mdp, // Changez "mdp" en "password"
      role: newClient.roles[0], // Envoyez uniquement le premier rôle (l'API attend un seul rôle)
    };

    console.log("Données envoyées :", payload); // Log des données envoyées

    try {
      await apiClient("/api/utilisateurs", {
        method: "POST",
        body: JSON.stringify(payload),
      });

      alert("Utilisateur ajouté avec succès !");
      router.push("/admin/clients");
    } catch (err) {
      console.error("Erreur lors de l'ajout de l'utilisateur :", err);
      setError("Une erreur est survenue lors de l'ajout de l'utilisateur.");
    }
  };

  const handleRetour = () => {
    router.push("/admin/clients"); // Redirection vers la page clients
  };

  return (
    <div className="container">
      {/* Header */}
      <Header />

      {/* Contenu principal */}
      <main className="my-5">
        <h1 className="text-center mb-4">Ajouter un utilisateur</h1>

        <div className="card p-4" style={{ transform: "none" }}>
          {error && <p className="text-danger">{error}</p>} {/* Affiche les erreurs */}
          <form onSubmit={handleSubmit}>
            <div className="mb-3">
              <label htmlFor="nom" className="form-label">
                Nom
              </label>
              <input
                type="text"
                id="nom"
                name="nom"
                className="form-control"
                value={newClient.nom}
                onChange={handleChange}
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="prenom" className="form-label">
                Prénom
              </label>
              <input
                type="text"
                id="prenom"
                name="prenom"
                className="form-control"
                value={newClient.prenom}
                onChange={handleChange}
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="email" className="form-label">
                Email
              </label>
              <input
                type="email"
                id="email"
                name="email"
                className="form-control"
                value={newClient.email}
                onChange={handleChange}
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="mdp" className="form-label">
                Mot de passe
              </label>
              <input
                type="password"
                id="mdp"
                name="mdp"
                className="form-control"
                value={newClient.mdp}
                onChange={handleChange}
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="roles" className="form-label">
                Rôle
              </label>
              <select
                id="roles"
                name="roles"
                className="form-select"
                value={newClient.roles[0] || ""} // Sélectionne le premier rôle ou une valeur vide
                onChange={(e) =>
                  setNewClient((prev) => ({
                    ...prev,
                    roles: [e.target.value], // Met à jour le tableau avec un seul rôle
                  }))
                }
                required
              >
                <option value="" disabled>
                  Sélectionnez un rôle
                </option>
                {rolesDisponibles.map((role, index) => (
                  <option key={index} value={role}>
                    {role === "ROLE_USER" ? "Utilisateur" : "Administrateur"}
                  </option>
                ))}
              </select>
            </div>
            <button type="submit" className="btn btn-primary mb-3">
              Ajouter l'utilisateur
            </button>
            <button type="button" className="btn btn-secondary mb-3 mx-2" onClick={handleRetour}>
              Retour
            </button>
          </form>
        </div>
      </main>
    </div>
  );
}