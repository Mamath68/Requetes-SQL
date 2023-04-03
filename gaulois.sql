                    -- Consignes: A partir du script SQL Gaulois fourni par votre formateur, écrivez et exécutez les requêtes SQL suivantes :
-- 1. Nom des lieux qui finissent par 'um'.

SELECT *
FROM LIEU
WHERE NOM_LIEU LIKE '%um'

    -- Correction:
-- SELECT l.nom_lieu
-- FROM lieu l
-- WHERE LOWER(l.nom_lieu) LIKE "%um"
-- ORDER BY l.nom_lieu

-- 2. Nombre de personnages par lieu (trié par nombre de personnages décroissant).

SELECT COUNT(P.ID_PERSONNAGE) AS 'Nombre de Personnages', L.NOM_LIEU AS 'Nom du Village'
FROM PERSONNAGE P
INNER JOIN LIEU L ON L.ID_LIEU = P.ID_LIEU
GROUP BY L.NOM_LIEU
ORDER BY COUNT(P.ID_PERSONNAGE) DESC

    -- Correction:
-- SELECT l.nom_lieu AS lieu, COUNT(p.id_personnage) AS 'Nombre D''Habitants'
-- FROM personnage p, lieu l
-- WHERE l.id_lieu = p.id_lieu
-- GROUP BY l.id_lieu
-- ORDER BY COUNT(p.id_personnage) DESC

-- 3. Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.

SELECT P.NOM_PERSONNAGE AS 'Nom des Personnages', S.NOM_SPECIALITE 'Nom des Spécialité', P.ADRESSE_PERSONNAGE AS 'Adresse', L.NOM_LIEU AS 'Nom du Village'
FROM PERSONNAGE P
INNER JOIN SPECIALITE S
INNER JOIN LIEU L ON L.ID_LIEU = P.ID_LIEU
ORDER BY  L.NOM_LIEU ASC, P.NOM_PERSONNAGE ASC

    -- Correction
-- SELECT p.nom_personnage AS 'Nom des Personnages', l.nom_lieu AS 'Nom des Villages', s.nom_specialite AS 'Nom des Spécialités'
-- FROM personnage p, lieu l, specialite s
-- WHERE l.id_lieu = p.id_lieu AND s.id_specialite = p.id_specialite
-- ORDER BY l.nom_lieu ASC, p.nom_personnage ASC

-- 4. Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant).

SELECT S.NOM_SPECIALITE AS 'Nom des Spécialité', COUNT(P.NOM_PERSONNAGE) AS 'Nombre de Personnages'
FROM PERSONNAGE P
INNER JOIN SPECIALITE S ON S.ID_SPECIALITE = P.ID_SPECIALITE
GROUP BY S.NOM_SPECIALITE
ORDER BY COUNT(P.NOM_PERSONNAGE) DESC

    -- Correction
-- SELECT s.nom_specialite AS 'Nom des spécialité', COUNT(p.id_personnage) AS 'Nombre de personnage'
-- FROM specialite s
-- LEFT JOIN personnage p 
-- ON s.id_specialite = p.id_specialite
-- GROUP BY s.id_specialite
-- ORDER BY COUNT(p.id_personnage) DESC

-- 5. Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa).

SELECT B.NOM_BATAILLE AS 'Nom des batailles', DATE_FORMAT(B.DATE_BATAILLE, "%d/%m/%Y") AS 'Dates des batailles', L.NOM_LIEU AS 'Lieu des batailles'
FROM BATAILLE B
INNER JOIN LIEU L
ORDER BY B.DATE_BATAILLE DESC

    -- Correction
-- SELECT b.nom_bataille AS 'Nom des Bataille', DATE_FORMAT(b.date_bataille, '%d %M -%y') AS 'Date des Batailles', l.nom_lieu AS 'Nom des Villages'
-- FROM bataille b, lieu l
-- WHERE b.id_lieu = l.id_lieu
-- ORDER BY YEAR(b.date_bataille) ASC, MONTH(b.date_bataille) DESC, DAY(b.date_bataille) DESC

-- 6. Nom des potions + coût de réalisation de la potion (trié par coût décroissant).

SELECT P.NOM_POTION AS 'Nom des potions', SUM(C.QTE*I.COUT_INGREDIENT) AS 'Coût des potions'
FROM POTION P
INNER JOIN COMPOSER C ON P.ID_POTION = C.ID_POTION
INNER JOIN INGREDIENT I ON I.ID_INGREDIENT = C.ID_INGREDIENT
GROUP BY P.NOM_POTION
ORDER BY SUM(C.QTE*I.COUT_INGREDIENT) DESC

    -- Correction

