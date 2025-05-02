import { useState, useEffect } from "react";
import { useRouter } from "next/router";
import Header from "../../components/Header";

export default function AjoutUtilisateurs() {
  const [newClient, setNewClient] = useState({
    nom: "",
    prenom: "",
    email: "",
    mdp: "",
    roleId: "", // Ajout du champ pour le rôle
  });

  const [roles, setRoles] = useState<{ id: number; role: string }[]>([]); // Stocke les rôles disponibles
  const [error, setError] = useState<string | null>(null); // Stocke les erreurs
  const router = useRouter();

  // Récupération des rôles depuis l'API
  useEffect(() => {
    const fetchRoles = async () => {
      try {
        const response = await fetch("/api/roles");
        if (!response.ok) {
          throw new Error("Erreur lors de la récupération des rôles.");
        }
        const data = await response.json();
        setRoles(data);
      } catch (err) {
        console.error(err);
        setError("Impossible de charger les rôles.");
      }
    };

    fetchRoles();
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target as HTMLInputElement;
    const checked = (e.target as HTMLInputElement).checked;
    setNewClient((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validation des champs côté client
    if (!newClient.nom || !newClient.prenom || !newClient.email || !newClient.mdp || !newClient.roleId) {
      setError("Tous les champs doivent être remplis.");
      return;
    }

    // Vérification que roleId correspond à un ID valide
    const isValidRoleId = roles.some((role) => role.id.toString() === newClient.roleId);
    if (!isValidRoleId) {
      setError("Le rôle sélectionné est invalide.");
      return;
    }

    // Préparation des données pour correspondre au format attendu par l'API
    const payload = {
      nom: newClient.nom,
      prenom: newClient.prenom,
      email: newClient.email,
      mdp: newClient.mdp,
      role_id: parseInt(newClient.roleId, 10), // Transforme roleId en role_id (nombre)
    };

    try {
      const response = await fetch("/api/utilisateurs", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorData = await response.json();
        if (errorData.errors) {
          setError(errorData.errors.join(", ")); // Affiche tous les messages d'erreur
        } else {
          setError("Une erreur est survenue.");
        }
        return;
      }

      alert("Utilisateur ajouté avec succès !");
      router.push("/admin/clients"); // Redirection vers la page clients
    } catch (err) {
      console.error(err);
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
              <label htmlFor="roleId" className="form-label">
                Rôle
              </label>
              <select
                id="roleId"
                name="roleId"
                className="form-select"
                value={newClient.roleId}
                onChange={handleChange}
                required
              >
                <option value="">-- Sélectionnez un rôle --</option>
                {roles.map((role) => (
                  <option key={role.id} value={role.id}>
                    {role.role}
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