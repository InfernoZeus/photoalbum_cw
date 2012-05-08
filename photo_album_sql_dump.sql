-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.1.37-1ubuntu5.1


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema photo_album
--

CREATE DATABASE IF NOT EXISTS photo_album;
USE photo_album;

--
-- Definition of table `photo_album`.`albums`
--

DROP TABLE IF EXISTS `photo_album`.`albums`;
CREATE TABLE  `photo_album`.`albums` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `owner_id` int(10) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `is_public` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_albums_1` (`owner_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `photo_album`.`albums`
--

/*!40000 ALTER TABLE `albums` DISABLE KEYS */;
LOCK TABLES `albums` WRITE;
INSERT INTO `photo_album`.`albums` VALUES  (1,1,'Plants','Plants are living organisms belonging to the kingdom Plantae. They include familiar organisms such as trees, herbs, bushes, grasses, vines, ferns, mosses, and green algae.',1),
 (2,2,'Houses','A house is a home, shelter, building or structure that is a dwelling or place for habitation by human beings.',1),
 (3,1,'Animals','Animals are a major group of mostly multicellular, eukaryotic organisms of the kingdom Animalia or Metazoa.',1),
 (4,2,'Countries','In geography, a country is a geographical region. The term is often applied to a political division or the territory of a sovereign state, or to a smaller, or former, political division of a geographical region.',0),
 (5,3,'People','A group of humans, either with unspecified traits, or specific characteristics (e.g. the people of Spain or the people of the Plains).',1),
 (6,3,'Gadgets','A gadget is a small technological object (such as a device or an appliance) that has a particular function, but is often thought of as a novelty.',1);
UNLOCK TABLES;
/*!40000 ALTER TABLE `albums` ENABLE KEYS */;


--
-- Definition of table `photo_album`.`comments`
--

DROP TABLE IF EXISTS `photo_album`.`comments`;
CREATE TABLE  `photo_album`.`comments` (
  `photo_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `comment` text NOT NULL,
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `FK_comments_2` (`user_id`),
  KEY `FK_comments_1` (`photo_id`) USING BTREE) ENGINE=MyISAM AUTO_INCREMENT=82 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `photo_album`.`comments`
--

/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
LOCK TABLES `comments` WRITE;
INSERT INTO `photo_album`.`comments` VALUES  (6,3,'Donec adipiscing sollicitudin enim',6),
 (7,1,'enean a tellus eu urna congue congue.',7),
 (8,2,'In hac habitasse platea dictumst',8),
 (9,3,'Fusce sit amet nulla',9),
 (10,1,'In vel lorem in turpis pulvinar dapibus',10),
 (11,2,'roin diam tellus, placerat vitae, fermentum a, auctor eget.',11),
 (12,3,'Donec ultrices lectus non elit. Sed nunc orci, ornare id.',12),
 (1,2,'Nutr gharture comment',13),
 (1,1,';;;;;;',17),
 (1,1,'  ',18),
 (1,1,'ahmed elhas haldfjlkajdfl ',19),
 (1,1,' Enter The Comment Here',20),
 (1,1,'  ;;;',21),
 (1,1,' Enter The Comment Here',25),
 (1,1,',',26),
 (19,1,';;;',27),
 (26,1,'ahmed test',31),
 (6,2,'Enter some comment about the picture here',33),
 (3,2,'Enter some comment about the picture here',36),
 (5,1,'Enter some comment about the picture here',55),
 (2,1,'Enter some comment about the picture here',56),
 (2,1,'Enter some comment about the picture here',57),
 (4,1,'Enter some comment about the picture here',58),
 (4,1,'Enter some comment about the elksad',59);
INSERT INTO `photo_album`.`comments` VALUES  (1,1,'dghd',67),
 (1,1,'fffffffffffffffffffffff',68),
 (1,1,'&apos; or &apos;a&apos;=&apos;a',75),
 (1,1,'&quot; or &quot;a&quot;=&quot;a',76),
 (1,1,'&apos;) or (&apos;a&apos;=&apos;a',77),
 (10,1,'sdfgsdfg',78),
 (31,1,'Looks nice!',79),
 (32,1,'',80),
 (32,1,'',81);
UNLOCK TABLES;
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;


--
-- Definition of table `photo_album`.`contact`
--

DROP TABLE IF EXISTS `photo_album`.`contact`;
CREATE TABLE  `photo_album`.`contact` (
  `issue_type` text,
  `name` text,
  `email` text,
  `text` text,
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `photo_album`.`contact`
--

/*!40000 ALTER TABLE `contact` DISABLE KEYS */;
LOCK TABLES `contact` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `contact` ENABLE KEYS */;


--
-- Definition of table `photo_album`.`permissions`
--

DROP TABLE IF EXISTS `photo_album`.`permissions`;
CREATE TABLE  `photo_album`.`permissions` (
  `album_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `type` int(1) unsigned NOT NULL,
  KEY `FK_permissions_1` (`album_id`),
  KEY `FK_permissions_2` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `photo_album`.`permissions`
--

/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
LOCK TABLES `permissions` WRITE;
INSERT INTO `photo_album`.`permissions` VALUES  (1,1,777),
 (2,2,777),
 (3,3,777),
 (4,1,777),
 (5,2,777),
 (6,3,777),
 (2,3,444),
 (3,1,444),
 (1,2,777),
 (2,1,777);
UNLOCK TABLES;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;


--
-- Definition of table `photo_album`.`photos`
--

DROP TABLE IF EXISTS `photo_album`.`photos`;
CREATE TABLE  `photo_album`.`photos` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `description` text,
  `src` varchar(255) NOT NULL,
  `album_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_photos_1` (`album_id`)
) ENGINE=MyISAM AUTO_INCREMENT=35 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `photo_album`.`photos`
--

