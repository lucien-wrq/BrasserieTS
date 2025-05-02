<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\HttpFoundation\Request;
use OpenApi\Attributes as OA;

class ImagesController extends AbstractController
{
    /**
     * Route pour récupérer une image spécifique par son ID (nom de fichier)
     */
    #[OA\Tag(name: 'Images')]
    #[Route('/api/images/{id}', name: 'get_image_by_id', methods: ['GET'])]
    public function getImageById(string $id): Response
    {
        $imagesDirectory = $this->getParameter('kernel.project_dir') . '/public/images';

        $extensions = ['jpg', 'jpeg', 'png','webp']; 
        $imagePath = null;

        foreach ($extensions as $extension) {
            $potentialPath = $imagesDirectory . '/' . $id . '.' . $extension;
            if (file_exists($potentialPath)) {
                $imagePath = $potentialPath;
                break;
            }
        }

        if (!$imagePath) {
            return new JsonResponse(['error' => 'Image introuvable.'], Response::HTTP_NOT_FOUND);
        }

        return new Response(file_get_contents($imagePath), Response::HTTP_OK, [
            'Content-Type' => mime_content_type($imagePath),
            'Content-Disposition' => 'inline; filename="' . basename($imagePath) . '"',
        ]);
    }

    /**
     * Route pour uploader une image
     */
    #[OA\Tag(name: 'Images')]
    #[Route('/api/produits/{id}/upload-image', name: 'upload_image_for_product', methods: ['POST'])]
    public function uploadImageForProduct(int $id, Request $request): JsonResponse
    {
        $imagesDirectory = $this->getParameter('kernel.project_dir') . '/public/images';

        // Vérifiez si un fichier a été uploadé
        $file = $request->files->get('fichier');
        if (!$file) {
            return new JsonResponse(['error' => 'Aucun fichier envoyé.'], Response::HTTP_BAD_REQUEST);
        }

        // Vérifiez le type de fichier
        $allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
        $extension = $file->guessExtension();
        if (!in_array($extension, $allowedExtensions)) {
            return new JsonResponse(['error' => 'Type de fichier non autorisé.'], Response::HTTP_BAD_REQUEST);
        }

        // Renommez le fichier avec l'ID du produit
        $filename = $id . '.' . $extension;

        try {
            // Supprimez l'ancienne image si elle existe
            foreach ($allowedExtensions as $ext) {
                $existingFile = $imagesDirectory . '/' . $id . '.' . $ext;
                if (file_exists($existingFile)) {
                    unlink($existingFile); // Supprime l'ancienne image
                }
            }

            // Déplacez le fichier dans le dossier public/images
            $file->move($imagesDirectory, $filename);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Erreur lors de l\'upload de l\'image : ' . $e->getMessage()], Response::HTTP_INTERNAL_SERVER_ERROR);
        }

        return new JsonResponse(['message' => 'Image uploadée avec succès.', 'filename' => $filename], Response::HTTP_OK);
    }

    /**
     * Route pour uploader une image
     */
    #[OA\Tag(name: 'Images')]
    #[Route('/api/upload-image', name: 'upload_image', methods: ['POST'])]
    public function uploadImage(Request $request): JsonResponse
    {
        $imagesDirectory = $this->getParameter('kernel.project_dir') . '/public/images';

        // Vérifiez si un fichier a été uploadé
        $file = $request->files->get('image');
        if (!$file) {
            return new JsonResponse(['error' => 'Aucun fichier envoyé.'], Response::HTTP_BAD_REQUEST);
        }

        // Vérifiez le type de fichier
        $allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
        $extension = $file->guessExtension();
        if (!in_array($extension, $allowedExtensions)) {
            return new JsonResponse(['error' => 'Type de fichier non autorisé.'], Response::HTTP_BAD_REQUEST);
        }

        // Générer un nom unique pour le fichier
        $filename = uniqid() . '.' . $extension;

        try {
            // Déplacez le fichier dans le dossier public/images
            $file->move($imagesDirectory, $filename);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Erreur lors de l\'upload de l\'image : ' . $e->getMessage()], Response::HTTP_INTERNAL_SERVER_ERROR);
        }

        return new JsonResponse(['message' => 'Image uploadée avec succès.', 'filename' => $filename], Response::HTTP_OK);
    }
}