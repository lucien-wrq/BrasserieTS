<?php

namespace App\Controller;

use App\Entity\Utilisateur;
use App\Repository\UtilisateurRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Security\Core\Exception\AuthenticationException;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;
use Symfony\Component\Serializer\SerializerInterface;

class LoginController extends AbstractController
{
    /**
     * Route pour vérifier l'utilisateur et générer un token JWT
     */
    #[Route('/api/login', name: 'api_login', methods: ['POST'])]
    public function verifyUtilisateur(
        Request $request,
        UtilisateurRepository $utilisateurRepository,
        UserPasswordHasherInterface $passwordHasher,
        JWTTokenManagerInterface $JWTManager
    ): JsonResponse {
        $content = json_decode($request->getContent(), true);
        $email = $content['email'] ?? null;
        $password = $content['password'] ?? null;

        if (empty($email) || empty($password)) {
            return new JsonResponse(['message' => 'Email et mot de passe sont requis.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        $utilisateur = $utilisateurRepository->findOneBy(['email' => $email]);

        if (!$utilisateur) {
            return new JsonResponse(['message' => 'Utilisateur non trouvé.'], JsonResponse::HTTP_NOT_FOUND);
        }

        if (!$passwordHasher->isPasswordValid($utilisateur, $password)) {
            return new JsonResponse(['message' => 'Mot de passe incorrect.'], JsonResponse::HTTP_UNAUTHORIZED);
        }

        // 🔐 Génération du token JWT
        try {
            $token = $JWTManager->create($utilisateur);
        } catch (\Exception $e) {
            return new JsonResponse(['message' => 'Erreur lors de la génération du token JWT.'], JsonResponse::HTTP_INTERNAL_SERVER_ERROR);
        }

        // Construire manuellement la réponse utilisateur
        $utilisateurData = [
            'id' => $utilisateur->getId(),
            'email' => $utilisateur->getEmail(),
            'roles' => $utilisateur->getRoles(),
        ];

        return new JsonResponse([
            'token' => $token,
            'utilisateur' => $utilisateurData,
            'redirect' => '/monEspace'
        ], JsonResponse::HTTP_OK);
    }
}