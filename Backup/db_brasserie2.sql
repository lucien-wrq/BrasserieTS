-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mer. 07 mai 2025 à 07:03
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
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `details_reservation`
--

INSERT INTO `details_reservation` (`id`, `reservation_id`, `produit_id`, `quantite`) VALUES
(1, 1, 1, 10),
(2, 1, 2, 5),
(3, 2, 3, 15),
(6, 4, 1, 10),
(7, 4, 2, 5),
(8, 4, 5, 10),
(9, 5, 4, 10),
(10, 5, 2, 5),
(11, 5, 5, 10);

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
('DoctrineMigrations\\Version20250410143859', '2025-04-10 14:42:34', 280),
('DoctrineMigrations\\Version20250427182222', '2025-04-27 18:22:36', 144),
('DoctrineMigrations\\Version20250427184447', '2025-04-27 18:44:52', 42);

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `produit`
--

INSERT INTO `produit` (`id`, `nom`, `description`, `prix`, `quantite`, `disponible`) VALUES
(1, 'Bière Blonde', 'Légère et rafraîchissante, la bière blonde de la Brasserie Terroir & Saveurs séduit par son\néquilibre parfait entre douceur et amertume. Brassée avec des malts soigneusement\nsélectionnés et des houblons aromatiques, elle offre des notes subtiles de céréal', 5.99, 162, 1),
(2, 'Bière Brune', 'Riche et intense, la bière brune de la Brasserie Terroir & Saveurs dévoile une palette de\nsaveurs profondes. Ses malts torréfiés révèlent des arômes de chocolat noir, de caramel\net une légère pointe de café. Sa texture ronde et son caractère généreux en f', 6.49, 50, 1),
(3, 'Bière IPA', 'Audacieuse et aromatique, la bière IPA (India Pale Ale) de la Brasserie Terroir & Saveurs\nse distingue par ses houblons expressifs et son amertume affirmée. Elle libère des\narômes intenses d’agrumes, de fruits tropicaux et de résine de pin. Avec son profi', 7.99, 30, 1),
(4, 'Whisky', 'Le whisky de la Brasserie Terroir & Saveurs est un hommage à l’artisanat et au terroir.\r\nDistillé avec soin et vieilli en fûts de chêne, il révèle une richesse aromatique\r\nexceptionnelle : des notes de vanille, d’épices douces, de fruits secs et une point', 70, 10, 1),
(5, 'Gin', 'Ce gin artisanal signé Brasserie Terroir & Saveurs est une véritable ode à la nature.\r\nÉlaboré à partir de plantes aromatiques locales et d’épices soigneusement sélectionnées,\r\nil combine des notes fraîches de genièvre, des zestes d’agrumes et des touches', 40, 100, 1);

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
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `reservation`
--

INSERT INTO `reservation` (`id`, `utilisateur_id`, `date`, `status_id`) VALUES
(1, 1, '2025-04-01 12:00:00', 1),
(2, 2, '2025-04-02 14:00:00', 3),
(4, 1, '2025-04-25 14:00:00', 2),
(5, 2, '2025-04-10 14:00:00', 1);

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
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `roles` json NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_IDENTIFIER_EMAIL` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `utilisateur`
--

INSERT INTO `utilisateur` (`id`, `nom`, `prenom`, `email`, `password`, `roles`) VALUES
(1, 'Dupont', 'Jean', 'jean.dupont@example.com', '$2y$10$5LWX8mDp0VxQx33Yg.EIMeFMH/YjAvx5MgAJZeUlfIrYx/q14kuzm', '[\"ROLE_USER\"]'),
(2, 'Durand', 'Marie', 'marie.durand@example.com', '$2y$10$CfLFhdteCcE/gm18dCH4W.m0JkP9Z9/WfkITv1oPWEuGCrw69l5QS', '[\"ROLE_USER\"]'),
(5, 'adminNom', 'adminPrenom', 'admin.admin@example.com', '$2y$10$zADfFNyYy38w.fSF6TS8wOEGY9.GkKnaV4WVFwIQYjnj4zLOwNSEi', '[\"ROLE_ADMIN\"]'),
(6, 'clientNom', 'clientPrenom', 'client.client@example.com', '$2y$10$YRGWbChgzXmEby.xnLIw8ulgcVWYwxjbAp.6ZKmkP.bjDFNtOVfSG', '[\"ROLE_USER\"]'),
(11, 'testNom', 'testPrenom', 'test.test@example.com', '$2y$10$rwXDF.6T06D1FN5D8RFzjeF4oJ8AXpQIySh0mY3xxzwWV.Wm3hVdy', '[\"ROLE_USER\"]');

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
