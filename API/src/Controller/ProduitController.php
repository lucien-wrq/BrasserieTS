<?php

namespace App\Controller;

use App\Entity\Produit;
use App\Repository\ProduitRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
use Symfony\Component\Serializer\SerializerInterface;
use Symfony\Component\Serializer\Normalizer\AbstractNormalizer;
use Symfony\Component\Validator\Validator\ValidatorInterface;

final class ProduitController extends AbstractController
{

    /** 
     * Route pour récupérer tous les produits
    */
    #[Route('/api/produits', name: 'getProduits', methods: ['GET'])]
    public function getAllProduits(ProduitRepository $produitRepository, SerializerInterface $serializer): JsonResponse
    {
        $produitsList = $produitRepository->findAll();
        $jsonProduits = $serializer->serialize($produitsList, 'json', ['groups' => 'getProduits']);
        return new JsonResponse($jsonProduits, Response::HTTP_OK, [], true);
    }

    /**
     * Route pour récupérer un produit par son ID
     */
    #[Route('/api/produits/{id}', name: 'getProduit', methods: ['GET'])]
    public function getDetailProduit(Produit $produit, SerializerInterface $serializer): JsonResponse
    {
        $jsonProduit = $serializer->serialize($produit, 'json', ['groups' => 'getProduits']);
        return new JsonResponse($jsonProduit, Response::HTTP_OK, [], true);
    }

    
    /**
     *  Route pour supprimer un produit par son ID
     */
    #[Route('/api/produits/{id}', name: 'deleteProduit', methods: ['DELETE'])]
    public function deleteProduit(Produit $produit, EntityManagerInterface $entityManager): JsonResponse
    {
        $entityManager->remove($produit);
        $entityManager->flush();
        return new JsonResponse(null, Response::HTTP_NO_CONTENT);
    }

    /**
     * Route pour créer un produit
     */
    #[Route('/api/produits', name: 'createProduit', methods: ['POST'])]
    public function addProduit(Request $request, EntityManagerInterface $entityManager, SerializerInterface $serializer, UrlGeneratorInterface $urlGenerator, ValidatorInterface $validator): JsonResponse
    {
        $produit = $serializer->deserialize($request->getContent(), Produit::class, 'json');

        // Validation des données
        $errors = $validator->validate($produit);
        if (count($errors) > 0) {
            return new JsonResponse((string) $errors, Response::HTTP_BAD_REQUEST);
        }

        $entityManager->persist($produit);
        $entityManager->flush();

        $location = $urlGenerator->generate('getProduit', ['id' => $produit->getId()], UrlGeneratorInterface::ABSOLUTE_URL);

        $jsonProduit = $serializer->serialize($produit, 'json', ['groups' => 'getProduits']);
        return new JsonResponse($jsonProduit, Response::HTTP_CREATED, ["Location" => $location], true);
    }

    /**
     * Route pour mettre à jour un produit par son ID
     */
    #[Route('/api/produits/{id}', name: 'updateProduit', methods: ['PUT'])]
    public function updateProduit(
        Request $request, 
        SerializerInterface $serializer, 
        Produit $currentProduit, 
        EntityManagerInterface $em
    ): JsonResponse 
    {
        $updatedProduit = $serializer->deserialize(
            $request->getContent(),
            Produit::class,
            'json',
            [AbstractNormalizer::OBJECT_TO_POPULATE => $currentProduit]
        );

        $em->persist($updatedProduit);
        $em->flush();

        return new JsonResponse(null, JsonResponse::HTTP_NO_CONTENT);
    }

    /**
     * Route pour supprimer un produit par son ID
     */
    #[Route('/api/produits/{id}', name: 'delete_product', methods: ['DELETE'])]
    public function deleteProduct(int $id, Request $request, EntityManagerInterface $entityManager): JsonResponse
    {
        $produit = $entityManager->getRepository(Produit::class)->find($id);

        if (!$produit) {
            return new JsonResponse(['error' => 'Produit non trouvé.'], Response::HTTP_NOT_FOUND);
        }

        $imagesDirectory = $this->getParameter('kernel.project_dir') . '/public/images';
        $allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

        try {
            // Supprimez l'image associée au produit
            foreach ($allowedExtensions as $ext) {
                $imagePath = $imagesDirectory . '/' . $id . '.' . $ext;
                if (file_exists($imagePath)) {
                    if (!unlink($imagePath)) {
                        throw new \Exception("Impossible de supprimer le fichier : " . $imagePath);
                    }
                }
            }

            // Supprimez le produit de la base de données
            $entityManager->remove($produit);
            $entityManager->flush();

            return new JsonResponse(['message' => 'Produit et image supprimés avec succès.'], Response::HTTP_OK);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Erreur lors de la suppression : ' . $e->getMessage()], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
}
