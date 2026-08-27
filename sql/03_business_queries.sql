-- Base de données d'une agence d'intérim
-- Sélection de requêtes SQL opérationnelles et analytiques pour le portfolio.

USE `recruitment_agency`;


-- ============================================================================
-- REQUÊTE 1
-- Liste des candidats et des offres auxquelles ils ont postulé.
-- ============================================================================
SELECT
    cand.idCandidat,
    p.nom               AS nom_candidat,
    p.prenom            AS prenom_candidat,
    o.idOffre,
    o.intitule          AS intitule_offre,
    o.typeContrat,
    c.dateCandidature,
    c.statutCandidature
FROM CANDIDATURE c
INNER JOIN CANDIDAT      cand ON c.idCandidat   = cand.idCandidat
INNER JOIN PERSONNE      p    ON cand.idPersonne = p.idPersonne
INNER JOIN OFFRE_EMPLOI  o    ON c.idOffre       = o.idOffre
ORDER BY p.nom, p.prenom, c.dateCandidature;


-- ============================================================================
-- REQUÊTE 2
-- Toutes les informations d'un candidat : informations personnelles,
-- diplômes, métiers, compétences, expériences, candidatures.
-- ============================================================================
SET @idCandidat := 1;

-- 2.a  Informations personnelles du candidat
SELECT
    cand.idCandidat,
    p.nom,
    p.prenom,
    p.dateNaissance,
    p.adresse,
    p.email,
    p.telephone,
    cand.description,
    cand.statut
FROM CANDIDAT cand
INNER JOIN PERSONNE p ON cand.idPersonne = p.idPersonne
WHERE cand.idCandidat = @idCandidat;

-- 2.b  Diplômes du candidat
SELECT idDiplome, libelle, niveauEtude
FROM DIPLOME
WHERE idCandidat = @idCandidat;

-- 2.c  Métiers associés au candidat
SELECT m.idMetier, m.libelle
FROM METIER m
INNER JOIN CANDIDAT_METIER cm ON m.idMetier = cm.idMetier
WHERE cm.idCandidat = @idCandidat;

-- 2.d  Compétences maîtrisées par le candidat
SELECT comp.idCompetence, comp.libelle
FROM COMPETENCE comp
INNER JOIN MAITRISE ma ON comp.idCompetence = ma.idCompetence
WHERE ma.idCandidat = @idCandidat;

-- 2.e  Expériences professionnelles du candidat
SELECT idExperience, description, dateDebut, dateFin, typeExperience
FROM EXPERIENCE_PROFESSIONNELLE
WHERE idCandidat = @idCandidat
ORDER BY dateDebut DESC;

-- 2.f  Offres auxquelles le candidat a postulé
SELECT
    o.idOffre,
    o.intitule,
    o.typeContrat,
    o.statut          AS statut_offre,
    c.dateCandidature,
    c.statutCandidature
FROM CANDIDATURE c
INNER JOIN OFFRE_EMPLOI o ON c.idOffre = o.idOffre
WHERE c.idCandidat = @idCandidat
ORDER BY c.dateCandidature DESC;


-- ============================================================================
-- REQUÊTE 3
-- Candidats qui ont postulé à TOUTES les offres d'emploi.
-- ============================================================================
SELECT cand.idCandidat, p.nom, p.prenom
FROM CANDIDAT cand
INNER JOIN PERSONNE   p ON cand.idPersonne = p.idPersonne
INNER JOIN CANDIDATURE c ON cand.idCandidat = c.idCandidat
GROUP BY cand.idCandidat, p.nom, p.prenom
HAVING COUNT(DISTINCT c.idOffre) = (SELECT COUNT(*) FROM OFFRE_EMPLOI);


-- ============================================================================
-- REQUÊTE 4
-- Somme totale des commissions perçues par l'agence (toutes périodes).
-- ============================================================================
SELECT
    ROUND(SUM(o.tauxHoraire * o.heuresMensuelles * 0.10), 2) AS commission_totale