-- SELECT p.nom_potion AS 'Nom des Potions', SUM(i.cout_ingredient*c.qte) AS 'Coût des potions'
-- FROM potion p
-- LEFT JOIN composer c ON c.id_potion = p.id_potion
-- LEFT JOIN ingredient i ON c.id_ingredient = i.id_ingredient
-- GROUP BY p.id_potion
-- ORDER BY SUM(i.cout_ingredient*c.qte) DESC

-- 7. Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'.

SELECT P.NOM_POTION AS 'Nom de la potion', I.NOM_INGREDIENT AS 'Nom des ingredients', I.COUT_INGREDIENT AS 'Coûts des ingredients', C.QTE AS 'Quantité des ingredients'
FROM INGREDIENT I
INNER JOIN COMPOSER C ON I.ID_INGREDIENT = C.ID_INGREDIENT
INNER JOIN POTION P ON P.ID_POTION = C.ID_POTION
WHERE P.NOM_POTION = 'Santé'
ORDER BY I.NOM_INGREDIENT

    -- Correction

-- SELECT i.nom_ingredient AS 'Nom des Ingrédients', SUM(i.cout_ingredient*c.qte) AS 'Coûts des Ingrédients'
-- FROM potion p, composer c, ingredient i
-- WHERE p.id_potion = c.id_potion AND c.id_ingredient = i.id_ingredient AND p.nom_potion = 'Santé'
-- GROUP BY i.id_ingredient 

-- 8. Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.

SELECT B.NOM_BATAILLE AS 'Nom de la Bataille', P.NOM_PERSONNAGE AS 'Nom des Personnages', PC.QTE AS 'Nombres de Casques'
FROM PERSONNAGE P
INNER JOIN PRENDRE_CASQUE PC ON P.ID_PERSONNAGE = PC.ID_PERSONNAGE
INNER JOIN CASQUE C ON C.ID_CASQUE = PC.ID_CASQUE
INNER JOIN BATAILLE B ON B.ID_BATAILLE = PC.ID_BATAILLE
WHERE B.NOM_BATAILLE = 'Bataille du village gaulois'
ORDER BY P.NOM_PERSONNAGE

    -- Correction 1

-- SELECT p.nom_personnage AS 'Nom du Personnage', SUM(pc.qte) AS 'Quantité de casques'
-- FROM personnage p, bataille b, prendre_casque pc
-- WHERE p.id_personnage = pc.id_personnage AND pc.id_bataille = b.id_bataille AND b.nom_bataille = 'Bataille du village gaulois'
-- GROUP BY p.id_personnage
-- HAVING SUM(pc.qte) >= ALL(
-- SELECT SUM(pc.qte)
-- FROM prendre_casque pc, bataille b
-- WHERE b.id_bataille = pc.id_bataille AND b.nom_bataille = 'Bataille du village gaulois'
-- GROUP BY pc.id_personnage)

    -- Correction 2 : Alternative 1

-- SELECT p.nom_personnage, SUM(pc.qte) AS 'Quantité de casque'
-- FROM personnage p, bataille b, prendre_casque pc
-- WHERE p.id_personnage = pc.id_personnage AND pc.id_bataille = b.id_bataille AND b.nom_bataille = 'Bataille du village gaulois'
-- GROUP BY p.id_personnage
-- HAVING SUM(pc.qte) = (
-- SELECT SUM(pc.qte) AS 'Quantité de casque'
-- FROM prendre_casque pc, bataille b
-- WHERE b.id_bataille = pc.id_bataille AND b.nom_bataille = 'Bataille du village gaulois'
-- GROUP BY pc.id_personnage
-- ORDER BY SUM(pc.qte) DESC
-- LIMIT 1)

    -- Correction 3 : Alternative 2 (Avec une Wiev)
