<?php

namespace App\Entity;

use App\Repository\DetailsReservationRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

#[ORM\Entity(repositoryClass: DetailsReservationRepository::class)]
class DetailsReservation
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(["getReservations", "getDetailsReservation"])]
    private ?int $id = null;

    #[ORM\ManyToOne(targetEntity: Reservation::class, inversedBy: 'detailsReservations')]
    #[ORM\JoinColumn(nullable: false)]
    #[Groups(["getDetailsReservation"])]
    private ?Reservation $reservation = null;

    #[ORM\ManyToOne(targetEntity: Produit::class, inversedBy: 'detailsReservations')]
    #[ORM\JoinColumn(nullable: false)]
    #[Groups(["getReservations", "getDetailsReservation"])]
    private ?Produit $produit = null;

    #[ORM\Column]
    #[Groups(["getReservations", "getDetailsReservation"])]
    private ?int $quantite = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getReservation(): ?Reservation
    {
        return $this->reservation;
    }

    public function setReservation(?Reservation $reservation): static
    {
        $this->reservation = $reservation;

        return $this;
    }

    public function getProduit(): ?Produit
    {
        return $this->produit;
    }

    public function setProduit(?Produit $produit): static
    {
        $this->produit = $produit;

        return $this;
    }

    public function getQuantite(): ?int
    {
        return $this->quantite;
    }

    public function setQuantite(int $quantite): static
    {
        $this->quantite = $quantite;

        return $this;
    }
}