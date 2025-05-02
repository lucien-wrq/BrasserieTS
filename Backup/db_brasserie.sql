-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : jeu. 10 avr. 2025 à 14:52
-- Version du serveur : 8.0.31
-- Version de PHP : 8.0.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `db_brasserie`
--

-- --------------------------------------------------------

--
-- Structure de la table `details_reservation`
--

DROP TABLE IF EXISTS `details_reservation`;
CREATE TABLE IF NOT EXISTS `details_reservation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `reservation_id` int NOT NULL,
  `produit_id` int NOT NULL,
  `quantite` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_29B263AAB83297E7` (`reservation_id`),
  KEY `IDX_29B263AAF347EFB` (`produit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `details_reservation`
--

INSERT INTO `details_reservation` (`id`, `reservation_id`, `produit_id`, `quantite`) VALUES
(1, 1, 1, 10),
(2, 1, 2, 5),
(3, 2, 3, 15);

-- --------------------------------------------------------

--
-- Structure de la table `doctrine_migration_versions`
--

DROP TABLE IF EXISTS `doctrine_migration_versions`;
CREATE TABLE IF NOT EXISTS `doctrine_migration_versions` (
  `version` varchar(191) COLLATE utf8mb3_unicode_ci NOT NULL,
  `executed_at` datetime DEFAULT NULL,
  `execution_time` int DEFAULT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `doctrine_migration_versions`
--

INSERT INTO `doctrine_migration_versions` (`version`, `executed_at`, `execution_time`) VALUES
('DoctrineMigrations\\Version20250404081822', '2025-04-10 14:42:34', 227),
('DoctrineMigrations\\Version20250406212005', '2025-04-10 14:42:34', 12),
('DoctrineMigrations\\Version20250410143859', '2025-04-10 14:42:34', 280);

-- --------------------------------------------------------

--
-- Structure de la table `produit`
--

DROP TABLE IF EXISTS `produit`;
CREATE TABLE IF NOT EXISTS `produit` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `prix` double NOT NULL,
  `quantite` double NOT NULL,
  `disponible` tinyint(1) NOT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `produit`
--

INSERT INTO `produit` (`id`, `nom`, `description`, `prix`, `quantite`, `disponible`, `image_url`) VALUES
(1, 'Bière Blonde', 'Légère et rafraîchissante, la bière blonde de la Brasserie Terroir & Saveurs séduit par son\néquilibre parfait entre douceur et amertume. Brassée avec des malts soigneusement\nsélectionnés et des houblons aromatiques, elle offre des notes subtiles de céréal', 5.99, 100, 1, '/images/biere_blonde.png'),
(2, 'Bière Brune', 'Riche et intense, la bière brune de la Brasserie Terroir & Saveurs dévoile une palette de\nsaveurs profondes. Ses malts torréfiés révèlent des arômes de chocolat noir, de caramel\net une légère pointe de café. Sa texture ronde et son caractère généreux en f', 6.49, 50, 1, '/images/biere_brune.png'),
(3, 'Bière IPA', 'Audacieuse et aromatique, la bière IPA (India Pale Ale) de la Brasserie Terroir & Saveurs\nse distingue par ses houblons expressifs et son amertume affirmée. Elle libère des\narômes intenses d’agrumes, de fruits tropicaux et de résine de pin. Avec son profi', 7.99, 30, 1, '/images/biere_ipa.png'),
(4, 'Whisky', 'Le whisky de la Brasserie Terroir & Saveurs est un hommage à l’artisanat et au terroir.\r\nDistillé avec soin et vieilli en fûts de chêne, il révèle une richesse aromatique\r\nexceptionnelle : des notes de vanille, d’épices douces, de fruits secs et une point', 70, 10, 1, '/images/whiskey.png'),
(5, 'Gin', 'Ce gin artisanal signé Brasserie Terroir & Saveurs est une véritable ode à la nature.\r\nÉlaboré à partir de plantes aromatiques locales et d’épices soigneusement sélectionnées,\r\nil combine des notes fraîches de genièvre, des zestes d’agrumes et des touches', 40, 100, 1, '/images/gin.png');

-- --------------------------------------------------------

--
-- Structure de la table `reservation`
--

DROP TABLE IF EXISTS `reservation`;
CREATE TABLE IF NOT EXISTS `reservation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `utilisateur_id` int DEFAULT NULL,
  `date` datetime NOT NULL,
  `status_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_42C84955FB88E14F` (`utilisateur_id`),
  KEY `IDX_42C849556BF700BD` (`status_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `reservation`
--

INSERT INTO `reservation` (`id`, `utilisateur_id`, `date`, `status_id`) VALUES
(1, 1, '2025-04-01 12:00:00', 1),
(2, 2, '2025-04-02 14:00:00', 2);

-- --------------------------------------------------------

--
-- Structure de la table `role`
--

DROP TABLE IF EXISTS `role`;
CREATE TABLE IF NOT EXISTS `role` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `role`
--

INSERT INTO `role` (`id`, `role`) VALUES
(1, 'Utilisateur'),
(2, 'Administrateur');

-- --------------------------------------------------------

--
-- Structure de la table `status`
--

DROP TABLE IF EXISTS `status`;
CREATE TABLE IF NOT EXISTS `status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `etat` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `status`
--

INSERT INTO `status` (`id`, `etat`) VALUES
(1, 'En attente'),
(2, 'Confirmée'),
(3, 'Annulée');

-- --------------------------------------------------------

--
-- Structure de la table `utilisateur`
--

DROP TABLE IF EXISTS `utilisateur`;
CREATE TABLE IF NOT EXISTS `utilisateur` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prenom` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mdp` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_1D1C63B3D60322AC` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `utilisateur`
--

INSERT INTO `utilisateur` (`id`, `nom`, `prenom`, `email`, `mdp`, `role_id`) VALUES
(1, 'Dupont', 'Jean', 'jean.dupont@example.com', '$2y$10$5LWX8mDp0VxQx33Yg.EIMeFMH/YjAvx5MgAJZeUlfIrYx/q14kuzm', 1),
(2, 'Durand', 'Marie', 'marie.durand@example.com', '$2y$10$CfLFhdteCcE/gm18dCH4W.m0JkP9Z9/WfkITv1oPWEuGCrw69l5QS', 2);

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `details_reservation`
--
ALTER TABLE `details_reservation`
  ADD CONSTRAINT `FK_29B263AAB83297E7` FOREIGN KEY (`reservation_id`) REFERENCES `reservation` (`id`),
  ADD CONSTRAINT `FK_29B263AAF347EFB` FOREIGN KEY (`produit_id`) REFERENCES `produit` (`id`);

--
-- Contraintes pour la table `reservation`
--
ALTER TABLE `reservation`
  ADD CONSTRAINT `FK_42C849556BF700BD` FOREIGN KEY (`status_id`) REFERENCES `status` (`id`),
  ADD CONSTRAINT `FK_42C84955FB88E14F` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateur` (`id`);

--
-- Contraintes pour la table `utilisateur`
--
ALTER TABLE `utilisateur`
  ADD CONSTRAINT `FK_1D1C63B3D60322AC` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
