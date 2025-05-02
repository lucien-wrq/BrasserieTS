import { useState } from "react";
import { useRouter } from "next/router";
import Header from "../../components/Header";

export default function AjoutProduits() {
  const [newProduit, setNewProduit] = useState({
    nom: "",
    description: "",
    prix: "",
    quantite: "",
    disponible: true, // Valeur par défaut
  });
  const [image, setImage] = useState<File | null>(null); // État pour le fichier image
  const [error, setError] = useState("");
  const router = useRouter();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value, type } = e.target as HTMLInputElement;
    const checked = (e.target as HTMLInputElement).checked;

    if (name === "image") {
      const file = (e.target as HTMLInputElement).files?.[0] || null;
      if (file && !file.type.startsWith("image/")) {
        alert("Veuillez sélectionner un fichier image valide.");
        return;
      }
      setImage(file); // Stocke le fichier sélectionné
    } else {
      setNewProduit((prev) => ({
        ...prev,
        [name]: type === "checkbox" ? checked : value,
      }));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validation des champs
    if (!newProduit.nom || !newProduit.prix || !newProduit.quantite || !image) {
      setError("Tous les champs doivent être remplis.");
      return;
    }

    try {
      // Envoi des données du produit
      const produitResponse = await fetch("/api/produits", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          nom: newProduit.nom,
          description: newProduit.description,
          prix: parseFloat(newProduit.prix),
          quantite: parseInt(newProduit.quantite, 10),
          disponible: newProduit.disponible,
        }),
      });

      if (!produitResponse.ok) {
        throw new Error("Erreur lors de l'ajout du produit.");
      }

      const produitData = await produitResponse.json();

      // Envoi de l'image
      const formData = new FormData();
      formData.append("fichier", image);

      const imageResponse = await fetch(`/api/produits/${produitData.id}/upload-image`, {
        method: "POST",
        body: formData,
      });

      if (!imageResponse.ok) {
        throw new Error("Erreur lors de l'upload de l'image.");
      }

      alert("Produit ajouté avec succès !");
      router.push("/admin/produits");
    } catch (err) {
      console.error(err);
      setError("Une erreur est survenue lors de l'ajout du produit.");
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
        <h1 className="text-center mb-4">Ajouter un produit</h1>

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
                value={newProduit.nom}
                onChange={handleChange}
                required
              />
            </div>
            <div className="mb-3">
              <label htmlFor="description" className="form-label">
                Description
              </label>
              <textarea
                id="description"
                name="description"
                className="form-control"
                value={newProduit.description}
                onChange={handleChange}
                required
              ></textarea>
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
                value={newProduit.prix}
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
                value={newProduit.quantite}
                onChange={handleChange}
                required
              />
            </div>
            <div className="mb-3 form-check">
              <input
                type="checkbox"
                id="disponible"
                name="disponible"
                className="form-check-input"
                checked={newProduit.disponible}
                onChange={handleChange}
              />
              <label htmlFor="disponible" className="form-check-label">
                Disponible
              </label>
            </div>
            <div className="mb-3">
              <label htmlFor="image" className="form-label">
                Ajouter une image
              </label>
              <input
                type="file"
                id="image"
                name="image"
                className="form-control"
                accept="image/*"
                onChange={handleChange}
                required
              />
            </div>
            <button type="submit" className="btn btn-primary mb-3">
              Ajouter le produit
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