import { useState, useEffect } from "react";
import { useRouter } from "next/router";
import Header from "../../components/Header";
import { apiClient } from "../../utils/apiClient"; // Import de la fonction utilitaire

export default function ModifierUtilisateurs() {
  const [utilisateur, setUtilisateur] = useState({
    nom: "",
    prenom: "",
    email: "",
    role: "", // Le rôle est maintenant une chaîne unique
  });

  const [error, setError] = useState("");
  const router = useRouter();
  const { id } = router.query; // Récupère l'ID de l'utilisateur depuis l'URL

  useEffect(() => {
    // Récupérer les données de l'utilisateur à modifier
    const fetchUtilisateur = async () => {
      if (!id) return;
      try {
        const data = await apiClient(`/api/utilisateurs/${id}`); // Utilisation de apiClient
        setUtilisateur({
          nom: data.nom,
          prenom: data.prenom,
          email: data.email,
          role: data.roles[0] || "ROLE_USER", // Assurez-vous de prendre le premier rôle ou un rôle par défaut
        });
      } catch (err) {
        console.error(err);
        setError("Impossible de charger les données de l'utilisateur.");
      }
    };

    fetchUtilisateur();
  }, [id]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setUtilisateur((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validation des champs
    if (!utilisateur.nom || !utilisateur.email || !utilisateur.role) {
      setError("Tous les champs doivent être remplis.");
      return;
    }

    const payload = {
      nom: utilisateur.nom,
      prenom: utilisateur.prenom,
      email: utilisateur.email,
      roles: [utilisateur.role], // Envoyer le rôle sous forme de tableau
    };

    try {
      await apiClient(`/api/utilisateurs/${id}`, {
        method: "PUT", // Utilisation de la méthode PUT pour la modification
        body: JSON.stringify(payload),
      });

      alert("Utilisateur modifié avec succès !");
      router.push("/admin/clients");
    } catch (err) {
      console.error(err);
      setError("Une erreur est survenue lors de la modification de l'utilisateur.");
    }
  };

  const handleRetour = () => {
    router.push("/admin/clients");
  };

  return (
    <div className="container">
      {/* Header */}
      <Header />

      {/* Contenu principal */}
      <main className="my-5">
        <h1 className="text-center mb-4">Modifier un utilisateur</h1>
        <div className="card p-4" style={{ transform: "none" }}>
          {error && <p className="text-danger">{error}</p>}
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
                value={utilisateur.nom}
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
                value={utilisateur.prenom}
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
                value={utilisateur.email}
                onChange={handleChange}
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="role" className="form-label">
                Rôle
              </label>
              <select
                id="role"
                name="role"
                className="form-select"
                value={utilisateur.role}
                onChange={handleChange}
                required
              >
                <option value="ROLE_USER">Utilisateur</option>
                <option value="ROLE_ADMIN">Administrateur</option>
              </select>
            </div>
            <button type="submit" className="btn btn-primary mb-3">
              Modifier l'utilisateur
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
