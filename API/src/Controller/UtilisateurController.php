<?php

namespace App\Controller;

use App\Entity\Utilisateur;
use App\Repository\UtilisateurRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
use Symfony\Component\Serializer\SerializerInterface;
use Symfony\Component\Serializer\Normalizer\AbstractNormalizer;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Repository\RoleRepository;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Security;

final class UtilisateurController extends AbstractController
{
    /**
     * Route pour récupérer tous les utilisateurs
     */
    #[OA\Tag(name: 'Utilisateurs')]
    #[Security(name: 'Bearer')]
    #[Route('api/utilisateurs', name: 'getAllUtilisateurs', methods: ['GET'])]
    public function getAllUtilisateurs(UtilisateurRepository $utilisateurRepository, SerializerInterface $serializer): JsonResponse
    {
        $utilisateurList = $utilisateurRepository->findAll();
        if (!$utilisateurList) {
            return new JsonResponse(['error' => 'Aucun utilisateur trouvé'], Response::HTTP_NOT_FOUND);
        }

        $jsonUtilisateurs = $serializer->serialize($utilisateurList, 'json', ['groups' => 'getUtilisateurs']);
        return new JsonResponse($jsonUtilisateurs, Response::HTTP_OK, [], true);
    }

    /**
     * Route pour récupérer un utilisateur par son ID
     */
    #[OA\Tag(name: 'Utilisateurs')]
    #[Security(name: 'Bearer')]
    #[Route('api/utilisateurs/{id}', name: 'getUtilisateur', methods: ['GET'])]
    public function getDetailUtilisateur(UtilisateurRepository $utilisateurRepository, SerializerInterface $serializer, int $id): JsonResponse
    {
        $utilisateur = $utilisateurRepository->find($id);
        if (!$utilisateur) {
            return new JsonResponse(['error' => 'Utilisateur not found'], Response::HTTP_NOT_FOUND);
        }
        $jsonUtilisateur = $serializer->serialize($utilisateur, 'json', ['groups' => 'getUtilisateurs']);
        return new JsonResponse($jsonUtilisateur, Response::HTTP_OK, [], true);
    }
    
    /**
     * Route pour supprimer un utilisateur par son ID
     */
    #[OA\Tag(name: 'Utilisateurs')]
    #[Security(name: 'Bearer')]
    #[Route('api/utilisateurs/{id}', name: 'deleteUtilisateur', methods: ['DELETE'])]
    public function deleteUtilisateur(Utilisateur $utilisateur, EntityManagerInterface $entityManager): JsonResponse
    {
        $entityManager->remove($utilisateur);
        $entityManager->flush();

        return new JsonResponse(null, Response::HTTP_NO_CONTENT);
    }

    /**
     * Route pour créer un nouvel utilisateur
     */ 
    #[OA\Tag(name: 'Utilisateurs')]
    #[Route('/api/utilisateurs', name: 'createUtilisateur', methods: ['POST'])]
    public function addUtilisateur(
        Request $request,
        EntityManagerInterface $entityManager,
        UserPasswordHasherInterface $passwordHasher
    ): JsonResponse {
        $content = json_decode($request->getContent(), true);
        $nom = $content['nom'] ?? null;
        $prenom = $content['prenom'] ?? null;
        $email = $content['email'] ?? null;
        $password = $content['password'] ?? null;
        $role = $content['role'] ?? null;

        if (empty($nom) || empty($prenom) || empty($email) || empty($password) || empty($role)) {
            return new JsonResponse(['message' => 'Tous les champs sont requis.'], JsonResponse::HTTP_BAD_REQUEST);
        }

        // Vérifier si l'utilisateur existe déjà
        if ($entityManager->getRepository(Utilisateur::class)->findOneBy(['email' => $email])) {
            return new JsonResponse(['message' => 'Cet email est déjà utilisé.'], JsonResponse::HTTP_CONFLICT);
        }

        // Création de l'utilisateur
        $utilisateur = new Utilisateur();
        $utilisateur->setNom($nom)
                    ->setPrenom($prenom)
                    ->setEmail($email)
                    ->setPassword($passwordHasher->hashPassword($utilisateur, $password))
                    ->setRoles([$role]);

        $entityManager->persist($utilisateur);
        $entityManager->flush();

        return new JsonResponse(['message' => 'Utilisateur enregistré avec succès.'], JsonResponse::HTTP_CREATED);
    }

    /**
     * Route pour mettre à jour un utilisateur par son ID
     */
    #[OA\Tag(name: 'Utilisateurs')]
    #[Route('/api/utilisateurs/{id}', name: 'updateUtilisateur', methods: ['PUT'])]
    public function updateUtilisateur(
        Request $request, 
        SerializerInterface $serializer, 
        Utilisateur $currentUtilisateur, 
        EntityManagerInterface $em
    ): JsonResponse 
    {
        $content = $request->toArray();

        // Désérialisation des données et mise à jour de l'utilisateur
        $updatedUtilisateur = $serializer->deserialize(
            $request->getContent(),
            Utilisateur::class,
            'json',
            [AbstractNormalizer::OBJECT_TO_POPULATE => $currentUtilisateur]
        );

        // Vérification et hashage du mot de passe si modifié
        if (isset($content['mdp']) && !empty($content['mdp'])) {
            $hashedPassword = password_hash($content['mdp'], PASSWORD_BCRYPT);
            $updatedUtilisateur->setPassword($hashedPassword);
        }

        $em->persist($updatedUtilisateur);
        $em->flush();

        return new JsonResponse(null, JsonResponse::HTTP_NO_CONTENT);
    }
}