/*!40000 ALTER TABLE `photos` DISABLE KEYS */;
LOCK TABLES `photos` WRITE;
INSERT INTO `photo_album`.`photos` VALUES  (1,'Cow','Photo of a meeeew Cow','cow.jpg',3),
 (2,'Wolf','Photo of a Wolf','wolf.jpg',3),
 (3,'Lion','Photo of a Lion','lion.jpg',3),
 (4,'Zebra','Photo of a Zebra','zebra.jpg',3),
 (5,'Mouse','Photo of a Mouse','mouse.jpg',3),
 (6,'Compass','Photo of the Compass Flower','compass.jpg',1),
 (7,'White House','Photo of the White House','whitehouse.jpg',2),
 (8,'Pan House','Photo of Pan House','panhouse.jpg',2),
 (9,'House MD','Photo of... well... House MD (still House...)','housemd.jpg',2),
 (10,'Steve Jobs','Photo of Steve Jobs','stevejobs.jpg',5),
 (11,'Bill Gates','Photo of Bill Gates','billgates.jpg',5),
 (12,'Gangsta Shoe','Photo of Gangsta Shoe','gangstashoe.jpg',6),
 (13,'iPad','Photo of iPad','ipad.jpg',6),
 (14,'Google Phone','Photo of Google Phone','googlephone.jpg',6),
 (15,'Greece','Photo of Greece','greece.jpg',4),
 (16,'Spain','Photo of Spain','spain.jpg',4),
 (17,'Indonesia','Photo of Indonesia','indonesia.jpg',4),
 (18,'United Kingdom','Photo of United Kingdom','uk.jpg',4);
UNLOCK TABLES;
/*!40000 ALTER TABLE `photos` ENABLE KEYS */;


--
-- Definition of table `photo_album`.`users`
--

DROP TABLE IF EXISTS `photo_album`.`users`;
CREATE TABLE  `photo_album`.`users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `photo_album`.`users`
--

/*!40000 ALTER TABLE `users` DISABLE KEYS */;
LOCK TABLES `users` WRITE;
INSERT INTO `photo_album`.`users` VALUES  (1,'firstuser','04f0cef3e4796f6967fd5bae6e2c9113','Mark Brown'),
 (2,'seconduser','d4865a8d699a70cf0beced66bc1d8036','John Smith'),
 (3,'thirduser','71fc0987be72fc4c5068383838d2e7a8','Joe Black');
UNLOCK TABLES;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;



# creating whccw db account

create user whccw@localhost;
set password for whccw@localhost = password('cw-whc$2012');

grant all on photo_album.* to whccw@localhost;
grant select, insert, update on photo_album.* to whccw@localhost;
