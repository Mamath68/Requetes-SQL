-- 1. Nom des lieux qui finissent par 'um' (trié par ordre alphabétique).
SELECT
    L.NOM_LIEU
FROM
    LIEU L
WHERE
    LOWER(L.NOM_LIEU) LIKE "%um"
ORDER BY
    L.NOM_LIEU
 -- 2. Nombre de personnages par lieu (trié par nombre de personnages décroissant).
    SELECT
        L.NOM_LIEU AS LIEU,
        COUNT(P.ID_PERSONNAGE) AS NB_HABITANTS
    FROM
        PERSONNAGE P,
        LIEU L
    WHERE
        L.ID_LIEU = P.ID_LIEU
    GROUP BY
        L.ID_LIEU
    ORDER BY
        NB_HABITANTS DESC
 -- 3. Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.
        SELECT
            P.NOM_PERSONNAGE,
            L.NOM_LIEU,
            S.NOM_SPECIALITE
        FROM
            PERSONNAGE P,
            LIEU L,
            SPECIALITE S
        WHERE
            L.ID_LIEU = P.ID_LIEU
            AND S.ID_SPECIALITE = P.ID_SPECIALITE
        ORDER BY
            L.NOM_LIEU ASC,
            P.NOM_PERSONNAGE ASC
 -- 4. Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant).
            SELECT
                S.NOM_SPECIALITE,
                COUNT(P.ID_PERSONNAGE) AS NB_PERSONNAGES
            FROM
                SPECIALITE S
                LEFT JOIN PERSONNAGE P
                ON S.ID_SPECIALITE = P.ID_SPECIALITE
            GROUP BY
                S.ID_SPECIALITE
            ORDER BY
                NB_PERSONNAGES DESC
 --Note : LEFT JOIN vivement conseillé, sinon la spécialité "Agriculteur" n'apparaitra pas dans le jeu de résultat.
 -- 5. Nom, date et lieu des batailles, de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa).
                SELECT
                    B.NOM_BATAILLE,
                    DATE_FORMAT(B.DATE_BATAILLE,
                    '%d %M -%y'),
                    L.NOM_LIEU
                FROM
                    BATAILLE B,
                    LIEU L
                WHERE
                    B.ID_LIEU = L.ID_LIEU
                ORDER BY
                    YEAR(B.DATE_BATAILLE) ASC,
                    MONTH(B.DATE_BATAILLE) DESC,
                    DAY(B.DATE_BATAILLE) DESC
 -- Note : les dates ont lieu avant Jésus-Christ, le tri doit être croissant sur les années et décroissant sur les mois et les jours (afficher le '-' est un bonus).
 -- 6. Nom des potions + coût de réalisation de la potion (trié par coût décroissant).
                    SELECT
                        P.NOM_POTION,
                        SUM(I.COUT_INGREDIENT*C.QTE) AS COUT_POTION
                    FROM
                        POTION P
                        LEFT JOIN COMPOSER C
                        ON C.ID_POTION = P.ID_POTION
                        LEFT JOIN INGREDIENT I
                        ON C.ID_INGREDIENT = I.ID_INGREDIENT
                    GROUP BY
                        P.ID_POTION
                    ORDER BY
                        COUT_POTION DESC
 -- Note : LEFT JOIN permet de constater que la potion 'Miniaturisation' ne coûte rien.
 -- 7. Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'.
                        SELECT
                            I.NOM_INGREDIENT,
                            SUM(I.COUT_INGREDIENT*C.QTE) AS COUT_INGREDIENT
                        FROM
                            POTION P,
                            COMPOSER C,
                            INGREDIENT I
                        WHERE
                            P.ID_POTION = C.ID_POTION
                            AND C.ID_INGREDIENT = I.ID_INGREDIENT
                            AND P.NOM_POTION = 'Santé'
                        GROUP BY
                            I.ID_INGREDIENT
 -- 8. Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.
                            SELECT
                                P.NOM_PERSONNAGE,
                                SUM(PC.QTE) AS NB_CASQUES
                            FROM
                                PERSONNAGE P,
                                BATAILLE B,
                                PRENDRE_CASQUE PC
                            WHERE
                                P.ID_PERSONNAGE = PC.ID_PERSONNAGE
                                AND PC.ID_BATAILLE = B.ID_BATAILLE
                                AND B.NOM_BATAILLE = 'Bataille du village gaulois'
                            GROUP BY
                                P.ID_PERSONNAGE
                            HAVING
                                NB_CASQUES >= ALL(
                                    SELECT
                                        SUM(PC.QTE)
                                    FROM
                                        PRENDRE_CASQUE PC,
                                        BATAILLE B
                                    WHERE
                                        B.ID_BATAILLE = PC.ID_BATAILLE
                                        AND B.NOM_BATAILLE = 'Bataille du village gaulois'
                                    GROUP BY
                                        PC.ID_PERSONNAGE
                                )
 -- Alternative (si pas d'ex eaquo):
                                SELECT
                                    P.NOM_PERSONNAGE,
                                    SUM(PC.QTE) AS NB_CASQUES
                                FROM
                                    PERSONNAGE P,
                                    BATAILLE B,
                                    PRENDRE_CASQUE PC
                                WHERE
                                    P.ID_PERSONNAGE = PC.ID_PERSONNAGE
                                    AND PC.ID_BATAILLE = B.ID_BATAILLE
                                    AND B.NOM_BATAILLE = 'Bataille du village gaulois'
                                GROUP BY
                                    P.ID_PERSONNAGE
                                HAVING
                                    NB_CASQUES = (
                                        SELECT
                                            SUM(PC.QTE) AS NB_CASQUES
                                        FROM
                                            PRENDRE_CASQUE PC,
                                            BATAILLE B
                                        WHERE
                                            B.ID_BATAILLE = PC.ID_BATAILLE
                                            AND B.NOM_BATAILLE = 'Bataille du village gaulois'
                                        GROUP BY
                                            PC.ID_PERSONNAGE
                                        ORDER BY
                                            NB_CASQUES DESC LIMIT 1
                                    )
 -- avec une VIEW
                                    CREATE VIEW QTECASQUESBVG AS
                                    SELECT
                                        SUM(PC.QTE) AS SOMMETOTALE
                                    FROM
                                        PRENDRE_CASQUE PC,
                                        BATAILLE B
                                    WHERE
                                        B.ID_BATAILLE = PC.ID_BATAILLE
                                        AND B.NOM_BATAILLE = 'Bataille du village gaulois'
                                    GROUP BY
                                        PC.ID_PERSONNAGE
 -- puis
                                        SELECT
                                            P.NOM_PERSONNAGE,
                                            SUM(PC.QTE) AS NB_CASQUES
                                        FROM
                                            PERSONNAGE P,
                                            BATAILLE B,
                                            PRENDRE_CASQUE PC
                                        WHERE
                                            P.ID_PERSONNAGE = PC.ID_PERSONNAGE
                                            AND PC.ID_BATAILLE = B.ID_BATAILLE
                                            AND B.NOM_BATAILLE = 'Bataille du village gaulois'
                                        GROUP BY
                                            P.ID_PERSONNAGE
                                        HAVING
                                            NB_CASQUES >= ALL (
                                                SELECT
                                                    SOMMETOTALE
                                                FROM
                                                    QTECASQUESBVG
                                            )
 -- 9. Nom des personnages et, en distinguant chaque potion, la quantité de potion bue. Les classer du plus grand buveur au plus modeste.
                                            SELECT
                                                P.NOM_PERSONNAGE,
                                                PT.NOM_POTION,
                                                SUM(B.DOSE_BOIRE) AS QTE_BUE
                                            FROM
                                                PERSONNAGE P,
                                                BOIRE B,
                                                POTION PT
                                            WHERE
                                                P.ID_PERSONNAGE = B.ID_PERSONNAGE
                                                AND B.ID_POTION = PT.ID_POTION
                                            GROUP BY
                                                P.ID_PERSONNAGE,
                                                PT.ID_POTION
                                            ORDER BY
                                                QTE_BUE DESC
 -- 10. Nom de la bataille où le nombre de casques pris a été le plus important.
                                                SELECT
                                                    B.NOM_BATAILLE,
                                                    SUM(PC.QTE) AS NB_CASQUES
                                                FROM
                                                    BATAILLE B,
                                                    PRENDRE_CASQUE PC
                                                WHERE
                                                    B.ID_BATAILLE = PC.ID_BATAILLE
                                                GROUP BY
                                                    B.ID_BATAILLE
                                                HAVING
                                                    NB_CASQUES >= ALL(
                                                        SELECT
                                                            SUM(PC.QTE)
                                                        FROM
                                                            BATAILLE B,
                                                            PRENDRE_CASQUE PC
                                                        WHERE
                                                            B.ID_BATAILLE = PC.ID_BATAILLE
                                                        GROUP BY
                                                            B.ID_BATAILLE
                                                    )
 -- Note : similaire à la requête 7, la variante avec LIMIT fonctionne également ici.
 -- 11. Combien existe-t-il de casques de chaque type et quel est leur montant total ? (classés par nombre décroissant)
                                                    SELECT
                                                        COUNT(C.ID_CASQUE) AS NB_CASQUES,
                                                        TC.NOM_TYPE_CASQUE,
                                                        SUM(C.COUT_CASQUE) AS TOTAL
                                                    FROM
                                                        TYPE_CASQUE TC
                                                        LEFT JOIN CASQUE C
                                                        ON TC.ID_TYPE_CASQUE = C.ID_TYPE_CASQUE
                                                    GROUP BY
                                                        TC.ID_TYPE_CASQUE
                                                    ORDER BY
                                                        NB_CASQUES DESC
 -- Note : LEFT JOIN est préférable dans le cas où un type de casque ne soit représenté par aucun enregistrement de la table 'casque', afin que celui-ci apparaisse tout de même dans les résultats
 -- 12. Nom des potions dont la recette comporte du poisson frais.
                                                        SELECT
                                                            P.NOM_POTION
                                                        FROM
                                                            POTION P,
                                                            INGREDIENT I,
                                                            COMPOSER C
                                                        WHERE
                                                            P.ID_POTION = C.ID_POTION
                                                            AND C.ID_INGREDIENT = I.ID_INGREDIENT
                                                            AND LOWER(I.NOM_INGREDIENT) = "poisson frais"
 -- 12. bis Nom des potions dont la recette comporte du poisson.
                                                            SELECT
                                                                P.NOM_POTION
                                                            FROM
                                                                POTION P,
                                                                INGREDIENT I,
                                                                COMPOSER C
                                                            WHERE
                                                                P.ID_POTION = C.ID_POTION
                                                                AND C.ID_INGREDIENT = I.ID_INGREDIENT
                                                                AND LOWER(I.NOM_INGREDIENT) LIKE "%poisson%"
 -- Note : il y a deux ingrédients dont le nom contient "poisson" !
 -- 13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.
                                                                SELECT
                                                                    L.NOM_LIEU,
                                                                    COUNT(P.ID_PERSONNAGE) AS NB
                                                                FROM
                                                                    PERSONNAGE P,
                                                                    LIEU L
                                                                WHERE
                                                                    P.ID_LIEU = L.ID_LIEU
                                                                    AND L.NOM_LIEU != 'Village gaulois'
                                                                GROUP BY
                                                                    L.ID_LIEU
                                                                HAVING
                                                                    NB >= ALL (
                                                                        SELECT
                                                                            COUNT(P.ID_PERSONNAGE)
                                                                        FROM
                                                                            PERSONNAGE P,
                                                                            LIEU L
                                                                        WHERE
                                                                            L.ID_LIEU = P.ID_LIEU
                                                                            AND L.NOM_LIEU != 'Village gaulois'
                                                                        GROUP BY
                                                                            L.ID_LIEU
                                                                    )
 -- Note : attention à exclure le village gaulois des deux requêtes ! (Une variante avec LIMIT dans la sous-requête fonctionnerait également ici).
 -- 14. Nom des personnages qui n'ont jamais bu aucune potion.
                                                                    SELECT
                                                                        P.NOM_PERSONNAGE
                                                                    FROM
                                                                        PERSONNAGE P
                                                                        LEFT JOIN BOIRE B
                                                                        ON P.ID_PERSONNAGE = B.ID_PERSONNAGE
                                                                    WHERE
                                                                        B.ID_PERSONNAGE IS NULL
                                                                    GROUP BY
                                                                        P.ID_PERSONNAGE
 -- Alternative :
                                                                        SELECT
                                                                            P.NOM_PERSONNAGE
                                                                        FROM
                                                                            PERSONNAGE P
                                                                        WHERE
                                                                            P.ID_PERSONNAGE NOT IN (
                                                                                SELECT
                                                                                    P.ID_PERSONNAGE
                                                                                FROM
                                                                                    PERSONNAGE P,
                                                                                    BOIRE B
                                                                                WHERE
                                                                                    P.ID_PERSONNAGE = B.ID_PERSONNAGE
                                                                            )
 -- 15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.
                                                                            SELECT
                                                                                P.NOM_PERSONNAGE
                                                                            FROM
                                                                                PERSONNAGE P
                                                                            WHERE
                                                                                P.ID_PERSONNAGE NOT IN (
                                                                                    SELECT
                                                                                        ID_PERSONNAGE
                                                                                    FROM
                                                                                        AUTORISER_BOIRE A,
                                                                                        POTION PT
                                                                                    WHERE
                                                                                        PT.ID_POTION = A.ID_POTION
                                                                                        AND PT.NOM_POTION = 'Magique'
                                                                                )
 -- Note : bien entendu, Obélix est dans la liste !
 -- avec une VIEW
                                                                                CREATE VIEW BUVEURSMAGIQUE AS
                                                                                SELECT
                                                                                    ID_PERSONNAGE
                                                                                FROM
                                                                                    AUTORISER_BOIRE A,
                                                                                    POTION PT
                                                                                WHERE
                                                                                    PT.ID_POTION = A.ID_POTION
                                                                                    AND PT.NOM_POTION = 'Magique'
 -- puis
                                                                                    SELECT
                                                                                        P.NOM_PERSONNAGE
                                                                                    FROM
                                                                                        PERSONNAGE P
                                                                                    WHERE
                                                                                        P.ID_PERSONNAGE NOT IN (
                                                                                            SELECT
                                                                                                ID_PERSONNAGE
                                                                                            FROM
                                                                                                BUVEURSMAGIQUE
                                                                                        )
 -- ou
                                                                                        SELECT
                                                                                            P.NOM_PERSONNAGE
                                                                                        FROM
                                                                                            PERSONNAGE P
                                                                                        WHERE
                                                                                            NOT EXISTS (
                                                                                                SELECT
                                                                                                    AB.ID_PERSONNAGE
                                                                                                FROM
                                                                                                    AUTORISER_BOIRE AB
                                                                                                    INNER JOIN POTION PO
                                                                                                    ON AB.ID_POTION = PO.ID_POTION
                                                                                                WHERE
                                                                                                    P.ID_PERSONNAGE = AB.ID_PERSONNAGE
                                                                                                    AND NOM_POTION = "Magique"
                                                                                            )
 -- En écrivant toujours des requêtes SQL, modifiez la base de données comme suit : Note : il est préférable de se baser uniquement sur les informations données : ne pas saisir directement les identifiants correspondants aux critères mais les obtenir systématiquement grâce à un SELECT depuis leurs noms.
 -- A. Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus.
                                                                                            INSERT INTO PERSONNAGE (NOM_PERSONNAGE,
                                                                                            ADRESSE_PERSONNAGE,
                                                                                            ID_LIEU,
                                                                                            ID_SPECIALITE) VALUES ( 'Champdeblix',
                                                                                            'Ferme Hantassion',
                                                                                            (
                                                                                                SELECT
                                                                                                    ID_LIEU
                                                                                                FROM
                                                                                                    LIEU
                                                                                                WHERE
                                                                                                    NOM_LIEU = 'Rotomagus'
                                                                                            ),
                                                                                            (
                                                                                                SELECT
                                                                                                    ID_SPECIALITE
                                                                                                FROM
                                                                                                    SPECIALITE
                                                                                                WHERE
                                                                                                    NOM_SPECIALITE = 'Agriculteur'
                                                                                            ) )
 -- B. Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine...
                                                                                            INSERT INTO AUTORISER_BOIRE (ID_POTION,
                                                                                            ID_PERSONNAGE) VALUES ( (
                                                                                                SELECT
                                                                                                    ID_POTION
                                                                                                FROM
                                                                                                    POTION
                                                                                                WHERE
                                                                                                    NOM_POTION = 'Magique'
                                                                                            ),
                                                                                            (
                                                                                                SELECT
                                                                                                    ID_PERSONNAGE
                                                                                                FROM
                                                                                                    PERSONNAGE
                                                                                                WHERE
                                                                                                    NOM_PERSONNAGE = 'Bonemine'
                                                                                            ) )
 -- C. Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille.
                                                                                            DELETE
                                                                                        FROM
                                                                                            CASQUE
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
                                                                                            UPDATE PERSONNAGE SET ADRESSE_PERSONNAGE = 'Prison',
                                                                                            ID_LIEU = (
                                                                                                SELECT
                                                                                                    ID_LIEU
                                                                                                FROM
                                                                                                    LIEU
                                                                                                WHERE
                                                                                                    NOM_LIEU = 'Condate'
                                                                                            )
                                                                                        WHERE
                                                                                            NOM_PERSONNAGE = 'Zérozérosix'
 --NULL
                                                                                            UPDATE PERSONNAGE SET ADRESSE_PERSONNAGE = "Prison",
                                                                                            ID_LIEU = 9
                                                                                        WHERE
                                                                                            ID_PERSONNAGE = 23
 -- E. La potion 'Soupe' ne doit plus contenir de persil.
                                                                                            DELETE
                                                                                        FROM
                                                                                            COMPOSER
                                                                                        WHERE
                                                                                            ID_POTION = (
                                                                                                SELECT
                                                                                                    ID_POTION
                                                                                                FROM
                                                                                                    POTION
                                                                                                WHERE
                                                                                                    NOM_POTION = 'Soupe'
                                                                                            )
                                                                                            AND ID_INGREDIENT = (
                                                                                                SELECT
                                                                                                    ID_INGREDIENT
                                                                                                FROM
                                                                                                    INGREDIENT
                                                                                                WHERE
                                                                                                    NOM_INGREDIENT = 'Persil'
                                                                                            )
 -- F. Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, qu'il a pris lors de la bataille 'Attaque de la banque postale'. Corrigez son erreur !
                                                                                            UPDATE PRENDRE_CASQUE SET ID_CASQUE = (
                                                                                                SELECT
                                                                                                    ID_CASQUE
                                                                                                FROM
                                                                                                    CASQUE
                                                                                                WHERE
                                                                                                    NOM_CASQUE = 'Weisenau'
                                                                                            ),
                                                                                            QTE = 42
                                                                                        WHERE
                                                                                            ID_PERSONNAGE = (
                                                                                                SELECT
                                                                                                    ID_PERSONNAGE
                                                                                                FROM
                                                                                                    PERSONNAGE
                                                                                                WHERE
                                                                                                    NOM_PERSONNAGE = 'Obélix'
                                                                                            )
                                                                                            AND ID_BATAILLE = (
                                                                                                SELECT
                                                                                                    ID_BATAILLE
                                                                                                FROM
                                                                                                    BATAILLE
                                                                                                WHERE
                                                                                                    NOM_BATAILLE = 'Attaque de la banque postale'
                                                                                            )
                                                                                            AND ID_CASQUE = (
                                                                                                SELECT
                                                                                                    ID_CASQUE
                                                                                                FROM
                                                                                                    CASQUE
                                                                                                WHERE
                                                                                                    NOM_CASQUE = 'Ostrogoth'
                                                                                            )
 -- ou (si on connaît les identifiants)
                                                                                            UPDATE PRENDRE_CASQUE SET ID_CASQUE = 10,
                                                                                            QTE = 42
                                                                                        WHERE
                                                                                            ID_PERSONNAGE = 5
                                                                                            AND ID_BATAILLE = 9
                                                                                            AND ID_CASQUE = 14
 -- BONUS
 -- Adresse mail pour chaque gaulois
 -- 3 premières lettres du nom du gaulois + un point + 4 premières lettres du lieu d'habitation + "gaulois.fr"
 -- le tout en minuscule
                                                                                            SELECT
                                                                                                NOM_PERSONNAGE,
                                                                                                LOWER(CONCAT(
                                                                                                LEFT(NOM_PERSONNAGE, 3), ".", LEFT(NOM_LIEU, 4), "@gaulois.fr"))
                                                                                            FROM
                                                                                                PERSONNAGE P
                                                                                                INNER JOIN LIEU L
                                                                                                ON P.ID_LIEU = L.ID_LIEU
 -- Nombre de jours écoulés entre 2 batailles de votre choix
                                                                                                SELECT
                                                                                                    "Bataille du village gaulois",
                                                                                                    "Attaque du bateau pirate",
                                                                                                    ABS(DATEDIFF( (
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
                                                                                                        ) )) AS NBJOURS
 -- Nom des types de casque + nom des casques associés
 -- Résultat :
 ----- Autre | Corinthien, Elendil, Spartacus
 ----- Grec | Spartiate, Troyen
 ----- Romain | Centurion, Centurion officier, Imperial Gallic, Maximum, Romain
                                                                                                        SELECT
                                                                                                            TC.NOM_TYPE_CASQUE AS 'Type casque',
                                                                                                            GROUP_CONCAT(DISTINCT C.NOM_CASQUE SEPARATOR ', ') AS 'Noms casques'
                                                                                                        FROM
                                                                                                            CASQUE C
                                                                                                            INNER JOIN TYPE_CASQUE TC
                                                                                                            ON TC.ID_TYPE_CASQUE = C.ID_TYPE_CASQUE
                                                                                                        GROUP BY
                                                                                                            TC.NOM_TYPE_CASQUE