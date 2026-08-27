-- Base de données d'une agence d'intérim
-- Création du schéma relationnel et de ses contraintes d'intégrité.
-- Plateforme cible : MySQL 8.0+

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS `recruitment_agency`;
CREATE SCHEMA IF NOT EXISTS `recruitment_agency` DEFAULT CHARACTER SET utf8mb4;
USE `recruitment_agency`;

-- -----------------------------------------------------
-- Table `PERSONNE`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PERSONNE`;

CREATE TABLE IF NOT EXISTS `PERSONNE` (
  `idPersonne` INT NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(45) NOT NULL,
  `prenom` VARCHAR(45) NOT NULL,
  `dateNaissance` DATE NOT NULL,
  `adresse` VARCHAR(100) NULL,
  `email` VARCHAR(100) NULL,
  `telephone` VARCHAR(20) NULL,
  PRIMARY KEY (`idPersonne`)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CANDIDAT`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CANDIDAT`;

CREATE TABLE IF NOT EXISTS `CANDIDAT` (
  `idCandidat` INT NOT NULL AUTO_INCREMENT,
  `idPersonne` INT NOT NULL,
  `description` TEXT NULL,
  `statut` VARCHAR(15) NOT NULL DEFAULT 'disponible',
  PRIMARY KEY (`idCandidat`),
  INDEX `fk_candidat_personne_idx` (`idPersonne` ASC),
  CONSTRAINT `fk_candidat_personne`
    FOREIGN KEY (`idPersonne`)
    REFERENCES `PERSONNE` (`idPersonne`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  -- Contrainte : le statut du candidat doit être 'disponible' ou 'indisponible'
  CONSTRAINT `chk_statut_candidat`
    CHECK (`statut` IN ('disponible', 'indisponible'))
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `EMPLOYE`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `EMPLOYE`;

CREATE TABLE IF NOT EXISTS `EMPLOYE` (
  `idEmploye` INT NOT NULL AUTO_INCREMENT,
  `idPersonne` INT NOT NULL,
  `role` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idEmploye`),
  INDEX `fk_employe_personne_idx` (`idPersonne` ASC) ,
  CONSTRAINT `fk_employe_personne`
    FOREIGN KEY (`idPersonne`)
    REFERENCES `PERSONNE` (`idPersonne`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  -- Contrainte : le rôle doit être parmi les valeurs autorisées
  CONSTRAINT `chk_role_employe`
    CHECK (`role` IN ('Directeur', 'Manager', 'Secrétaire', 'Accompagnateur'))
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DIPLOME`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `DIPLOME`;

CREATE TABLE IF NOT EXISTS `DIPLOME` (
  `idDiplome` INT NOT NULL AUTO_INCREMENT,
  `libelle` VARCHAR(100) NOT NULL,
  `niveauEtude` VARCHAR(45) NULL,
  `idCandidat` INT NOT NULL,
  PRIMARY KEY (`idDiplome`),
  INDEX `fk_diplome_candidat_idx` (`idCandidat` ASC),
  CONSTRAINT `fk_diplome_candidat`
    FOREIGN KEY (`idCandidat`)
    REFERENCES `CANDIDAT` (`idCandidat`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `COMPETENCE`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `COMPETENCE`;

CREATE TABLE IF NOT EXISTS `COMPETENCE` (
  `idCompetence` INT NOT NULL AUTO_INCREMENT,
  `libelle` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`idCompetence`)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `MAITRISE` (Candidat <-> Compétence)
-- -----------------------------------------------------
DROP TABLE IF EXISTS `MAITRISE`;

CREATE TABLE IF NOT EXISTS `MAITRISE` (
  `idCandidat` INT NOT NULL,
  `idCompetence` INT NOT NULL,
  PRIMARY KEY (`idCandidat`, `idCompetence`),
  INDEX `fk_maitrise_competence_idx` (`idCompetence` ASC),
  CONSTRAINT `fk_maitrise_candidat`
    FOREIGN KEY (`idCandidat`)
    REFERENCES `CANDIDAT` (`idCandidat`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_maitrise_competence`
    FOREIGN KEY (`idCompetence`)
    REFERENCES `COMPETENCE` (`idCompetence`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `METIER`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `METIER`;

CREATE TABLE IF NOT EXISTS `METIER` (
  `idMetier` INT NOT NULL AUTO_INCREMENT,
  `libelle` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`idMetier`)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CANDIDAT_METIER` (Candidat <-> Métier)
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CANDIDAT_METIER`;

CREATE TABLE IF NOT EXISTS `CANDIDAT_METIER` (
  `idCandidat` INT NOT NULL,
  `idMetier` INT NOT NULL,
  PRIMARY KEY (`idCandidat`, `idMetier`),
  INDEX `fk_cm_metier_idx` (`idMetier` ASC),
  CONSTRAINT `fk_cm_candidat`
    FOREIGN KEY (`idCandidat`)
    REFERENCES `CANDIDAT` (`idCandidat`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_cm_metier`
    FOREIGN KEY (`idMetier`)
    REFERENCES `METIER` (`idMetier`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `EXPERIENCE_PROFESSIONNELLE`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `EXPERIENCE_PROFESSIONNELLE`;

CREATE TABLE IF NOT EXISTS `EXPERIENCE_PROFESSIONNELLE` (
  `idExperience` INT NOT NULL AUTO_INCREMENT,
  `description` TEXT NULL,
  `dateDebut` DATE NOT NULL,
  `dateFin` DATE NULL,
  `typeExperience` VARCHAR(45) NOT NULL,
  `idCandidat` INT NOT NULL,
  PRIMARY KEY (`idExperience`),
  INDEX `fk_exp_candidat_idx` (`idCandidat` ASC),
  CONSTRAINT `fk_exp_candidat`
    FOREIGN KEY (`idCandidat`)
    REFERENCES `CANDIDAT` (`idCandidat`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  -- Contrainte : le type d'expérience doit être parmi les valeurs autorisées
  CONSTRAINT `chk_type_experience`
    CHECK (`typeExperience` IN ('CDI', 'CDD', 'Stage', 'Bénévolat'))
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ENTREPRISE`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ENTREPRISE`;

CREATE TABLE IF NOT EXISTS `ENTREPRISE` (
  `idEntreprise` INT NOT NULL AUTO_INCREMENT,
  `nomEntreprise` VARCHAR(100) NOT NULL,
  `adresse` VARCHAR(100) NULL,
  `telephone` VARCHAR(20) NULL,
  PRIMARY KEY (`idEntreprise`)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `OFFRE_EMPLOI`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `OFFRE_EMPLOI`;

CREATE TABLE IF NOT EXISTS `OFFRE_EMPLOI` (
  `idOffre` INT NOT NULL AUTO_INCREMENT,
  `intitule` VARCHAR(100) NOT NULL,
  `tauxHoraire` DECIMAL(10,2) NOT NULL,
  `heuresMensuelles` INT NOT NULL,
  `dateDebut` DATE NOT NULL,
  `dateFin` DATE NULL,
  `statut` VARCHAR(20) NOT NULL DEFAULT 'ouverte',
  `dateFermeture` DATE NULL,
  `typeContrat` VARCHAR(20) NOT NULL,
  `idEntreprise` INT NOT NULL,
  `idSalarieGestionnaire` INT NOT NULL,
  `idCandidatRetenu` INT NULL,
  PRIMARY KEY (`idOffre`),
  INDEX `fk_offre_entreprise_idx` (`idEntreprise` ASC),
  INDEX `fk_offre_salarie_idx` (`idSalarieGestionnaire` ASC),
  INDEX `fk_offre_candidat_idx` (`idCandidatRetenu` ASC),
  CONSTRAINT `fk_offre_entreprise`
    FOREIGN KEY (`idEntreprise`)
    REFERENCES `ENTREPRISE` (`idEntreprise`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_offre_salarie`
    FOREIGN KEY (`idSalarieGestionnaire`)
    REFERENCES `EMPLOYE` (`idEmploye`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_offre_candidat`
    FOREIGN KEY (`idCandidatRetenu`)
    REFERENCES `CANDIDAT` (`idCandidat`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  -- Contrainte : le statut de l'offre doit être 'ouverte' ou 'fermée'
  CONSTRAINT `chk_statut_offre`
    CHECK (`statut` IN ('ouverte', 'fermée')),
  -- Contrainte : le type de contrat doit être parmi les valeurs autorisées
  CONSTRAINT `chk_type_contrat`
    CHECK (`typeContrat` IN ('CDI', 'CDD', 'Stage', 'Intérim')),
  -- Contrainte : le taux horaire doit être positif
  CONSTRAINT `chk_taux_horaire`
    CHECK (`tauxHoraire` > 0),
  -- Contrainte : les heures mensuelles doivent être positives
  CONSTRAINT `chk_heures_mensuelles`
    CHECK (`heuresMensuelles` > 0),
  -- Contrainte : si CDI alors pas de date de fin, sinon date de fin obligatoire
  CONSTRAINT `chk_contrat_date_fin`
    CHECK (
      (`typeContrat` = 'CDI' AND `dateFin` IS NULL)
      OR (`typeContrat` <> 'CDI' AND `dateFin` IS NOT NULL)
    )
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CANDIDATURE`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CANDIDATURE`;

CREATE TABLE IF NOT EXISTS `CANDIDATURE` (
  `idOffre` INT NOT NULL,
  `idCandidat` INT NOT NULL,
  `dateCandidature` DATE NOT NULL,
  `statutCandidature` VARCHAR(20) NOT NULL DEFAULT 'en attente',
  PRIMARY KEY (`idOffre`, `idCandidat`),
  INDEX `fk_cand_candidat_idx` (`idCandidat` ASC),
  CONSTRAINT `fk_cand_offre`
    FOREIGN KEY (`idOffre`)
    REFERENCES `OFFRE_EMPLOI` (`idOffre`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_cand_candidat`
    FOREIGN KEY (`idCandidat`)
    REFERENCES `CANDIDAT` (`idCandidat`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  -- Contrainte : le statut de la candidature doit être parmi les valeurs autorisées
  CONSTRAINT `chk_statut_candidature`
    CHECK (`statutCandidature` IN ('en attente', 'acceptée', 'refusée'))
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `OFFRE_METIER` (Offre <-> Métier)
-- -----------------------------------------------------
DROP TABLE IF EXISTS `OFFRE_METIER`;

CREATE TABLE IF NOT EXISTS `OFFRE_METIER` (
  `idOffre` INT NOT NULL,
  `idMetier` INT NOT NULL,
  PRIMARY KEY (`idOffre`, `idMetier`),
  INDEX `fk_om_metier_idx` (`idMetier` ASC),
  CONSTRAINT `fk_om_offre`
    FOREIGN KEY (`idOffre`)
    REFERENCES `OFFRE_EMPLOI` (`idOffre`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_om_metier`
    FOREIGN KEY (`idMetier`)
    REFERENCES `METIER` (`idMetier`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `OFFRE_COMPETENCE` (Offre <-> Compétence)
-- -----------------------------------------------------
DROP TABLE IF EXISTS `OFFRE_COMPETENCE`;

CREATE TABLE IF NOT EXISTS `OFFRE_COMPETENCE` (
  `idOffre` INT NOT NULL,
  `idCompetence` INT NOT NULL,
  PRIMARY KEY (`idOffre`, `idCompetence`),
  INDEX `fk_oc_competence_idx` (`idCompetence` ASC),
  CONSTRAINT `fk_oc_offre`
    FOREIGN KEY (`idOffre`)
    REFERENCES `OFFRE_EMPLOI` (`idOffre`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_oc_competence`
    FOREIGN KEY (`idCompetence`)
    REFERENCES `COMPETENCE` (`idCompetence`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
