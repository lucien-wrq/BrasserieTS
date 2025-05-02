<?php

namespace App\Entity;

use App\Repository\ReservationRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity(repositoryClass: ReservationRepository::class)]
class Reservation
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(["getProduits", "getReservations", "getDetailsReservation"])]
    private ?int $id = null;

    #[ORM\Column(type: Types::DATETIME_MUTABLE)]
    #[Groups(["getProduits", "getReservations"])]
    #[Assert\NotBlank(message: "La date de réservation est obligatoire.")]
    #[Assert\DateTime(message: "La date de réservation doit être au format valide.")]
    private ?\DateTimeInterface $date = null;

    #[ORM\OneToMany(mappedBy: 'reservation', targetEntity: DetailsReservation::class, cascade: ['persist', 'remove'])]
    private Collection $detailsReservations;

    #[ORM\ManyToOne(inversedBy: 'reservations')]
    #[Groups(["getReservations"])]
    private ?Utilisateur $utilisateur = null;

    #[ORM\ManyToOne(targetEntity: Status::class, inversedBy: "reservations")]
    #[ORM\JoinColumn(nullable: false)]
    #[Groups(["getReservations"])]
    #[Assert\NotNull(message: "Le statut de la réservation est obligatoire.")]
    private ?Status $status = null;

    public function __construct()
    {
        $this->detailsReservations = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getDate(): ?\DateTimeInterface
    {
        return $this->date;
    }

    public function setDate(\DateTimeInterface $date): static
    {
        $this->date = $date;

        return $this;
    }

    /**
     * @return Collection<int, DetailsReservation>
     */
    public function getDetailsReservations(): Collection
    {
        return $this->detailsReservations;
    }

    public function addDetailsReservation(DetailsReservation $detailsReservation): static
    {
        if (!$this->detailsReservations->contains($detailsReservation)) {
            $this->detailsReservations->add($detailsReservation);
            $detailsReservation->setReservation($this);
        }

        return $this;
    }

    public function removeDetailsReservation(DetailsReservation $detailsReservation): static
    {
        if ($this->detailsReservations->removeElement($detailsReservation)) {
            // Set the owning side to null (unless already changed)
            if ($detailsReservation->getReservation() === $this) {
                $detailsReservation->setReservation(null);
            }
        }

        return $this;
    }

    public function getUtilisateur(): ?Utilisateur
    {
        return $this->utilisateur;
    }

    public function setUtilisateur(?Utilisateur $utilisateur): static
    {
        $this->utilisateur = $utilisateur;

        return $this;
    }

    public function getStatus(): ?Status
    {
        return $this->status;
    }

    public function setStatus(?Status $status): static
    {
        $this->status = $status;

        return $this;
    }
}