-- -CREATE VIEW qteCasquesBVG AS
-- SELECT SUM(pc.qte) AS sommeTotale
-- FROM prendre_casque pc, bataille b
-- WHERE b.id_bataille = pc.id_bataille AND b.nom_bataille = 'Bataille du village gaulois'
-- GROUP BY pc.id_personnage 
-- -- puis
-- SELECT p.nom_personnage, SUM(pc.qte) AS nb_casques
-- FROM personnage p, bataille b, prendre_casque pc
-- WHERE p.id_personnage = pc.id_personnage AND pc.id_bataille = b.id_bataille AND b.nom_bataille = 'Bataille du village gaulois'
-- GROUP BY p.id_personnage
-- HAVING nb_casques >= ALL (
-- SELECT sommeTotale
-- FROM qteCasquesBVG)

 -- 9. Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).
                                SELECT
                                    P.NOM_PERSONNAGE AS 'Nom des Personnages',
                                    B.DOSE_BOIRE AS 'Dose de potion Bue'
                                FROM
                                    PERSONNAGE P
                                    INNER JOIN BOIRE B
                                    ON P.ID_PERSONNAGE = B.ID_PERSONNAGE
                                ORDER BY
                                    B.DOSE_BOIRE DESC
 -- 10. Nom de la bataille où le nombre de casques pris a été le plus important.
                                    SELECT
                                        B.NOM_BATAILLE AS 'Nom de la bataille'
                                    FROM
                                        BATAILLE B
                                        INNER JOIN PRENDRE_CASQUE PC
                                        ON B.ID_BATAILLE = PC.ID_BATAILLE
                                    WHERE
                                        PC.QTE >'50'
 -- 11. Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)
                                        SELECT
                                            TC.NOM_TYPE_CASQUE AS 'Type de casque',
                                            COUNT(C.ID_CASQUE) AS 'Nombre de casque',
                                            SUM(C.COUT_CASQUE) AS 'Prix des Casques'
                                        FROM
                                            TYPE_CASQUE TC
                                            INNER JOIN CASQUE C
                                            ON TC.ID_TYPE_CASQUE = C.ID_TYPE_CASQUE
                                        GROUP BY
                                            TC.NOM_TYPE_CASQUE
                                        ORDER BY
                                            'Nombre de casque' DESC
 -- 12. Nom des potions dont un des ingrédients est le poisson frais.
                                            SELECT
                                                P.NOM_POTION AS 'Nom de potion'
                                            FROM
                                                POTION P
                                                INNER JOIN COMPOSER C
                                                ON P.ID_POTION = C.ID_POTION
                                                INNER JOIN INGREDIENT I
                                                ON I.ID_INGREDIENT = C.ID_INGREDIENT
                                            WHERE
                                                I.NOM_INGREDIENT = 'Poisson frais'
 -- 13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.
                                                SELECT
                                                    L.NOM_LIEU AS 'Nom de Village',
                                                    COUNT(P.ID_PERSONNAGE) AS 'Nombre D''habitant'
                                                FROM
                                                    LIEU L
                                                    INNER JOIN PERSONNAGE P
                                                    ON L.ID_LIEU = P.ID_LIEU
                                                WHERE
                                                    L.NOM_LIEU != 'Village gaulois'
                                                GROUP BY
                                                    L.NOM_LIEU
                                                HAVING
                                                    COUNT(P.ID_PERSONNAGE) >= ALL (
                                                        SELECT
                                                            COUNT(P2.ID_PERSONNAGE)
                                                        FROM
                                                            PERSONNAGE P2
                                                            INNER JOIN LIEU L2
                                                            ON P2.ID_LIEU = L2.ID_LIEU
                                                        WHERE
                                                            L2.NOM_LIEU != 'Village gaulois'
                                                        GROUP BY
                                                            L2.ID_LIEU
                                                    )
                                                ORDER BY
                                                    COUNT(P.ID_PERSONNAGE) DESC
 -- 14. Nom des personnages qui n'ont jamais bu aucune potion.
                                                    SELECT
                                                        P.NOM_PERSONNAGE AS 'Nom des personnages'
                                                    FROM
                                                        PERSONNAGE P
                                                        LEFT OUTER JOIN BOIRE B
                                                        ON P.ID_PERSONNAGE = B.ID_PERSONNAGE
                                                    WHERE
                                                        B.ID_PERSONNAGE IS NULL
 -- 15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.
                                                        SELECT
                                                            P.NOM_PERSONNAGE AS 'Nom des personnages'
                                                        FROM
                                                            PERSONNAGE P
                                                            INNER JOIN POTION PO
                                                            LEFT OUTER JOIN AUTORISER_BOIRE AB
                                                            ON P.ID_PERSONNAGE = AB.ID_PERSONNAGE
                                                        WHERE
                                                            AB.ID_PERSONNAGE IS NULL
                                                            AND PO.NOM_POTION = 'Magique'