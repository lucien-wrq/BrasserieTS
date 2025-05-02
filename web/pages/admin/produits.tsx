import { useEffect, useState } from "react";
import Header from "../../components/Header";
import { useRouter } from "next/router";

export default function GestionProduits() {
  const [produits, setProduits] = useState([]);
  const [isLoading, setIsLoading] = useState(true); // État pour le chargement
  const [isClient, setIsClient] = useState(false); // Vérifie si le code s'exécute côté client
  const [imageTimestamp, setImageTimestamp] = useState(Date.now()); // Timestamp pour forcer le rechargement des images
  const router = useRouter();

  useEffect(() => {
    setIsClient(true);
    fetchProduits();

    // Écoute les changements de route pour recharger les données
    const handleRouteChange = () => {
      fetchProduits();
      setImageTimestamp(Date.now()); // Met à jour le timestamp après un changement de route
    };

    router.events.on("routeChangeComplete", handleRouteChange);

    // Nettoyage de l'écouteur lors du démontage du composant
    return () => {
      router.events.off("routeChangeComplete", handleRouteChange);
    };
  }, []);

  const fetchProduits = async () => {
    try {
      setIsLoading(true); // Début du chargement
      const response = await fetch("/api/produits");
      if (!response.ok) {
        throw new Error("Erreur lors de la récupération des produits.");
      }
      const data = await response.json();
      setProduits(data);
    } catch (error) {
      console.error(error);
    } finally {
      setIsLoading(false); // Fin du chargement
    }
  };

  const handleAdd = () => {
    router.push("/admin/AjoutProduits");
  };

  const handleEdit = (id: number) => {
    router.push(`/admin/ModifierProduits?id=${id}`);
  };

  const handleImage = (id: number) => {
    router.push(`/admin/ModifierImageProduits?id=${id}`).then(() => {
      setImageTimestamp(Date.now()); // Met à jour le timestamp après modification de l'image
    });
  };

  const handleDelete = async (id: number) => {
    if (confirm("Êtes-vous sûr de vouloir supprimer ce produit ?")) {
      try {
        const response = await fetch(`/api/produits/${id}`, {
          method: "DELETE",
        });

        if (!response.ok) {
          throw new Error("Erreur lors de la suppression du produit.");
        }

        alert("Produit supprimé avec succès !");
        fetchProduits(); // Rafraîchit la liste des produits après suppression
      } catch (error) {
        console.error(error);
        alert("Une erreur est survenue lors de la suppression du produit.");
      }
    }
  };

  if (!isClient) {
    // Empêche le rendu côté serveur
    return null;
  }

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
        <h1 className="text-center mb-4">Gestion des Produits</h1>
        <button className="btn btn-primary mb-3" onClick={handleAdd}>
          Ajouter un produit
        </button>

        {/* Affichage du message de chargement */}
        {isLoading ? (
          <p className="text-center">Chargement...</p>
        ) : (
          <table className="table">
            <thead className="table-dark">
              <tr>
                <th className="text-center">Image</th>
                <th className="text-center">Nom</th>
                <th className="text-center">Prix</th>
                <th className="text-center">Quantité</th>
                <th className="text-center">Actions</th>
              </tr>
            </thead>
            <tbody>
              {produits.map((produit: any) => (
                <tr key={produit.id}>
                  <td>
                    <div
                      style={{
                        display: "flex",
                        justifyContent: "center",
                        alignItems: "center",
                        height: "100px",
                      }}
                    >
                      <img
                        src={`/api/images/${produit.id}?t=${imageTimestamp}`} // Ajout du timestamp pour contourner le cache
                        alt={produit.nom}
                        width={100}
                        height={100}
                        className="product-image"
                      />
                    </div>
                  </td>
                  <td className="align-middle text-center">{produit.nom}</td>
                  <td className="align-middle text-center">{produit.prix} €</td>
                  <td className="align-middle text-center">{produit.quantite}</td>
                  <td className="align-middle text-center">
                    <button
                      className="btn btn-warning btn-sm me-2"
                      onClick={() => handleEdit(produit.id)}
                      title="Modifier le produit"
                    >
                      <i className="fas fa-edit"></i>
                    </button>
                    <button
                      className="btn btn-warning btn-sm me-2"
                      onClick={() => handleImage(produit.id)}
                      title="Modifier l'image du produit"
                    >
                      <i className="fas fa-image"></i>
                    </button>
                    <button
                      className="btn btn-danger btn-sm"
                      onClick={() => handleDelete(produit.id)}
                      title="Supprimer le produit"
                    >
                      <i className="fas fa-trash"></i>
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </main>
    </div>
  );
}