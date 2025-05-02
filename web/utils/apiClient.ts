export const apiClient = async (url: string, options: RequestInit = {}) => {
  const token = localStorage.getItem("jwtToken");

  if (!token) {
    console.error("Token JWT manquant.");
    throw new Error("Token JWT manquant.");
  }

  const headers = {
    ...options.headers,
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  };

  const response = await fetch(url, { ...options, headers });

  console.log("Statut de la réponse :", response.status);

  if (!response.ok) {
    if (response.status === 401) {
      console.warn("Token expiré ou invalide. Déconnexion en cours...");
      handleLogout(); 
    }

    const errorData = await response.text();
    console.error("Erreur API :", errorData);
    throw new Error(errorData || "Erreur lors de la requête API.");
  }

  const contentType = response.headers.get("Content-Type");
  if (contentType && contentType.includes("application/json")) {
    return response.json();
  } else {
    console.warn("Réponse vide ou non JSON.");
    return null;
  }
};

const handleLogout = () => {
  localStorage.removeItem("jwtToken"); 
  window.location.href = "/login"; 

};