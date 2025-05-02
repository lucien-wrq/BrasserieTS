<?php

namespace App\Controller;

use App\Entity\Reservation;
use App\Entity\DetailsReservation;
use App\Repository\ReservationRepository;
use App\Repository\UtilisateurRepository;
use App\Repository\ProduitRepository;
use App\Repository\StatusRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
use Symfony\Component\Serializer\SerializerInterface;
use Symfony\Component\Serializer\Normalizer\AbstractNormalizer;

final class ReservationController extends AbstractController
{
    /**
     * Route pour récupérer toutes les réservations
     */
    #[Route('/api/reservations', name: 'getReservations', methods: ['GET'])]
    public function getAllReservations(ReservationRepository $reservationRepository, SerializerInterface $serializer): JsonResponse
    {
        $reservationsList = $reservationRepository->findAll();
        $jsonReservations = $serializer->serialize($reservationsList, 'json', ['groups' => 'getReservations']);
        return new JsonResponse($jsonReservations, Response::HTTP_OK, [], true);
    }

    /**
     * Route pour récupérer une réservation par son ID
     */
    #[Route('/api/reservations/{id}', name: 'getReservation', methods: ['GET'])]
    public function getDetailReservation(Reservation $reservation, SerializerInterface $serializer): JsonResponse
    {
        $jsonReservation = $serializer->serialize($reservation, 'json', ['groups' => 'getReservations']);
        return new JsonResponse($jsonReservation, Response::HTTP_OK, [], true);
    }

    /**
     * Route pour supprime la réservation et les détails de réservation associés par son ID
     */
    #[Route('/api/reservations/{id}', name: 'deleteReservation', methods: ['DELETE'])]
    public function deleteReservation(Reservation $reservation, EntityManagerInterface $entityManager): JsonResponse
    {
        $entityManager->remove($reservation);
        $entityManager->flush();
        return new JsonResponse(null, Response::HTTP_NO_CONTENT);
    }

    /**
     * Route pour créer une nouvelle réservation
     */
    #[Route('/api/reservations', name:"createReservations", methods: ['POST'])]
    public function createReservations(
        Request $request, 
        SerializerInterface $serializer, 
        EntityManagerInterface $em, 
        UrlGeneratorInterface $urlGenerator, 
        UtilisateurRepository $utilisateurRepository,
        ProduitRepository $produitRepository,
        StatusRepository $statusRepository
    ): JsonResponse 
    {
        $content = $request->toArray();

        // Vérification et récupération de l'utilisateur
        $utilisateur_id = $content['utilisateur_id'] ?? null;
        if (!$utilisateur_id) {
            return new JsonResponse(['error' => 'Le champ utilisateur_id est requis'], Response::HTTP_BAD_REQUEST);
        }

        $utilisateur = $utilisateurRepository->find($utilisateur_id);
        if (!$utilisateur) {
            return new JsonResponse(['error' => 'Utilisateur non trouvé'], Response::HTTP_BAD_REQUEST);
        }

        // Vérification et récupération du statut
        $status_id = $content['status_id'] ?? null;
        if (!$status_id) {
            return new JsonResponse(['error' => 'Le champ status_id est requis'], Response::HTTP_BAD_REQUEST);
        }

        $status = $statusRepository->find($status_id);
        if (!$status) {
            return new JsonResponse(['error' => 'Statut non trouvé'], Response::HTTP_BAD_REQUEST);
        }

        // Création de la réservation
        $reservation = new Reservation();
        $reservation->setUtilisateur($utilisateur);
        $reservation->setStatus($status);

        // Gestion de la date
        $date = $content['date'] ?? null;
        if ($date) {
            $reservation->setDate(new \DateTime($date));
        } else {
            $reservation->setDate(new \DateTime());
        }

        // Gestion des détails de réservation
        $details = $content['details'] ?? [];
        if (empty($details)) {
            return new JsonResponse(['error' => 'Les détails de la réservation sont requis'], Response::HTTP_BAD_REQUEST);
        }

        foreach ($details as $detail) {
            $produit_id = $detail['produit_id'] ?? null;
            $quantite = $detail['quantite'] ?? 1;

            if (!$produit_id) {
                return new JsonResponse(['error' => 'Le champ produit_id est requis pour chaque détail'], Response::HTTP_BAD_REQUEST);
            }

            $produit = $produitRepository->find($produit_id);
            if (!$produit) {
                return new JsonResponse(['error' => "Produit avec l'ID $produit_id non trouvé"], Response::HTTP_BAD_REQUEST);
            }

            $detailReservation = new DetailsReservation();
            $detailReservation->setReservation($reservation);
            $detailReservation->setProduit($produit);
            $detailReservation->setQuantite($quantite);

            $em->persist($detailReservation);
        }

        // Persistance de la réservation
        $em->persist($reservation);
        $em->flush();

        // Génération de la réponse
        $jsonReservation = $serializer->serialize($reservation, 'json', ['groups' => 'getReservations']);
        $location = $urlGenerator->generate('getReservation', ['id' => $reservation->getId()], UrlGeneratorInterface::ABSOLUTE_URL);

        return new JsonResponse($jsonReservation, Response::HTTP_CREATED, ["Location" => $location], true);
    }

    /**
     * Route pour mettre à jour une réservation par son ID
     */
    #[Route('/api/reservations/{id}', name: 'updateReservation', methods: ['PUT'])]
    public function updateReservation(
        Request $request,
        SerializerInterface $serializer,
        Reservation $currentReservation,
        EntityManagerInterface $em,
        ProduitRepository $produitRepository,
        StatusRepository $statusRepository // Ajout du repository pour gérer le statut
    ): JsonResponse {
        // Désérialisation et mise à jour de la réservation existante
        $updatedReservation = $serializer->deserialize(
            $request->getContent(),
            Reservation::class,
            'json',
            [AbstractNormalizer::OBJECT_TO_POPULATE => $currentReservation]
        );

        $content = $request->toArray();

        // Gestion du statut via le champ "etat"
        $etat = $content['etat'] ?? null;
        if ($etat) {
            $status = $statusRepository->findOneBy(['etat' => $etat]);
            if (!$status) {
                return new JsonResponse(['error' => 'Statut non trouvé'], Response::HTTP_BAD_REQUEST);
            }
            $updatedReservation->setStatus($status);
        }

        // Mise à jour ou ajout des détails de réservation
        $detailsReservations = $currentReservation->getDetailsReservations(); // Supposons que c'est une collection
        $produit_id = $content['produit'] ?? null;

        if ($produit_id) {
            $produit = $produitRepository->find($produit_id);
            if (!$produit) {
                return new JsonResponse(['error' => 'Produit non trouvé'], Response::HTTP_BAD_REQUEST);
            }

            // Vérifier si un détail de réservation existe déjà pour ce produit
            $detailReservation = null;
            foreach ($detailsReservations as $detail) {
                if ($detail->getProduit() === $produit) {
                    $detailReservation = $detail;
                    break;
                }
            }

            // Si aucun détail n'existe pour ce produit, en créer un nouveau
            if (!$detailReservation) {
                $detailReservation = new DetailsReservation();
                $detailReservation->setReservation($updatedReservation);
                $detailReservation->setProduit($produit);
                $detailsReservations->add($detailReservation); // Ajouter à la collection
            }

            // Mise à jour de la quantité
            $detailReservation->setQuantite($content['quantite'] ?? $detailReservation->getQuantite());
            $em->persist($detailReservation);
        }

        // Persistance des modifications
        $em->persist($updatedReservation);
        $em->flush();

        return new JsonResponse(null, JsonResponse::HTTP_NO_CONTENT);
    }
}