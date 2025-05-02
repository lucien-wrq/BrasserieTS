import { useState, useEffect } from "react";
import { useRouter } from "next/router";
import Header from "../../components/Header";

export default function ModifierUtilisateurs() {
  const [utilisateur, setUtilisateur] = useState({
    nom: "",
    prenom: "",
    email: "",
    administrateur: false, // Par défaut, utilisateur n'est pas admin
  });

  const [error, setError] = useState("");
  const router = useRouter();
  const { id } = router.query; // Récupère l'ID de l'utilisateur depuis l'URL

  useEffect(() => {
    // Récupérer les données de l'utilisateur à modifier
    const fetchUtilisateur = async () => {
      if (!id) return;
      try {
        const response = await fetch(`/api/utilisateurs/${id}`);
        if (!response.ok) {
          throw new Error("Erreur lors de la récupération de l'utilisateur.");
        }
        const data = await response.json();
        setUtilisateur({
          nom: data.nom,
          prenom: data.prenom,
          email: data.email,
          administrateur: data.administrateur,
        });
      } catch (err) {
        console.error(err);
        setError("Impossible de charger les données de l'utilisateur.");
      }
    };

    fetchUtilisateur();
  }, [id]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target as HTMLInputElement;
    const checked = (e.target as HTMLInputElement).checked;
    setUtilisateur((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleRoleChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const value = e.target.value === "admin";
    setUtilisateur((prev) => ({
      ...prev,
      administrateur: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validation des champs
    if (!utilisateur.nom || !utilisateur.email) {
      setError("Tous les champs doivent être remplis.");
      return;
    }

    try {
      const response = await fetch(`/api/utilisateurs/${id}`, {
        method: "PUT", // Utilisation de la méthode PUT pour la modification
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(utilisateur),
      });

      if (!response.ok) {
        throw new Error("Erreur lors de la modification de l'utilisateur.");
      }

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
                value={utilisateur.administrateur ? "admin" : "utilisateur"}
                onChange={handleRoleChange}
                required
              >
                <option value="utilisateur">Utilisateur</option>
                <option value="admin">Admin</option>
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
