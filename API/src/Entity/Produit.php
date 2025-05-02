<?php

namespace App\Entity;

use App\Repository\ProduitRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity(repositoryClass: ProduitRepository::class)]
class Produit
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(["getProduits", "getDetailsReservation"])]
    private ?int $id = null;

    #[ORM\Column(length: 255)]
    #[Groups(["getProduits"])]
    #[Assert\NotBlank(message: "Le nom du produit est obligatoire")]
    #[Assert\Length(
        min: 3,
        max: 255,
        minMessage: 'Le nom du produit doit contenir au moins {{ limit }} caractères',
        maxMessage: 'Le nom du produit ne peut pas dépasser {{ limit }} caractères'
    )]
    private ?string $nom = null;

    #[ORM\Column(length: 255, nullable: true)]
    #[Groups(["getProduits"])]
    #[Assert\Length(
        max: 255,
        maxMessage: 'La description du produit ne peut pas dépasser {{ limit }} caractères'
    )]
    private ?string $description = null;

    #[ORM\Column]
    #[Groups(["getProduits"])]
    #[Assert\NotBlank(message: "Le prix du produit est obligatoire")]
    #[Assert\Positive(message: "Le prix du produit doit être positif")]
    #[Assert\Type(
        type: 'float',
        message: 'Le prix du produit doit être un nombre décimal'
    )]
    #[Assert\Range(
        min: 0,
        notInRangeMessage: 'Le prix du produit doit être supérieur ou égal à {{ min }}',
    )]
    #[Assert\Regex(
        pattern: '/^\d+(\.\d{1,2})?$/',
        message: 'Le prix du produit doit être un nombre décimal avec au maximum deux décimales'
    )]
    private ?float $prix = null;

    #[ORM\Column]
    #[Groups(["getProduits"])]
    private ?float $quantite = null;

    #[ORM\Column]
    #[Groups(["getProduits"])]
    private ?bool $disponible = null;

    #[ORM\OneToMany(mappedBy: 'produit', targetEntity: DetailsReservation::class, cascade: ['persist', 'remove'])]
    private Collection $detailsReservations;

    public function __construct()
    {
        $this->detailsReservations = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getNom(): ?string
    {
        return $this->nom;
    }

    public function setNom(string $nom): static
    {
        $this->nom = $nom;

        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): static
    {
        $this->description = $description;

        return $this;
    }

    public function getPrix(): ?float
    {
        return $this->prix;
    }

    public function setPrix(float $prix): static
    {
        $this->prix = $prix;

        return $this;
    }

    public function getQuantite(): ?float
    {
        return $this->quantite;
    }

    public function setQuantite(float $quantite): static
    {
        $this->quantite = $quantite;

        return $this;
    }

    public function isDisponible(): ?bool
    {
        return $this->disponible;
    }

    public function setDisponible(bool $disponible): static
    {
        $this->disponible = $disponible;

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
            $detailsReservation->setProduit($this);
        }

        return $this;
    }

    public function removeDetailsReservation(DetailsReservation $detailsReservation): static
    {
        if ($this->detailsReservations->removeElement($detailsReservation)) {
            // Set the owning side to null (unless already changed)
            if ($detailsReservation->getProduit() === $this) {
                $detailsReservation->setProduit(null);
            }
        }

        return $this;
    }
}
