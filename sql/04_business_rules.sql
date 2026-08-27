-- Base de données d'une agence d'intérim
-- Implémentation et démonstration des règles métier au niveau de la base de données.

USE `recruitment_agency`;

DROP TRIGGER  IF EXISTS trg_offre_no_delete;
DROP TRIGGER  IF EXISTS trg_offre_before_update_fermeture;
DROP TRIGGER  IF EXISTS trg_candidat_no_delete;
DROP TRIGGER  IF EXISTS trg_offre_check_dispo_insert;
DROP TRIGGER  IF EXISTS trg_offre_check_dispo_update;
DROP TRIGGER  IF EXISTS trg_offre_no_reattribution;
DROP TRIGGER  IF EXISTS trg_candidat_age_min_insert;
DROP PROCEDURE IF EXISTS sp_anonymiser_candidat;
DROP PROCEDURE IF EXISTS sp_maj_disponibilite_candidats;


-- ============================================================================
-- C1 - Une offre d'emploi ne peut pas être supprimée, uniquement archivée
--      (statut 'fermée'). On bloque toute tentative de DELETE sur OFFRE_EMPLOI.
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_offre_no_delete
BEFORE DELETE ON OFFRE_EMPLOI
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'C1 : suppression interdite. Une offre doit etre archivee (statut = fermee).';
END $$

DELIMITER ;


-- ============================================================================
-- C2 - Lorsqu'une offre passe de 'ouverte' à 'fermée', on enregistre
--      automatiquement la date du jour comme date de fermeture.
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_offre_before_update_fermeture
BEFORE UPDATE ON OFFRE_EMPLOI
FOR EACH ROW
BEGIN
    IF OLD.statut = 'ouverte'
       AND NEW.statut = 'fermée'
       AND NEW.dateFermeture IS NULL
    THEN
        SET NEW.dateFermeture = CURDATE();
    END IF;
END $$

DELIMITER ;


-- ============================================================================
-- C3 - La suppression d'un candidat est interdite : on conserve la ligne
--      CANDIDAT (avec ses diplômes, expériences, candidatures) pour archive,
--      mais on supprime/anonymise les données personnelles.
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_candidat_no_delete
BEFORE DELETE ON CANDIDAT
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'C3 : suppression interdite. Utiliser CALL sp_anonymiser_candidat(idCandidat).';
END $$

CREATE PROCEDURE sp_anonymiser_candidat (IN p_idCandidat INT)
BEGIN
    -- Anonymisation des données personnelles dans PERSONNE.
    UPDATE PERSONNE
    SET nom        = 'Anonyme',
        prenom     = 'Anonyme',
        adresse    = NULL,
        email      = NULL,
        telephone  = NULL
    WHERE idPersonne = (
        SELECT idPersonne FROM CANDIDAT WHERE idCandidat = p_idCandidat
    );

    -- On vide aussi la description et on rend le candidat indisponible.
    UPDATE CANDIDAT
    SET description = NULL,
        statut      = 'indisponible'
    WHERE idCandidat = p_idCandidat;
END $$

DELIMITER ;


