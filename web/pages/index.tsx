import { useEffect, useState } from "react";
import Header from "../components/Header";
import Footer from "../components/Footer";

export default function Home() {
  const [produits, setProduits] = useState([]);
  const [showDescription, setShowDescription] = useState<{ [key: number]: boolean }>({});

  useEffect(() => {
    // Récupérer les produits
    fetch(`${process.env.NEXT_PUBLIC_API_URL}/produits`)
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

        {/* Section description */}
        <section className="card mb-4 p-4" style={{ transform: "none" }}>

          <section
            className="hero-section text-center text-white d-flex align-items-center justify-content-center mb-5"
            style={{
              backgroundImage: "url('/images/brasserie_image.jpg')", // Chemin de l'image
              backgroundSize: "cover",
              backgroundPosition: "center",
              height: "400px",
              borderRadius: "10px",
            }}
          >
          </section>

          <p className="fs-5 fw-light text-muted">
            Nichée au cœur des Hauts-de-France, la Brasserie TS vous invite à découvrir un univers de bières artisanales brassées avec amour, patience et exigence. Ici, chaque recette raconte une histoire, chaque gorgée reflète le caractère unique de notre terroir.
          </p>
          <p className="fs-5 fw-light text-muted">
            Depuis 2023, nous cultivons l'art de la bière en petite série, avec des ingrédients locaux et naturels. Blondes, brunes, IPA ou même plus récemment notre Gin et notre Whisky, notre gamme évolue au fil des inspirations et des rencontres, pour offrir des breuvages riches en goût et en personnalité.
          </p>
          <p className="fs-5 fw-light text-muted">
            Chez nous, pas de production industrielle : juste le plaisir de créer, de partager, et de faire vivre une tradition brassicole tournée vers l'avenir.
          </p>
          <p className="fs-5 fw-light text-muted">
            🍺 Visitez notre brasserie, dégustez nos créations dans notre espace chaleureux, ou commandez en ligne depuis notre application mobile pour découvrir la différence d'une bière artisanale véritable.
          </p>


        </section>
        <h1 className="text-center mb-4 border-bottom border-secondary">Nos Produits</h1>
        {/* Produits */}
        <div className="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
          {produits.map((produit: any) => (
            <div key={produit.id} className="col">
              <div className="card h-100 shadow-sm">
                <img
                  src={`${process.env.NEXT_PUBLIC_API_URL}/images/${produit.id}`}
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