FROM OFFRE_EMPLOI o
WHERE o.statut = 'fermée'
  AND o.idCandidatRetenu IS NOT NULL;


-- ============================================================================
-- REQUÊTE 5
-- Commissions regroupées par mois.
-- ============================================================================
SELECT
    DATE_FORMAT(o.dateFermeture, '%Y-%m')                    AS mois,
    ROUND(SUM(o.tauxHoraire * o.heuresMensuelles * 0.10), 2) AS commission_mois,
    COUNT(*)                                                 AS nb_offres_pourvues
FROM OFFRE_EMPLOI o
WHERE o.statut = 'fermée'
  AND o.idCandidatRetenu IS NOT NULL
GROUP BY DATE_FORMAT(o.dateFermeture, '%Y-%m')
ORDER BY mois;


-- ============================================================================
-- REQUÊTE 6
-- Commissions par salarié (l'employé qui a géré l'offre).
-- 6.a : total par salarié (toutes périodes).
-- 6.b : total par salarié et par mois.
-- ============================================================================

-- 6.a  Total par salarié
SELECT
    e.idEmploye,
    p.nom,
    p.prenom,
    e.role,
    ROUND(SUM(o.tauxHoraire * o.heuresMensuelles * 0.10), 2) AS commission_totale,
    COUNT(*)                                                 AS nb_offres_pourvues
FROM OFFRE_EMPLOI o
INNER JOIN EMPLOYE  e ON o.idSalarieGestionnaire = e.idEmploye
INNER JOIN PERSONNE p ON e.idPersonne            = p.idPersonne
WHERE o.statut = 'fermée'
  AND o.idCandidatRetenu IS NOT NULL
GROUP BY e.idEmploye, p.nom, p.prenom, e.role
ORDER BY commission_totale DESC;

-- 6.b  Par salarié et par mois
SELECT
    e.idEmploye,
    p.nom,
    p.prenom,
    DATE_FORMAT(o.dateFermeture, '%Y-%m')                    AS mois,
    ROUND(SUM(o.tauxHoraire * o.heuresMensuelles * 0.10), 2) AS commission
FROM OFFRE_EMPLOI o
INNER JOIN EMPLOYE  e ON o.idSalarieGestionnaire = e.idEmploye
INNER JOIN PERSONNE p ON e.idPersonne            = p.idPersonne
WHERE o.statut = 'fermée'
  AND o.idCandidatRetenu IS NOT NULL
GROUP BY e.idEmploye, p.nom, p.prenom, DATE_FORMAT(o.dateFermeture, '%Y-%m')
ORDER BY mois, p.nom, p.prenom;


-- ============================================================================
-- REQUÊTE 7
-- Compétences qui ne sont rattachées à aucun candidat.
-- ============================================================================
SELECT c.idCompetence, c.libelle
FROM COMPETENCE c
LEFT JOIN MAITRISE m ON c.idCompetence = m.idCompetence
WHERE m.idCandidat IS NULL;