-- ============================================================================
-- C4 - Un candidat ne peut pas être attribué à une offre s'il n'est pas
--      disponible. Définition métier : un candidat est indisponible s'il a
--      déjà été retenu sur une autre offre dont la date de fin est NULL
--      (CDI) ou dans le futur (contrat en cours).
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_offre_check_dispo_insert
BEFORE INSERT ON OFFRE_EMPLOI
FOR EACH ROW
BEGIN
    IF NEW.idCandidatRetenu IS NOT NULL THEN
        IF EXISTS (
            SELECT 1
            FROM OFFRE_EMPLOI o
            WHERE o.idCandidatRetenu = NEW.idCandidatRetenu
              AND (o.dateFin IS NULL OR o.dateFin > CURDATE())
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'C4 : ce candidat est deja sous contrat actif.';
        END IF;
    END IF;
END $$

CREATE TRIGGER trg_offre_check_dispo_update
BEFORE UPDATE ON OFFRE_EMPLOI
FOR EACH ROW
BEGIN
    IF NEW.idCandidatRetenu IS NOT NULL
       AND (OLD.idCandidatRetenu IS NULL
            OR OLD.idCandidatRetenu <> NEW.idCandidatRetenu)
    THEN
        IF EXISTS (
            SELECT 1
            FROM OFFRE_EMPLOI o
            WHERE o.idOffre <> NEW.idOffre
              AND o.idCandidatRetenu = NEW.idCandidatRetenu
              AND (o.dateFin IS NULL OR o.dateFin > CURDATE())
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'C4 : ce candidat est deja sous contrat actif.';
        END IF;
    END IF;
END $$

DELIMITER ;


-- ============================================================================
-- C5 - Une offre déjà attribuée ne peut pas être réattribuée à un autre
--      candidat (interprétation : "une candidature ne peut être obtenue si
--      elle a déjà été obtenue par un autre candidat").
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_offre_no_reattribution
BEFORE UPDATE ON OFFRE_EMPLOI
FOR EACH ROW
BEGIN
    IF OLD.idCandidatRetenu IS NOT NULL
       AND NEW.idCandidatRetenu IS NOT NULL
       AND OLD.idCandidatRetenu <> NEW.idCandidatRetenu
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'C5 : cette offre est deja attribuee a un autre candidat.';
    END IF;
END $$

DELIMITER ;


-- ============================================================================
-- C6 - Procédure qui passe le statut des candidats à 'disponible' lorsque
--      leur emploi actuel s'est terminé.
-- ============================================================================
DELIMITER $$

CREATE PROCEDURE sp_maj_disponibilite_candidats ()
BEGIN
    UPDATE CANDIDAT c
    SET c.statut = 'disponible'
    WHERE c.statut = 'indisponible'
      AND NOT EXISTS (
          SELECT 1 FROM OFFRE_EMPLOI o
          WHERE o.idCandidatRetenu = c.idCandidat
            AND (o.dateFin IS NULL OR o.dateFin > CURDATE())
      );
END $$

DELIMITER ;


-- ============================================================================
-- C7 - Les candidats doivent avoir au moins 16 ans à la date d'inscription.
-- ----------------------------------------------------------------------------
-- Trigger BEFORE INSERT sur CANDIDAT. On va chercher la date de naissance
-- dans PERSONNE via SELECT ... INTO, puis on calcule l'âge avec
-- TIMESTAMPDIFF(YEAR, dateNaissance, CURDATE()).
-- Si l'âge est < 16, on bloque avec SIGNAL.
-- (On ne fait pas de trigger UPDATE : la colonne idPersonne d'un CANDIDAT
-- n'a pas vocation à changer dans la vie courante de la base.)
-- ============================================================================
DELIMITER $$

CREATE TRIGGER trg_candidat_age_min_insert
BEFORE INSERT ON CANDIDAT
FOR EACH ROW
BEGIN
    DECLARE v_age INT;

    SELECT TIMESTAMPDIFF(YEAR, dateNaissance, CURDATE())
      INTO v_age
      FROM PERSONNE
     WHERE idPersonne = NEW.idPersonne;

    IF v_age < 16 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'C7 : un candidat doit avoir au moins 16 ans.';
    END IF;
END $$

DELIMITER ;


-- ============================================================================
-- ============================================================================
--                              S E C T I O N    T E S T S
-- ============================================================================
-- ============================================================================
-- Pour chaque contrainte on présente :
--   * un cas qui DOIT ECHOUER : commenté (--), à décommenter manuellement
--     pour observer l'erreur 1644 (SIGNAL '45000').
--   * un cas qui DOIT REUSSIR : exécuté directement par le SOURCE et suivi
--     d'un SELECT de vérification.
--
-- Les requêtes "doit échouer" sont laissées en commentaires pour que le
-- SOURCE complet s'exécute sans interruption. Pour tester, copier-coller
-- la ligne dans MySQL Workbench et l'exécuter seule.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- TEST C1 : suppression d'une offre interdite
-- ----------------------------------------------------------------------------
-- DOIT ECHOUER (decommenter pour tester) :
-- DELETE FROM OFFRE_EMPLOI WHERE idOffre = 1;
-- => ERROR 1644 (45000): C1 : suppression interdite...

-- DOIT REUSSIR : on archive l'offre 10 en passant son statut à 'fermée'.
-- Le trigger C2 va automatiquement positionner dateFermeture.
UPDATE OFFRE_EMPLOI SET statut = 'fermée' WHERE idOffre = 10;
SELECT idOffre, statut, dateFermeture FROM OFFRE_EMPLOI WHERE idOffre = 10;

-- Remise dans l'état initial (pour ne pas polluer la base de test)
UPDATE OFFRE_EMPLOI
SET statut = 'ouverte', dateFermeture = NULL
WHERE idOffre = 10;


-- ----------------------------------------------------------------------------
-- TEST C2 : passage à 'fermée' => dateFermeture automatique
-- ----------------------------------------------------------------------------
-- L'offre 6 est 'ouverte' avec dateFermeture NULL.
UPDATE OFFRE_EMPLOI SET statut = 'fermée' WHERE idOffre = 6;
SELECT idOffre, statut, dateFermeture FROM OFFRE_EMPLOI WHERE idOffre = 6;
-- Resultat attendu : dateFermeture = date du jour.

-- Remise dans l'état initial
UPDATE OFFRE_EMPLOI
SET statut = 'ouverte', dateFermeture = NULL
WHERE idOffre = 6;


-- ----------------------------------------------------------------------------
-- TEST C3 : suppression d'un candidat interdite + procédure d'anonymisation
-- ----------------------------------------------------------------------------
-- DOIT ECHOUER (decommenter pour tester) :
-- DELETE FROM CANDIDAT WHERE idCandidat = 2;

-- DOIT REUSSIR : on anonymise le candidat 2 (Julie Simon).
-- Avant : Julie a un nom, un email, un téléphone, une description, et 2 diplômes.
SELECT c.idCandidat, p.nom, p.prenom, p.email, p.telephone, c.description, c.statut
FROM CANDIDAT c INNER JOIN PERSONNE p ON c.idPersonne = p.idPersonne
WHERE c.idCandidat = 2;

CALL sp_anonymiser_candidat(2);

-- Apres : nom = 'Anonyme', email/telephone NULL, description NULL,
-- statut 'indisponible'. Mais ses diplomes et candidatures sont conserves.
SELECT c.idCandidat, p.nom, p.prenom, p.email, p.telephone, c.description, c.statut
FROM CANDIDAT c INNER JOIN PERSONNE p ON c.idPersonne = p.idPersonne
WHERE c.idCandidat = 2;

SELECT COUNT(*) AS nb_diplomes_conserves     FROM DIPLOME      WHERE idCandidat = 2;
SELECT COUNT(*) AS nb_candidatures_conservees FROM CANDIDATURE WHERE idCandidat = 2;


-- ----------------------------------------------------------------------------
-- TEST C4 : un candidat sous contrat actif ne peut pas etre retenu ailleurs
-- ----------------------------------------------------------------------------
-- D'apres les donnees initiales, le candidat 1 (Thomas) est retenu sur
-- l'offre 7 (CDI, dateFin NULL) : il est en contrat actif.
-- DOIT ECHOUER (decommenter pour tester) :
-- UPDATE OFFRE_EMPLOI SET idCandidatRetenu = 1 WHERE idOffre = 1;

-- DOIT REUSSIR : Lea (candidat 8) n'a aucun contrat actif.
UPDATE OFFRE_EMPLOI SET idCandidatRetenu = 8 WHERE idOffre = 1;
SELECT idOffre, idCandidatRetenu FROM OFFRE_EMPLOI WHERE idOffre = 1;

-- Remise dans l'etat initial
UPDATE OFFRE_EMPLOI SET idCandidatRetenu = NULL WHERE idOffre = 1;


-- ----------------------------------------------------------------------------
-- TEST C5 : pas de reattribution d'une offre deja attribuee
-- ----------------------------------------------------------------------------
-- L'offre 3 est attribuee au candidat 5 (Antoine).
-- DOIT ECHOUER (decommenter pour tester) :
-- UPDATE OFFRE_EMPLOI SET idCandidatRetenu = 6 WHERE idOffre = 3;


-- ----------------------------------------------------------------------------
-- TEST C6 : procedure de remise a 'disponible' apres fin de contrat
-- ----------------------------------------------------------------------------
-- Avant : Claire (candidat 12) est 'indisponible' dans les donnees initiales.
-- Cependant elle n'a aucune offre retenue dans les donnees initiales, donc
-- la procedure va la rendre 'disponible' (la condition NOT EXISTS est vraie).
SELECT idCandidat, statut FROM CANDIDAT WHERE idCandidat = 12;

CALL sp_maj_disponibilite_candidats();

SELECT idCandidat, statut FROM CANDIDAT WHERE idCandidat = 12;

-- Remise dans l'etat initial pour ne pas polluer la base
UPDATE CANDIDAT SET statut = 'indisponible' WHERE idCandidat = 12;


-- ----------------------------------------------------------------------------
-- TEST C7 : un candidat doit avoir au moins 16 ans
-- ----------------------------------------------------------------------------
-- DOIT ECHOUER : on insere une personne agee de 10 ans, puis on essaie de
-- la declarer candidate. Le trigger trg_candidat_age_min_insert va bloquer.
INSERT INTO PERSONNE (nom, prenom, dateNaissance, email)
VALUES ('Test', 'Mineur', DATE_SUB(CURDATE(), INTERVAL 10 YEAR), 'mineur@test.fr');
SET @idPersonneMineur := LAST_INSERT_ID();

-- DOIT ECHOUER (decommenter pour tester) :
-- INSERT INTO CANDIDAT (idPersonne, description, statut)
-- VALUES (@idPersonneMineur, 'Test C7 - mineur', 'disponible');
-- => ERROR 1644 (45000): C7 : un candidat doit avoir au moins 16 ans.

-- DOIT REUSSIR : une personne de 20 ans peut etre inscrite comme candidate.
INSERT INTO PERSONNE (nom, prenom, dateNaissance, email)
VALUES ('Test', 'Majeur', DATE_SUB(CURDATE(), INTERVAL 20 YEAR), 'majeur@test.fr');
SET @idPersonneMajeur := LAST_INSERT_ID();

INSERT INTO CANDIDAT (idPersonne, description, statut)
VALUES (@idPersonneMajeur, 'Test C7 - majeur, doit passer', 'disponible');

-- Verification : on retrouve bien le nouveau candidat avec son age >= 16
SELECT c.idCandidat, p.nom, p.prenom, p.dateNaissance,
       TIMESTAMPDIFF(YEAR, p.dateNaissance, CURDATE()) AS age
FROM CANDIDAT c INNER JOIN PERSONNE p ON c.idPersonne = p.idPersonne
WHERE p.email IN ('mineur@test.fr', 'majeur@test.fr');

-- ============================================================================
-- FIN DU FICHIER database_triggers.sql
-- ============================================================================
