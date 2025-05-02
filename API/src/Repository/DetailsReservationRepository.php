<?php

namespace App\Repository;

use App\Entity\DetailsReservation;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<DetailsReservation>
 *
 * @method DetailsReservation|null find($id, $lockMode = null, $lockVersion = null)
 * @method DetailsReservation|null findOneBy(array $criteria, array $orderBy = null)
 * @method DetailsReservation[]    findAll()
 * @method DetailsReservation[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class DetailsReservationRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, DetailsReservation::class);
    }

    // Exemple de méthode personnalisée
    public function findByReservationId(int $reservationId): array
    {
        return $this->createQueryBuilder('d')
            ->andWhere('d.reservation = :reservationId')
            ->setParameter('reservationId', $reservationId)
            ->getQuery()
            ->getResult();
    }
}