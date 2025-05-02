<?php
namespace App\Controller;

use App\Entity\Status;
use App\Repository\StatusRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Serializer\SerializerInterface;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Attribute\Security;


#[Route('/api/status')]
class StatusController extends AbstractController
{


    /**
     * Route pour récupérer tous les statuts
     */
    #[OA\Tag(name: 'Statuts')]
    #[Security(name: 'Bearer')]
    #[Route('', name: 'getStatus', methods: ['GET'])]
    public function getAllStatus(StatusRepository $statusRepository, SerializerInterface $serializer): JsonResponse
    {
        $statusList = $statusRepository->findAll();
        $jsonStatus = $serializer->serialize($statusList, 'json', ['groups' => 'getStatus']);
        return new JsonResponse($jsonStatus, Response::HTTP_OK, [], true);
    }

    /**
     * Route pour creer un nouveau statut
     */
    #[OA\Tag(name: 'Statuts')]
    #[Security(name: 'Bearer')]
    #[Route('', name: 'createStatus', methods: ['POST'])]
    public function addStatus(
        Request $request,
        EntityManagerInterface $entityManager,
        SerializerInterface $serializer,
        ValidatorInterface $validator
    ): JsonResponse {
        $status = $serializer->deserialize($request->getContent(), Status::class, 'json');

        // Validation des données
        $errors = $validator->validate($status);
        if (count($errors) > 0) {
            return new JsonResponse((string) $errors, Response::HTTP_BAD_REQUEST);
        }

        $entityManager->persist($status);
        $entityManager->flush();

        return new JsonResponse(null, Response::HTTP_CREATED);
    }
}