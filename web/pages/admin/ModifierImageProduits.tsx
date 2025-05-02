import { useState, useEffect } from "react";
import { useRouter } from "next/router";
import Header from "../../components/Header";

export default function ModifierImageProduits() {
  const [produit, setProduit] = useState<any>(null); // État pour les données du produit
  const [image, setImage] = useState<File | null>(null); // État pour le fichier image
  const [error, setError] = useState("");
  const router = useRouter();
  const { id } = router.query; // Récupère l'ID du produit depuis l'URL

  useEffect(() => {
    if (id) {
      fetchProduit();
    }
  }, [id]);

  const fetchProduit = async () => {
    try {
      const response = await fetch(`/api/produits/${id}`);
      if (!response.ok) {
        throw new Error("Erreur lors de la récupération du produit.");
      }
      const data = await response.json();
      setProduit(data);
    } catch (error) {
      console.error(error);
      setError("Impossible de charger les données du produit.");
    }
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0] || null;
    if (file && !file.type.startsWith("image/")) {
      alert("Veuillez sélectionner un fichier image valide.");
      return;
    }
    setImage(file); // Stocke le fichier sélectionné
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!image) {
      setError("Veuillez sélectionner une image.");
      return;
    }

    try {
      const formData = new FormData();
      formData.append("fichier", image);

      const response = await fetch(`/api/produits/${id}/upload-image`, {
        method: "POST",
        body: formData,
      });

      if (!response.ok) {
        throw new Error("Erreur lors de l'upload de l'image.");
      }

      alert("Image modifiée avec succès !");
      router.push("/admin/produits");
    } catch (error) {
      console.error(error);
      setError("Une erreur est survenue lors de la modification de l'image.");
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
        <h1 className="text-center mb-4">Modifier l'image du produit</h1>

        {error && <p className="text-danger text-center">{error}</p>}

        {produit ? (
          <div className="card p-4" style={{ transform: "none" }}>
            <form onSubmit={handleSubmit}>
              <div className="mb-3 text-center">
                <label htmlFor="image" className="form-label">
                  Image actuelle :
                </label>
                <div>
                  <img
                    src={`/api/images/${produit.id}`}
                    alt={produit.nom}
                    width={150}
                    height={150}
                    className="rounded"
                  />
                </div>
              </div>
              <div className="mb-3">
                <label htmlFor="image" className="form-label">
                  Nouvelle image :
                </label>
                <input
                  type="file"
                  id="image"
                  name="image"
                  className="form-control"
                  accept="image/*"
                  onChange={handleImageChange}
                  required
                />
              </div>
              <button type="submit" className="btn btn-primary mb-3">
                Modifier l'image
              </button>
              <button
                type="button"
                className="btn btn-secondary mb-3 mx-2"
                onClick={handleRetour}
              >
                Retour
              </button>
            </form>
          </div>
        ) : (
          <p className="text-center">Chargement des données du produit...</p>
        )}
      </main>
    </div>
  );
}