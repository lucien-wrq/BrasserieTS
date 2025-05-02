<?php

namespace App\Controller;

use App\Entity\DetailsReservation;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Serializer\SerializerInterface;

final class DetailsReservationController extends AbstractController
{
    
    /**
     * Route pour récupérer tous les détails de réservation
     */
    #[Route('/api/details-reservations', name: 'getDetailsReservations', methods: ['GET'])]
    public function getAllDetailsReservations(EntityManagerInterface $entityManager, SerializerInterface $serializer): JsonResponse
    {
        $detailsReservationsList = $entityManager->getRepository(DetailsReservation::class)->findAll();
        $jsonDetailsReservations = $serializer->serialize($detailsReservationsList, 'json', ['groups' => 'getDetailsReservation']);
        return new JsonResponse($jsonDetailsReservations, Response::HTTP_OK, [], true);
    }

    /**
     * Route pour récupérer un détail de réservation par son ID
     */
    #[Route('/api/details-reservations/{id}', name: 'getDetailsReservation', methods: ['GET'])]
    public function getDetailDetailsReservation(DetailsReservation $detailsReservation, SerializerInterface $serializer): JsonResponse
    {
        $jsonDetailsReservation = $serializer->serialize($detailsReservation, 'json', ['groups' => 'getDetailsReservation']);
        return new JsonResponse($jsonDetailsReservation, Response::HTTP_OK, [], true);
    }

    /**
     * Route pour supprimer un détail de réservation par son ID
     */
    #[Route('/api/details-reservations/{id}', name: 'deleteDetailsReservation', methods: ['DELETE'])]
    public function deleteDetailsReservation(DetailsReservation $detailsReservation, EntityManagerInterface $entityManager): JsonResponse
    {
        $entityManager->remove($detailsReservation);
        $entityManager->flush();
        return new JsonResponse(null, Response::HTTP_NO_CONTENT);
    }

}