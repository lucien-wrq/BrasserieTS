import Header from "../../components/Header";
import Link from "next/link";

export default function AdminDashboard() {
  return (
    <div className="container">
      {/* Header */}
      <Header />

      {/* Contenu principal */}
      <main className="my-5">
        <h1 className="text-center mb-4">Tableau de bord - Administrateur</h1>
        <div className="row row-cols-1 row-cols-md-3 g-4">
          <div className="col">
            <div className="card h-100 shadow-sm">
              <div className="card-body">
                <h2 className="card-title">Produits</h2>
                <p className="card-text">Gérez les produits disponibles dans votre système.</p>
                <Link href="/admin/produits" className="btn btn-primary">
                  Gérer les produits
                </Link>
              </div>
            </div>
          </div>
          <div className="col">
            <div className="card h-100 shadow-sm">
              <div className="card-body">
                <h2 className="card-title">Utilisateurs</h2>
                <p className="card-text">Consultez et gérez les informations des utilisateurs.</p>
                <Link href="/admin/clients" className="btn btn-primary">
                  Gérer les utilisateurs
                </Link>
              </div>
            </div>
          </div>
          <div className="col">
            <div className="card h-100 shadow-sm">
              <div className="card-body">
                <h2 className="card-title">Réservations</h2>
                <p className="card-text">Suivez et gérez les réservations effectuées par les utilisateurs.</p>
                <Link href="/admin/reservations" className="btn btn-primary">
                  Gérer les réservations
                </Link>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}