import Link from "next/link";
import { useEffect, useState } from "react";
import { useRouter } from "next/router";

export default function Header() {
  const [role, setRole] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    // Fonction pour synchroniser le rôle avec le localStorage
    const syncRole = () => {
      const userRole = localStorage.getItem("role");
      setRole(userRole);
    };

    // Récupérer le rôle initial
    syncRole();

    // Écouter les changements dans le localStorage
    window.addEventListener("storage", syncRole);

    // Nettoyer l'écouteur lors du démontage du composant
    return () => {
      window.removeEventListener("storage", syncRole);
    };
  }, [router]);

  const handleLogout = () => {
    // Supprimer les données du localStorage
    localStorage.removeItem("role");
    localStorage.removeItem("jwtToken");
    localStorage.removeItem("userId");
    setRole(null);
    router.push("/"); // Rediriger vers la page d'accueil après déconnexion
  };

  return (
    <header className="text-black py-3">
      <div className="container d-flex justify-content-between align-items-center">
        {/* Logo */}
        <div className="d-flex align-items-center">
          <img
            src="/images/brasserie_logo.png"
            alt="Logo Brasserie BTS"
            width={100}
            height={100}
            className="me-3"
          />
          <h1 className="h4 mb-0 text-decoration-none">Brasserie TS</h1>
        </div>

        {/* Navigation */}
        <nav className="d-flex align-items-center gap-3">
          <Link href="/" className="text-decoration-none">
            Accueil
          </Link>
          {role === "Administrateur" && (
            <Link href="/admin/dashboard" className="text-decoration-none">
              Dashboard
            </Link>
          )}
          {role ? (
            <button
              onClick={handleLogout}
              className="btn btn-outline-dark btn-md"
            >
              Se déconnecter
            </button>
          ) : (
            <Link href="/login" className="btn btn-outline-dark btn-md">
              Connexion
            </Link>
          )}
        </nav>
      </div>
    </header>
  );
}