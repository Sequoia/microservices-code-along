-- phpMyAdmin SQL Dump
-- version 3.5.5
-- http://www.phpmyadmin.net
--
-- Host: sql3.freemysqlhosting.net
-- Generation Time: Jun 02, 2017 at 07:39 PM
-- Server version: 5.5.49-0ubuntu0.12.04.1
-- PHP Version: 5.3.28

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `sql3177971`
--

-- --------------------------------------------------------

--
-- Table structure for table `Authors`
--

CREATE TABLE IF NOT EXISTS `Authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=33 ;

--
-- Dumping data for table `Authors`
--

INSERT INTO `Authors` (`id`, `name`) VALUES
(1, 'Various Authors'),
(2, 'C. W. WOLF'),
(3, 'E. T. A. HOFFMANN'),
(4, 'Benito PÉREZ GALDÓS'),
(5, 'Karl MARX'),
(6, 'Pedro Antonio de ALARCÓN Y ARIZA'),
(7, 'VARIOUS'),
(8, 'Johnston MCCULLEY'),
(9, 'Jules VERNE'),
(10, 'A. J. EVANS'),
(11, 'Stanisław PRZYBYSZEWSKI'),
(12, 'Justus van MAURIK'),
(13, 'Francis Bond HEAD'),
(14, 'UNKNOWN'),
(15, 'James Whitcomb RILEY'),
(16, 'James Hartwell WILLARD'),
(17, 'Andrew LANG'),
(18, 'Elizabeth Thompson DILLINGHAM'),
(19, 'Olive Beaupre MILLER'),
(20, 'ANONYMOUS'),
(21, 'Hans Christian ANDERSEN'),
(22, 'Helen Hunt JACKSON'),
(23, 'Hilaire BELLOC'),
(24, 'Alicia Stuart ASPINWALL'),
(25, 'Edward LEAR'),
(26, 'Mark TWAIN'),
(27, 'Covington CLARKE'),
(28, 'Anatole FRANCE'),
(29, 'Dinah Maria Mulock CRAIK'),
(30, 'Thornton W. BURGESS'),
(31, 'Carlo COLLODI'),
(32, 'Waldemar BONSELS');

-- --------------------------------------------------------

--
-- Table structure for table `Books`
--

CREATE TABLE IF NOT EXISTS `Books` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `thumbnail` varchar(512) NOT NULL,
  `author_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `filepath` varchar(512) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=48 ;

--
-- Dumping data for table `Books`
--

