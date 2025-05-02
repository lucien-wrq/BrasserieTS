import { useEffect, useState } from "react";
import Header from "../components/Header";
import Footer from "../components/Footer";

export default function Home() {
  const [produits, setProduits] = useState([]);
  const [showDescription, setShowDescription] = useState<{ [key: number]: boolean }>({});

  useEffect(() => {
    // Récupérer les produits
    fetch("/api/produits")
      .then((res) => res.json())
      .then((data) => setProduits(data));
  }, []);

  const toggleDescription = (id: number) => {
    setShowDescription((prev) => ({
      ...prev,
      [id]: !prev[id],
    }));
  };

  return (
    <div className="container">
      {/* Header */}
      <Header />

      {/* Contenu principal */}
      <main className="my-5">
        <h1 className="text-center mb-4 border-bottom border-secondary ">Nos Produits</h1>
        <div className="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
          {produits.map((produit: any) => (
            <div key={produit.id} className="col">
              <div className="card h-100 shadow-sm">
                <img
                  src={`/api/images/${produit.id}`}
                  alt={`Image de ${produit.nom}`}
                  className="card-img-top"
                  style={{ maxHeight: "400px", objectFit: "cover" }}
                />
                <div className="card-body">
                  <h5 className="card-title">{produit.nom}</h5>
                  <p className="card-text">Prix : {produit.prix} €</p>
                  <p className="card-text">Quantité disponible : {produit.quantite}</p>
                  <button
                    className="btn btn-secondary"
                    onClick={() => toggleDescription(produit.id)}
                  >
                    {showDescription[produit.id] ? "Masquer" : "Voir plus"}
                  </button>
                  {showDescription[produit.id] && (
                    <p className="mt-3">{produit.description}</p>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </main>

      {/* Footer */}
      <Footer />
    </div>
  );
}