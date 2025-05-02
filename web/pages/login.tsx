import { useState } from "react";
import { useRouter } from "next/router";
import Header from "../components/Header";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const router = useRouter();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();

    try {
      const response = await fetch("/api/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || "Erreur inconnue");
      }

      const data = await response.json();

      // Stocker le token JWT et les informations utilisateur dans le localStorage
      localStorage.setItem("jwtToken", data.token);
      localStorage.setItem("userId", data.utilisateur.id);
      localStorage.setItem("role", data.utilisateur.roles.includes("ROLE_ADMIN") ? "Administrateur" : "Utilisateur");

      // Rediriger en fonction du rôle
      if (data.utilisateur.roles.includes("ROLE_ADMIN")) {
        router.push("/admin/dashboard");
      } else {
        throw new Error("Accès refusé. Cette connexion est réservée aux administrateurs.");
      }
    } catch (err: any) {
      setError(err.message);
    }
  };

  return (
    <div className="container">
      {/* Header */}
      <Header />

      <style jsx global>{`
        html,
        body {
          height: 100%;
          margin: 0;
          overflow: hidden; /* Empêche le défilement */
        }
        .vh-100 {
          height: 100vh;
        }
        .d-flex {
          display: flex;
        }
        .justify-content-center {
          justify-content: center;
        }
        .align-items-center {
          align-items: center;
        }
      `}</style>

      <div className="d-flex justify-content-center align-items-center vh-100">
        <div className="card shadow p-4" style={{ maxWidth: "400px", width: "100%", transform: "none" }}>
          <h1 className="h4 text-center mb-4">Connexion</h1>
          {error && <p className="text-danger text-center">{error}</p>}
          <form onSubmit={handleLogin}>
            <div className="mb-3">
              <label htmlFor="email" className="form-label">
                Email
              </label>
              <input
                type="email"
                id="email"
                className="form-control"
                placeholder="Entrez votre email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>

            <div className="mb-3">
              <label htmlFor="password" className="form-label">
                Mot de passe
              </label>
              <input
                type="password"
                id="password"
                className="form-control"
                placeholder="Entrez votre mot de passe"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            <button type="submit" className="btn btn-primary w-100">
              Se connecter
            </button>
          </form>
          <p className="text-center mt-3">
            <a href="/" className="text-decoration-none">
              Retour à l'accueil
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}