import { useState, useEffect } from "react";
import { useRouter } from "next/router";
import Header from "../../components/Header";

export default function ModifierProduits() {
  const [produit, setProduit] = useState({
    nom: "",
    prix: "",
    quantite: "",
  });

  const [error, setError] = useState("");
  const router = useRouter();
  const { id } = router.query; // Récupère l'ID du produit depuis l'URL

  useEffect(() => {
    // Récupérer les données du produit à modifier
    const fetchProduit = async () => {
      if (!id) return;
      try {
        const response = await fetch(`/api/produits/${id}`);
        if (!response.ok) {
          throw new Error("Erreur lors de la récupération du produit.");
        }
        const data = await response.json();
        setProduit({
          nom: data.nom,
          prix: data.prix.toString(),
          quantite: data.quantite.toString(),
        });
      } catch (err) {
        console.error(err);
        setError("Impossible de charger les données du produit.");
      }
    };

    fetchProduit();
  }, [id]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target as HTMLInputElement;
    const checked = (e.target as HTMLInputElement).checked;
    setProduit((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validation des champs
    if (!produit.nom || !produit.prix || !produit.quantite) {
      setError("Tous les champs doivent être remplis.");
      return;
    }

    try {
      const response = await fetch(`/api/produits/${id}`, {
        method: "PUT", // Utilisation de la méthode PUT pour la modification
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          nom: produit.nom,
          prix: parseFloat(produit.prix),
          quantite: parseInt(produit.quantite, 10),
        }),
      });

      if (!response.ok) {
        throw new Error("Erreur lors de la modification du produit.");
      }

      alert("Produit modifié avec succès !");
      router.push("/admin/produits");
    } catch (err) {
      console.error(err);
      setError("Une erreur est survenue lors de la modification du produit.");
    }
  };

  const handleRetour = () => {
    router.push("/admin/produits");
  };

  return (
    <div className="container">
      {/* Header */}
      <Header />

      {/* Contenu principal */}
      <main className="my-5">
        <h1 className="text-center mb-4">Modifier un produit</h1>
        <div className="card p-4" style={{ transform: "none" }}>
          {error && <p className="text-danger">{error}</p>}
          <form onSubmit={handleSubmit}>
            <div className="mb-3">
              <label htmlFor="nom" className="form-label">
                Nom du produit
              </label>
              <input
                type="text"
                id="nom"
                name="nom"
                className="form-control"
                value={produit.nom}
                onChange={handleChange}
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="prix" className="form-label">
                Prix
              </label>
              <input
                type="number"
                id="prix"
                name="prix"
                className="form-control"
                value={produit.prix}
                onChange={handleChange}
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="quantite" className="form-label">
                Quantité
              </label>
              <input
                type="number"
                id="quantite"
                name="quantite"
                className="form-control"
                value={produit.quantite}
                onChange={handleChange}
                required
              />
            </div>
            <button type="submit" className="btn btn-primary mb-3">
              Modifier le produit
            </button>
            <button type="button" className="btn btn-primary mb-3 mx-2" onClick={handleRetour}>
              Retour
            </button>
          </form>
        </div>
      </main>
    </div>
  );
}