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

  console.log("Statut de la réponse :", response.status); // Log du statut HTTP

  if (!response.ok) {
    const errorData = await response.text(); // Utilisez `text()` pour éviter une erreur JSON
    console.error("Erreur API :", errorData);
    throw new Error(errorData || "Erreur lors de la requête API.");
  }

  // Vérifiez si la réponse contient du contenu avant de l'analyser
  const contentType = response.headers.get("Content-Type");
  if (contentType && contentType.includes("application/json")) {
    return response.json();
  } else {
    console.warn("Réponse vide ou non JSON.");
    return null; // Retournez `null` si la réponse est vide
  }
};