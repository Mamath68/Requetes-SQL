-- Consigne: En écrivant toujours des requêtes SQL, modifiez la base de données comme suit :

-- A. Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus.

INSERT INTO PERSONNAGE (
    NOM_PERSONNAGE,
    ADRESSE_PERSONNAGE,
    IMAGE_PERSONNAGE,
    ID_LIEU,
    ID_SPECIALITE
) VALUES (
    'Champdeblix',
    'Ferme Hantassion',
    'indisponible.jpg',
    6,
    12
)
 -- B. Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine...
UPDATE `GAULOIS`.`AUTORISER_BOIRE` SET `ID_POTION`='1' WHERE `ID_POTION`=11 AND `ID_PERSONNAGE`=12;

-- C. Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille.
-- CORRECTION DU PROF

DELETE FROM CASQUE
WHERE
    ID_TYPE_CASQUE = (
        SELECT
            ID_TYPE_CASQUE
        FROM
            TYPE_CASQUE
        WHERE
            NOM_TYPE_CASQUE = 'Grec'
    )
    AND ID_CASQUE NOT IN (
        SELECT
            PC.ID_CASQUE
        FROM
            PRENDRE_CASQUE PC
    )
 -- D. Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate.
    UPDATE `GAULOIS`.`PERSONNAGE` SET `ADRESSE_PERSONNAGE`='en prison',
    `ID_LIEU`='9'
    WHERE
        `ID_PERSONNAGE`=23;

-- E. La potion 'Soupe' ne doit plus contenir de persil.

DELETE FROM `GAULOIS`.`COMPOSER`
WHERE
    `ID_POTION`=9
    AND `ID_INGREDIENT`=19;

-- F. Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, qu'il a pris lors de la bataille 'Attaque de la banque postale'. Corrigez son erreur !

UPDATE `GAULOIS`.`PRENDRE_CASQUE`
SET
    `ID_CASQUE`='10'
WHERE
    `ID_CASQUE`=14
    AND `ID_PERSONNAGE`=5
    AND `ID_BATAILLE`=9;

-- Bonus

-- Bonus 1
-- Adresse mail pour chaque gaulois 
-- 3 premières lettres du nom du gaulois + un point + 4 premières lettres du lieu d'habitation + "gaulois.fr" 
-- le tout en minuscule

SELECT
    NOM_PERSONNAGE AS 'Nom des Personnages',
    LOWER(CONCAT(
    LEFT(NOM_PERSONNAGE, 3), ".", LEFT(NOM_LIEU, 4), "@gaulois.fr")) AS 'Adresse mail'
FROM
    PERSONNAGE P
    INNER JOIN LIEU L
    ON P.ID_LIEU = L.ID_LIEU

 -- Bonus 2
-- Nombre de jours écoulés entre 2 batailles de votre choix 

SELECT
    "Bataille du village gaulois",
    "Attaque du bateau pirate",
    ABS(DATEDIFF((
    SELECT
        DATE_BATAILLE
    FROM
        BATAILLE
    WHERE
        NOM_BATAILLE = "Bataille du village gaulois"),
        (
            SELECT
                DATE_BATAILLE
            FROM
                BATAILLE
            WHERE
                NOM_BATAILLE = "Attaque du bateau pirate"
        ))) AS NBJOURS
          
-- Bonus 3
-- Nom des types de casque + nom des casques associés 
-- Résultat :   ----- Autre | Gallois, Ostrogoth, Spangenhelm, Wisigoth
                ----- Grec | Corinthien
                ----- Normand | A cornes, Enkomi, Picte, Veksø
                ----- Romain | Haguenau, Impérial-gaulois, Italo-celtique, Negau, Villanovien, Weisenau

SELECT tc.NOM_TYPE_CASQUE AS 'Type casque', GROUP_CONCAT(DISTINCT c.NOM_CASQUE SEPARATOR ', ') AS 'Noms casques'
FROM casque c
INNER JOIN type_casque tc ON tc.ID_TYPE_CASQUE = c.ID_TYPE_CASQUE
GROUP BY tc.NOM_TYPE_CASQUE
