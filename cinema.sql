-- Réalisez les requêtes SQL suivantes avec PhpMyAdmin (rédigez les requêtes dans un document Word afin de garder un historique de celles-ci) : entre parenthèse les champs servant de référence aux requêtes.

-- a. Informations d’un film (id_film) : titre, année, durée (au format HH:MM) et réalisateur

SELECT f.id_film AS 'Id du film', f.titre AS 'Titre de film', DATE_FORMAT(f.date_sortie, '%Y') AS 'Date de sortie', SEC_TO_TIME(f.duree*60) AS 'Durée du film', CONCAT(r.prenom,' ',r.nom) AS 'Réalisateur'
FROM realisateur r
INNER JOIN film f ON r.id_realisateur = f.id_realisateur
WHERE f.id_film = 2
ORDER BY f.id_film

-- b. Liste des films dont la durée excède 2h15 classés par durée (du plus long au plus court)

SELECT f.titre AS 'Titre de film', SEC_TO_TIME(f.duree*60) AS 'Durée du film'
FROM film f
WHERE f.duree > 135
ORDER BY SEC_TO_TIME(f.duree*60) DESC

-- c. Liste des films d’un réalisateur (en précisant l’année de sortie)

SELECT f.titre AS 'Titre de film',CONCAT(r.prenom,' ',r.nom) AS 'Réalisateur' ,DATE_FORMAT(f.date_sortie, '%Y') AS 'Date de sortie'
FROM film f
INNER JOIN realisateur r
ON f.id_realisateur = r.id_realisateur
WHERE r.id_realisateur = 4
ORDER BY DATE_FORMAT(f.date_sortie, '%Y')

-- d. Nombre de films par genre (classés dans l’ordre décroissant)

SELECT COUNT(f.id_film) AS 'nombre de film', g.libelle AS 'genre'
FROM genre g
INNER JOIN lien_genre_film lgf
ON g.id_genre = lgf.id_genre
INNER join film f
ON f.id_film = lgf.id_film
GROUP BY g.libelle
ORDER BY COUNT(f.id_film) DESC

-- e. Nombre de films par réalisateur (classés dans l’ordre décroissant)

SELECT COUNT(f.id_film) AS 'nombre de film', CONCAT(r.prenom,' ',r.nom) AS 'Réalisateur'
FROM realisateur r
INNER join film f
ON r.id_realisateur = f.id_realisateur
GROUP BY CONCAT(r.prenom,' ',r.nom)
ORDER BY COUNT(f.id_film) DESC


-- f. Casting d’un film en particulier (id_film) : nom, prénom des acteurs + sexe

SELECT f.id_film AS 'ID du Film', f.titre AS 'Titre du film', CONCAT(a.prenom,' ',a.nom) as 'Acteurs', a.sexe AS 'Genre'
FROM film f
INNER join casting c
ON f.id_film = c.id_film
INNER JOIN acteur a
ON a.id_acteur = c.id_acteur
WHERE f.id_film = 12

-- g. Films tournés par un acteur en particulier (id_acteur) avec leur rôle et l’année de sortie (du film le plus récent au plus ancien)

SELECT a.id_acteur AS 'ID de l''acteur', f.titre AS 'Titre du film', CONCAT(r.prenom,' ',r.nom) AS 'Rôle' ,DATE_FORMAT(f.date_sortie, '%Y') AS 'Année de sortie'
FROM film f
INNER join casting c
ON f.id_film = c.id_film
INNER JOIN acteur a
ON a.id_acteur = c.id_acteur
INNER JOIN role r
ON r.id_role = c.id_role
WHERE a.id_acteur = 28
ORDER BY DATE_FORMAT(f.date_sortie, '%Y') DESC	

-- h. Listes des personnes qui sont à la fois acteurs et réalisateurs

SELECT CONCAT(a.prenom,' ',a.nom) AS 'Personnes'
FROM casting c
INNER JOIN acteur a
ON a.id_acteur = c.id_acteur
INNER JOIN film f
ON f.id_film = c.id_film
INNER JOIN realisateur r
ON r.id_realisateur = f.id_realisateur
WHERE CONCAT(a.prenom,' ',a.nom) = CONCAT(r.prenom,' ',r.nom)

-- i. Liste des films qui ont moins de 5 ans (classés du plus récent au plus ancien)

SELECT f.titre AS 'Titre du film', DATE_FORMAT(f.date_sortie, '%Y') AS 'Année de sortie'
FROM film f
WHERE DATE_FORMAT(f.date_sortie, '%Y') >= 2018
ORDER BY DATE_FORMAT(f.date_sortie, '%Y') DESC	

-- j. Nombre d’hommes et de femmes parmi les acteurs

SELECT a.sexe AS 'Genres', COUNT(a.sexe) AS 'Nombres'
FROM acteur a
GROUP BY a.sexe

-- k. Liste des acteurs ayant plus de 50 ans (âge révolu et non révolu)

SELECT  CONCAT(a.prenom,' ',a.nom) AS 'Prénom et Nom' ,
CASE 
    WHEN a.date_mort IS NULL
        THEN DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), a.date_naissance)), '%Y') + 0
	ELSE TIMESTAMPDIFF(YEAR, a.date_naissance, a.date_mort) 
END AS Age
FROM acteur a
where CASE 
        WHEN a.date_mort IS NULL
            THEN DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), a.date_naissance)), '%Y') + 0
	    ELSE TIMESTAMPDIFF(YEAR, a.date_naissance, a.date_mort)
       END >=50
ORDER BY Age DESC

-- l. Acteurs ayant joué dans 3 films ou plus

SELECT CONCAT(a.prenom,' ',a.nom) AS 'Acteurs', COUNT(c.id_film) AS 'nombres de film'
FROM acteur a
INNER JOIN casting c 
ON a.id_acteur = c.id_acteur
GROUP BY CONCAT(a.prenom,' ',a.nom)
HAVING COUNT(c.id_film) >=3