INSERT INTO `Books` (`id`, `title`, `thumbnail`, `author_id`, `language_id`, `filepath`) VALUES
(1, 'After Wapiti in Wyoming (in  American Big-Game Hunting )', 'americanbiggamehunting_1603_thumb.jpg', 1, 1, 'After_Wapiti_in_Wyoming_(in__American_Big-Game_Hunting_).txt'),
(2, 'Apis Mellifica', 'apis_mellifica_1303_thumb.jpg', 2, 1, 'Apis_Mellifica.txt'),
(3, 'Auswahl aus Die Serapionsbrüder', 'serapionsbrueder_1204_thumb.jpg', 3, 2, 'Auswahl_aus_Die_Serapionsbrüder.txt'),
(4, 'La Batalla de los Arapiles', 'batalla_arapiles_1302_thumb.jpg', 4, 3, 'La_Batalla_de_los_Arapiles.txt'),
(5, 'Capital: a critical analysis of capitalist production, Vol 1', 'Capital_Vol1_1201_thumb.jpg', 5, 1, 'Capital:_a_critical_analysis_of_capitalist_production,_Vol_1.txt'),
(6, 'El Capitán Veneno', 'Capitan_Veneno_1209_thumb.jpg', 6, 3, 'El_Capitán_Veneno.txt'),
(7, 'Winter: Reportagen - Kapitel 2 (in  Christmas Short Works Collection 2015 )', 'csw15_1512_thumb.jpg', 7, 4, 'Winter:_Reportagen_-_Kapitel_2_(in__Christmas_Short_Works_Collection_2015_).txt'),
(8, 'Papillon, Le (in  Compilation de poèmes - 003 )', 'Compilation_poemes_003_1209_thumb.jpg', 7, 5, 'Papillon,_Le_(in__Compilation_de_poèmes_-_003_).txt'),
(9, 'The Curse of Capistrano', 'Curse_of_Capistrano_1009_thumb.jpg', 8, 1, 'The_Curse_of_Capistrano.txt'),
(10, 'The Curse of Capistrano', 'book-cover-in-progress-65x65.gif', 8, 1, 'The_Curse_of_Capistrano.txt'),
(11, 'Les Enfants du capitaine Grant', 'capitainegrant_1115_thumb.jpg', 9, 5, 'Les_Enfants_du_capitaine_Grant.txt'),
(12, 'The Escaping Club', 'escapingclub_1205_thumb.jpg', 10, 1, 'The_Escaping_Club.txt'),
(13, 'Das Feuer: Kapitel 1 (in  First World War Centenary Prose Collection Vol. I )', 'ww1coll_prose1_1407_thumb.jpg', 7, 4, 'Das_Feuer:_Kapitel_1_(in__First_World_War_Centenary_Prose_Collection_Vol._I_).txt'),
(14, 'Homo sapiens - Romantrilogie', 'homosapiens_1508_thumb.jpg', 11, 2, 'Homo_sapiens_-_Romantrilogie.txt'),
(15, 'De Kinderen van Kapitein Grant', 'book-cover-in-progress-65x65.gif', 9, 6, 'De_Kinderen_van_Kapitein_Grant.txt'),
(16, '''t Café ''Goenong-Api'' (in  Korte Werken van Justus van Maurik )', 'maurik_1212_thumb.jpg', 12, 6, '''t_Café_''Goenong-Api''_(in__Korte_Werken_van_Justus_van_Maurik_).txt'),
(17, 'Bestiaries and Lapidaries (in  Library of the World''s Best Literature, Ancient and Modern, volume 4 )', 'library_world_4_1306_thumb.jpg', 7, 1, 'Bestiaries_and_Lapidaries_(in__Library_of_the_World''s_Best_Literature,_Ancient_and_Modern,_volume_4_).txt'),
(18, 'Kapitel 6 aus Die Offenbarung des Johannes (in  LibriVox 6th Anniversary Collection )', '6th_anniversary_1208_thumb.jpg', 7, 4, 'Kapitel_6_aus_Die_Offenbarung_des_Johannes_(in__LibriVox_6th_Anniversary_Collection_).txt'),
(19, 'Un tuteur embarrassé - Chapitre 1 (in  Multilingual 1910 Collection )', 'multi_1910_collection_1210_thumb.jpg', 7, 4, 'Un_tuteur_embarrassé_-_Chapitre_1_(in__Multilingual_1910_Collection_).txt'),
(20, 'A Likeness: Portrait Bust of an Unknown, Capitol, Rome (in  Poetry Miscellany 01 )', 'Poetry_Miscellany_01_1207_thumb.jpg', 7, 1, 'A_Likeness:_Portrait_Bust_of_an_Unknown,_Capitol,_Rome_(in__Poetry_Miscellany_01_).txt'),
(21, 'Apik (in  Puisi dari Indonesia )', 'Puisi_dari_Indonesia_1201_thumb.jpg', 7, 4, 'Apik_(in__Puisi_dari_Indonesia_).txt'),
(22, 'Rough Notes Taken During Some Rapid Journeys Across the Pampas and Among the Andes', 'book_roughnotes_1412_thumb.jpg', 13, 1, 'Rough_Notes_Taken_During_Some_Rapid_Journeys_Across_the_Pampas_and_Among_the_Andes.txt'),
(23, '''Bow, Wow'' Says the Dog (in  In the Nursery of My Bookhouse )', 'in_the_nursery_1302_thumb.jpg', 14, 1, '''Bow,_Wow''_Says_the_Dog_(in__In_the_Nursery_of_My_Bookhouse_).txt'),
(24, '''It'' (in  In the Nursery of My Bookhouse )', 'in_the_nursery_1302_thumb.jpg', 15, 1, '''It''_(in__In_the_Nursery_of_My_Bookhouse_).txt'),
(25, 'A Farmer''s Wife, The Story of Ruth (in  Children''s Short Works, Vol. 005 )', 'short_child_5_1101_thumb.jpg', 16, 1, 'A_Farmer''s_Wife,_The_Story_of_Ruth_(in__Children''s_Short_Works,_Vol._005_).txt'),
(26, 'A Fish Tale (in  Cocoa Break Collection, Vol. 01 )', 'Cocoa_Break_001_1208_thumb.jpg', 17, 1, 'A_Fish_Tale_(in__Cocoa_Break_Collection,_Vol._01_).txt'),
(27, 'A Halloween Story (in  In the Nursery of My Bookhouse )', 'in_the_nursery_1302_thumb.jpg', 18, 1, 'A_Halloween_Story_(in__In_the_Nursery_of_My_Bookhouse_).txt'),
(28, 'A Happy Day in the City (in  In the Nursery of My Bookhouse )', 'in_the_nursery_1302_thumb.jpg', 19, 1, 'A_Happy_Day_in_the_City_(in__In_the_Nursery_of_My_Bookhouse_).txt'),
(29, 'A kis kakas gyémánt félkrajcárja (in  Multilingual Fairy Tale Collection 003 )', 'multilingual_fairytale_collection_003_1008_thumb.jpg', 20, 4, 'A_kis_kakas_gyémánt_félkrajcárja_(in__Multilingual_Fairy_Tale_Collection_003_).txt'),
(30, 'A Leaf from Heaven (in  Hans Christian Andersen Fairy Tale Collection )', 'fairytales_andersen_thumb.jpg', 21, 1, 'A_Leaf_from_Heaven_(in__Hans_Christian_Andersen_Fairy_Tale_Collection_).txt'),
(31, 'A Letter From a Cat (in  In the Nursery of My Bookhouse )', 'in_the_nursery_1302_thumb.jpg', 22, 1, 'A_Letter_From_a_Cat_(in__In_the_Nursery_of_My_Bookhouse_).txt'),
(32, 'A Moral Alphabet (in  Children''s Short Works, Vol. 007 )', 'short_child_7_1101_thumb.jpg', 23, 1, 'A_Moral_Alphabet_(in__Children''s_Short_Works,_Vol._007_).txt'),
(33, 'A Psalm of Praise (Psalm 100) (in  In the Nursery of My Bookhouse )', 'in_the_nursery_1302_thumb.jpg', 14, 1, 'A_Psalm_of_Praise_(Psalm_100)_(in__In_the_Nursery_of_My_Bookhouse_).txt'),
(34, 'A Quick Running Squash (in  In the Nursery of My Bookhouse )', 'in_the_nursery_1302_thumb.jpg', 24, 1, 'A_Quick_Running_Squash_(in__In_the_Nursery_of_My_Bookhouse_).txt'),
(35, 'A Sea-Song From the Shore (in  In the Nursery of My Bookhouse )', 'in_the_nursery_1302_thumb.jpg', 15, 1, 'A_Sea-Song_From_the_Shore_(in__In_the_Nursery_of_My_Bookhouse_).txt'),
(36, 'A Selection of Limericks (in  Children''s Short Works, Vol. 005 )', 'short_child_5_1101_thumb.jpg', 25, 1, 'A_Selection_of_Limericks_(in__Children''s_Short_Works,_Vol._005_).txt'),
(37, 'Die Abenteuer Tom Sawyers', 'abenteuertomsawyer_1205_thumb.jpg', 26, 2, 'Die_Abenteuer_Tom_Sawyers.txt'),
(38, 'Die Abenteuer Tom Sawyers (Duett)', 'book-cover-in-progress-65x65.gif', 26, 2, 'Die_Abenteuer_Tom_Sawyers_(Duett).txt'),
(39, 'Aces Up', 'book-cover-in-progress-65x65.gif', 27, 1, 'Aces_Up.txt'),
(40, 'Across the Fields (in  In the Nursery of My Bookhouse )', 'in_the_nursery_1302_thumb.jpg', 28, 1, 'Across_the_Fields_(in__In_the_Nursery_of_My_Bookhouse_).txt'),
(41, 'Adventures of a Brownie as Told to my Child', 'Adventures_Brownie_Told_My_Child_1201_thumb.jpg', 29, 1, 'Adventures_of_a_Brownie_as_Told_to_my_Child.txt'),
(42, 'Adventures of Huckleberry Finn', 'Huck_Finn_thumb.jpg', 26, 1, 'Adventures_of_Huckleberry_Finn.txt'),
(43, 'Adventures of Huckleberry Finn (version 3)', 'Adventures_Huckleberry_Finn_V3_1203_thumb.jpg', 26, 1, 'Adventures_of_Huckleberry_Finn_(version_3).txt'),
(44, 'The Adventures of Johnny Chuck', 'adventures_johnny_chuck_1009_thumb.jpg', 30, 1, 'The_Adventures_of_Johnny_Chuck.txt'),
(45, 'The Adventures of Maya the Bee', 'Adventures_Maya_Bee_1202_thumb.jpg', 32, 1, 'The_Adventures_of_Maya_the_Bee.txt'),
(46, 'The Adventures of Paddy Beaver', 'adventures_paddy_beaver_1009_thumb.jpg', 30, 1, 'The_Adventures_of_Paddy_Beaver.txt'),
(47, 'The Adventures of Pinocchio', 'adventurespinocchio_1009_thumb.jpg', 31, 1, 'The_Adventures_of_Pinocchio.txt');

-- --------------------------------------------------------

--
-- Table structure for table `Languages`
--

CREATE TABLE IF NOT EXISTS `Languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;

--
-- Dumping data for table `Languages`
--

INSERT INTO `Languages` (`id`, `name`) VALUES
(1, 'English'),
(2, 'German'),
(3, 'Spanish'),
(4, 'Multilingual'),
(5, 'French'),
(6, 'Dutch');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