-- ============================================================================
-- REQUÊTE 8
-- Candidats potentiels (qui n'ont pas encore candidaté) pour une offre
-- donnée. Un candidat est potentiel s'il partage au moins un métier OU
-- au moins une compétence requise par l'offre, et s'il est disponible.
-- ============================================================================
SET @idOffre := 1;

DROP VIEW IF EXISTS V_CANDIDATS_POTENTIELS;
CREATE VIEW V_CANDIDATS_POTENTIELS AS
-- Branche 1 : candidats partageant un métier avec l'offre
SELECT DISTINCT
    om.idOffre,
    cand.idCandidat,
    p.nom,
    p.prenom
FROM CANDIDAT_METIER cm
INNER JOIN OFFRE_METIER om   ON cm.idMetier   = om.idMetier
INNER JOIN CANDIDAT     cand ON cm.idCandidat = cand.idCandidat
INNER JOIN PERSONNE     p    ON cand.idPersonne = p.idPersonne
INNER JOIN OFFRE_EMPLOI o    ON om.idOffre = o.idOffre
WHERE o.statut = 'ouverte'
  AND cand.statut = 'disponible'
  AND cand.idCandidat NOT IN (
      SELECT idCandidat FROM CANDIDATURE WHERE idOffre = om.idOffre
  )

UNION

-- Branche 2 : candidats partageant une compétence avec l'offre
SELECT DISTINCT
    oc.idOffre,
    cand.idCandidat,
    p.nom,
    p.prenom
FROM MAITRISE ma
INNER JOIN OFFRE_COMPETENCE oc   ON ma.idCompetence = oc.idCompetence
INNER JOIN CANDIDAT          cand ON ma.idCandidat   = cand.idCandidat
INNER JOIN PERSONNE          p    ON cand.idPersonne = p.idPersonne
INNER JOIN OFFRE_EMPLOI      o    ON oc.idOffre = o.idOffre
WHERE o.statut = 'ouverte'
  AND cand.statut = 'disponible'
  AND cand.idCandidat NOT IN (
      SELECT idCandidat FROM CANDIDATURE WHERE idOffre = oc.idOffre
  );

-- Interrogation pour l'offre @idOffre
SELECT *
FROM V_CANDIDATS_POTENTIELS
WHERE idOffre = @idOffre
ORDER BY nom, prenom;


-- ============================================================================
-- REQUÊTE 9
-- Ajouter automatiquement les candidatures pour les candidats listés en Q8.
-- ============================================================================
INSERT INTO CANDIDATURE (idOffre, idCandidat, dateCandidature, statutCandidature)
SELECT v.idOffre, v.idCandidat, CURDATE(), 'en attente'
FROM V_CANDIDATS_POTENTIELS v
WHERE v.idOffre = @idOffre
  AND v.idCandidat NOT IN (
      SELECT idCandidat FROM CANDIDATURE WHERE idOffre = @idOffre
  );

-- Vérification : on liste les candidatures de l'offre concernée
SELECT *
FROM CANDIDATURE
WHERE idOffre = @idOffre
ORDER BY dateCandidature;


-- ============================================================================
-- REQUÊTE 10
-- Fermer une offre d'emploi et l'attribuer à un candidat.
-- ============================================================================
SET @offreFerm       := 8;   -- Offre à fermer (Technicien Réseau)
SET @candidatRetenu  := 3;   -- Candidat retenu (Lucas)

-- (a) Fermeture et attribution de l'offre
UPDATE OFFRE_EMPLOI
SET statut           = 'fermée',
    dateFermeture    = CURDATE(),
    idCandidatRetenu = @candidatRetenu
WHERE idOffre = @offreFerm;

-- (b1) Marquer la candidature retenue comme 'acceptée'
UPDATE CANDIDATURE
SET statutCandidature = 'acceptée'
WHERE idOffre    = @offreFerm
  AND idCandidat = @candidatRetenu;

-- (b2) Marquer toutes les autres candidatures de l'offre comme 'refusée'
UPDATE CANDIDATURE
SET statutCandidature = 'refusée'
WHERE idOffre     = @offreFerm
  AND idCandidat <> @candidatRetenu
  AND statutCandidature = 'en attente';

-- (c) Le candidat retenu n'est plus disponible
UPDATE CANDIDAT
SET statut = 'indisponible'
WHERE idCandidat = @candidatRetenu;

-- Vérification finale
SELECT idOffre, intitule, statut, dateFermeture, idCandidatRetenu
FROM OFFRE_EMPLOI
WHERE idOffre = @offreFerm;

SELECT idOffre, idCandidat, dateCandidature, statutCandidature
FROM CANDIDATURE
WHERE idOffre = @offreFerm;

SELECT idCandidat, statut FROM CANDIDAT WHERE idCandidat = @candidatRetenu;


-- ============================================================================
-- FIN DU FICHIER database_queries.sql
-- ============================================================================
