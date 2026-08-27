-- Base de données d'une agence d'intérim
-- Chargement de données fictives destinées à la démonstration et aux tests.

USE `recruitment_agency`;

-- =============================================
-- PERSONNE (15 personnes)
-- =============================================
INSERT INTO `PERSONNE` (`idPersonne`, `nom`, `prenom`, `dateNaissance`, `adresse`, `email`, `telephone`) VALUES
(1,  'Dupont',    'Marie',     '1985-03-15', '12 Rue de la Paix, Paris',       'marie.dupont@email.fr',     '0601020304'),
(2,  'Martin',    'Pierre',    '1990-07-22', '5 Avenue Victor Hugo, Lyon',     'pierre.martin@email.fr',    '0611223344'),
(3,  'Bernard',   'Sophie',    '1988-11-03', '8 Boulevard Gambetta, Marseille', 'sophie.bernard@email.fr',   '0622334455'),
(4,  'Dubois',    'Jean',      '1975-01-28', '3 Rue Pasteur, Grenoble',        'jean.dubois@email.fr',      '0633445566'),
(5,  'Moreau',    'Claire',    '1992-05-10', '17 Rue de Rivoli, Paris',        'claire.moreau@email.fr',    '0644556677'),
(6,  'Laurent',   'Thomas',    '1980-09-18', '22 Rue Nationale, Lille',        'thomas.laurent@email.fr',   '0655667788'),
(7,  'Simon',     'Julie',     '1995-12-07', '9 Place Bellecour, Lyon',        'julie.simon@email.fr',      '0666778899'),
(8,  'Michel',    'Lucas',     '1987-04-25', '14 Rue de la République, Lyon',  'lucas.michel@email.fr',     '0677889900'),
(9,  'Garcia',    'Emma',      '1993-08-14', '6 Rue du Commerce, Bordeaux',    'emma.garcia@email.fr',      '0688990011'),
(10, 'Roux',      'Antoine',   '1978-02-20', '11 Avenue Jean Jaurès, Toulouse','antoine.roux@email.fr',     '0699001122'),
(11, 'Lefevre',   'Camille',   '1991-06-30', '7 Rue Voltaire, Nantes',        'camille.lefevre@email.fr',  '0610111213'),
(12, 'Fournier',  'Nicolas',   '1983-10-12', '20 Rue de Strasbourg, Grenoble', 'nicolas.fournier@email.fr', '0620212223'),
(13, 'Girard',    'Léa',       '1996-01-19', '4 Place de la Comédie, Montpellier','lea.girard@email.fr',    '0630313233'),
(14, 'Bonnet',    'Hugo',      '2000-03-08', '15 Rue Sainte-Catherine, Bordeaux','hugo.bonnet@email.fr',    '0640414243'),
(15, 'Petit',     'Manon',     '1998-07-25', '1 Rue de la Liberté, Dijon',     'manon.petit@email.fr',      '0650515253');


-- =============================================
-- EMPLOYE (5 employés : personnes 1 à 5)
-- =============================================
INSERT INTO `EMPLOYE` (`idEmploye`, `idPersonne`, `role`) VALUES
(1, 1, 'Directeur'),
(2, 2, 'Manager'),
(3, 3, 'Secrétaire'),
(4, 4, 'Accompagnateur'),
(5, 5, 'Accompagnateur');


-- =============================================
-- CANDIDAT (12 candidats : personnes 6 à 15, plus personnes 4 et 5)
-- Les personnes 4 et 5 sont à la fois employées et candidates.
-- =============================================
INSERT INTO `CANDIDAT` (`idCandidat`, `idPersonne`, `description`, `statut`) VALUES
(1,  6,  'Développeur fullstack avec 5 ans d expérience',           'disponible'),
(2,  7,  'Jeune diplômée en analyse de données',                    'disponible'),
(3,  8,  'Ingénieur système et réseau expérimenté',                 'disponible'),
(4,  9,  'Spécialiste en marketing digital',                        'disponible'),
(5,  10, 'Charpentier avec 20 ans d expérience',                    'indisponible'),
(6,  11, 'Professeur de mathématiques certifié',                    'disponible'),
(7,  12, 'Soudeur industriel qualifié',                             'disponible'),
(8,  13, 'Étudiante en informatique cherchant un stage',            'disponible'),
(9,  14, 'Technicien de maintenance polyvalent',                    'disponible'),
(10, 15, 'Assistante administrative bilingue',                      'disponible'),
(11, 4,  'Accompagnateur cherchant un nouveau poste',               'disponible'),
(12, 5,  'Accompagnatrice avec compétences en gestion de projet',   'indisponible');


-- =============================================
-- ENTREPRISE (5 entreprises)
-- =============================================
INSERT INTO `ENTREPRISE` (`idEntreprise`, `nomEntreprise`, `adresse`, `telephone`) VALUES
(1, 'TechVision SAS',       '100 Avenue de la Tech, Paris',         '0140506070'),
(2, 'BatiPro Construction', '25 Zone Industrielle, Lyon',           '0472838494'),
(3, 'DataSphere SARL',      '8 Rue de l Innovation, Grenoble',     '0476112233'),
(4, 'EcoServices',          '12 Boulevard Vert, Bordeaux',          '0556677889'),
(5, 'FormationPlus',        '3 Place de la Formation, Toulouse',    '0561223344');


-- =============================================
-- METIER (10 métiers)
-- =============================================
INSERT INTO `METIER` (`idMetier`, `libelle`) VALUES
(1,  'Développeur Web'),
(2,  'Analyste Data'),
(3,  'Charpentier'),
(4,  'Soudeur'),
(5,  'Professeur'),
(6,  'Technicien Réseau'),
(7,  'Chef de Projet'),
(8,  'Assistant Administratif'),
(9,  'Ingénieur Système'),
(10, 'Spécialiste Marketing');


-- =============================================
-- COMPETENCE (20 compétences)
-- =============================================
INSERT INTO `COMPETENCE` (`idCompetence`, `libelle`) VALUES
(1,  'Java'),
(2,  'MySQL'),
(3,  'Python'),
(4,  'JavaScript'),
(5,  'HTML/CSS'),
(6,  'Logiciels bureautiques'),
(7,  'Métallurgie'),
(8,  'Dessin Technique'),
(9,  'Formation'),
(10, 'Gestion de projet'),
(11, 'Analyse de données'),
(12, 'Linux'),
(13, 'Réseaux informatiques'),
(14, 'Soudure TIG/MIG'),
(15, 'Charpente bois'),
(16, 'Marketing digital'),
(17, 'Communication'),
(18, 'Anglais courant'),
(19, 'Comptabilité'),
(20, 'Maintenance industrielle');


-- =============================================
-- DIPLOME (diplômes des candidats)
-- =============================================
INSERT INTO `DIPLOME` (`idDiplome`, `libelle`, `niveauEtude`, `idCandidat`) VALUES
(1,  'Licence Informatique',              'Licence',  1),
(2,  'Master Développement Web',          'Master',   1),
(3,  'DUT Statistiques',                  'DUT',      2),
(4,  'Licence MIASHS',                    'Licence',  2),
(5,  'Master Ingénierie Réseau',          'Master',   3),
(6,  'BTS Marketing',                     'BTS',      4),
(7,  'CAP Charpentier',                   'CAP',      5),
(8,  'CAPES Mathématiques',               'Master',   6),
(9,  'CAP Soudeur',                       'CAP',      7),
(10, 'Baccalauréat Scientifique',         'Bac',      8),
(11, 'BTS Maintenance Industrielle',      'BTS',      9),
(12, 'BTS Assistant de Direction',         'BTS',      10);


-- =============================================
-- CANDIDAT_METIER (candidats <-> métiers)
-- =============================================
INSERT INTO `CANDIDAT_METIER` (`idCandidat`, `idMetier`) VALUES
(1,  1),   -- Thomas → Développeur Web
(1,  7),   -- Thomas → Chef de Projet
(2,  2),   -- Julie → Analyste Data
(3,  6),   -- Lucas → Technicien Réseau
(3,  9),   -- Lucas → Ingénieur Système
(4,  10),  -- Emma → Spécialiste Marketing
(5,  3),   -- Antoine → Charpentier
(6,  5),   -- Camille → Professeur
(7,  4),   -- Nicolas → Soudeur
(8,  1),   -- Léa → Développeur Web
(8,  2),   -- Léa → Analyste Data
(9,  6),   -- Hugo → Technicien Réseau
(10, 8),   -- Manon → Assistant Administratif
(11, 7),   -- Jean (employé+candidat) → Chef de Projet
(12, 7);   -- Claire (employé+candidat) → Chef de Projet


-- =============================================
-- MAITRISE (candidats <-> compétences)
-- =============================================
INSERT INTO `MAITRISE` (`idCandidat`, `idCompetence`) VALUES
(1,  1),   -- Thomas → Java
(1,  2),   -- Thomas → MySQL
(1,  4),   -- Thomas → JavaScript
(1,  5),   -- Thomas → HTML/CSS
(2,  3),   -- Julie → Python
(2,  2),   -- Julie → MySQL
(2,  11),  -- Julie → Analyse de données
(3,  12),  -- Lucas → Linux
(3,  13),  -- Lucas → Réseaux informatiques
(4,  16),  -- Emma → Marketing digital
(4,  17),  -- Emma → Communication
(5,  15),  -- Antoine → Charpente bois
(5,  8),   -- Antoine → Dessin Technique
(6,  9),   -- Camille → Formation
(6,  18),  -- Camille → Anglais courant
(7,  7),   -- Nicolas → Métallurgie
(7,  14),  -- Nicolas → Soudure TIG/MIG
(8,  3),   -- Léa → Python
(8,  4),   -- Léa → JavaScript
(8,  5),   -- Léa → HTML/CSS
(9,  12),  -- Hugo → Linux
(9,  20),  -- Hugo → Maintenance industrielle
(10, 6),   -- Manon → Logiciels bureautiques
(10, 18),  -- Manon → Anglais courant
(10, 19);  -- Manon → Comptabilité


-- =============================================
-- OFFRE_EMPLOI (10 offres avec différents statuts)
-- =============================================
INSERT INTO `OFFRE_EMPLOI` (`idOffre`, `intitule`, `tauxHoraire`, `heuresMensuelles`, `dateDebut`, `dateFin`, `statut`, `dateFermeture`, `typeContrat`, `idEntreprise`, `idSalarieGestionnaire`, `idCandidatRetenu`) VALUES
(1,  'Développeur Java Senior',        25.00, 151, '2026-03-01', NULL,         'ouverte', NULL,         'CDI',   1, 2, NULL),
(2,  'Analyste Data Junior',           18.00, 151, '2026-04-01', '2027-03-31', 'ouverte', NULL,         'CDD',   3, 2, NULL),
(3,  'Charpentier Expérimenté',        22.00, 160, '2026-05-01', NULL,         'fermée',  '2026-03-15', 'CDI',   2, 4, 5),
(4,  'Soudeur Industriel',             20.00, 160, '2026-04-15', '2026-10-15', 'ouverte', NULL,         'CDD',   2, 4, NULL),
(5,  'Stage Développement Web',        12.00, 151, '2026-06-01', '2026-08-31', 'ouverte', NULL,         'Stage', 1, 5, NULL),
(6,  'Professeur de Maths',            24.00, 140, '2026-09-01', '2027-06-30', 'ouverte', NULL,         'CDD',   5, 3, NULL),
(7,  'Chef de Projet IT',              30.00, 151, '2026-04-01', NULL,         'fermée',  '2026-03-20', 'CDI',   3, 2, 1),
(8,  'Technicien Réseau',              19.00, 151, '2026-05-01', '2026-11-30', 'ouverte', NULL,         'CDD',   1, 5, NULL),
(9,  'Assistant Administratif',        15.00, 151, '2026-04-01', '2027-03-31', 'ouverte', NULL,         'CDD',   4, 3, NULL),
(10, 'Spécialiste Marketing Digital',  21.00, 151, '2026-06-01', NULL,         'ouverte', NULL,         'CDI',   4, 5, NULL);


-- =============================================
-- OFFRE_METIER (offres <-> métiers)
-- =============================================
INSERT INTO `OFFRE_METIER` (`idOffre`, `idMetier`) VALUES
(1,  1),   -- Développeur Java → Développeur Web
(2,  2),   -- Analyste Data → Analyste Data
(3,  3),   -- Charpentier → Charpentier
(4,  4),   -- Soudeur → Soudeur
(5,  1),   -- Stage Dev Web → Développeur Web
(6,  5),   -- Professeur → Professeur
(7,  7),   -- Chef de Projet → Chef de Projet
(7,  9),   -- Chef de Projet → Ingénieur Système
(8,  6),   -- Technicien Réseau → Technicien Réseau
(9,  8),   -- Assistant Admin → Assistant Administratif
(10, 10);  -- Marketing → Spécialiste Marketing


-- =============================================
-- OFFRE_COMPETENCE (offres <-> compétences)
-- =============================================
INSERT INTO `OFFRE_COMPETENCE` (`idOffre`, `idCompetence`) VALUES
(1,  1),   -- Développeur Java → Java
(1,  2),   -- Développeur Java → MySQL
(2,  3),   -- Analyste Data → Python
(2,  11),  -- Analyste Data → Analyse de données
(3,  15),  -- Charpentier → Charpente bois
(3,  8),   -- Charpentier → Dessin Technique
(4,  7),   -- Soudeur → Métallurgie
(4,  14),  -- Soudeur → Soudure TIG/MIG
(5,  4),   -- Stage Dev Web → JavaScript
(5,  5),   -- Stage Dev Web → HTML/CSS
(6,  9),   -- Professeur → Formation
(7,  10),  -- Chef de Projet → Gestion de projet
(7,  13),  -- Chef de Projet → Réseaux informatiques
(8,  12),  -- Technicien → Linux
(8,  13),  -- Technicien → Réseaux informatiques
(9,  6),   -- Assistant Admin → Logiciels bureautiques
(10, 16),  -- Marketing → Marketing digital
(10, 17);  -- Marketing → Communication


-- =============================================
-- CANDIDATURE (candidatures des candidats)
-- =============================================
INSERT INTO `CANDIDATURE` (`idOffre`, `idCandidat`, `dateCandidature`, `statutCandidature`) VALUES
-- Offre 1 (Développeur Java) : 2 candidats
(1,  1,  '2026-02-20', 'en attente'),   -- Thomas postule
(1,  8,  '2026-02-25', 'en attente'),   -- Léa postule

-- Offre 2 (Analyste Data) : 2 candidats
(2,  2,  '2026-03-10', 'en attente'),   -- Julie postule
(2,  8,  '2026-03-12', 'en attente'),   -- Léa postule

-- Offre 3 (Charpentier) : fermée, Antoine retenu
(3,  5,  '2026-02-01', 'acceptée'),     -- Antoine retenu

-- Offre 4 (Soudeur) : 1 candidat
(4,  7,  '2026-03-20', 'en attente'),   -- Nicolas postule

-- Offre 5 (Stage Dev Web) : 1 candidat
(5,  8,  '2026-04-01', 'en attente'),   -- Léa postule

-- Offre 6 (Professeur) : 1 candidat
(6,  6,  '2026-03-25', 'en attente'),   -- Camille postule

-- Offre 7 (Chef de Projet) : fermée, Thomas retenu
(7,  1,  '2026-03-01', 'acceptée'),     -- Thomas retenu
(7,  11, '2026-03-05', 'refusée'),      -- Jean refusé

-- Offre 8 (Technicien Réseau) : 2 candidats
(8,  3,  '2026-03-28', 'en attente'),   -- Lucas postule
(8,  9,  '2026-03-30', 'en attente'),   -- Hugo postule

-- Offre 9 (Assistant Admin) : 1 candidat
(9,  10, '2026-03-15', 'en attente'),   -- Manon postule

-- Offre 10 (Marketing) : 1 candidat
(10, 4,  '2026-04-02', 'en attente');   -- Emma postule


-- =============================================
-- EXPERIENCE_PROFESSIONNELLE
-- =============================================
INSERT INTO `EXPERIENCE_PROFESSIONNELLE` (`idExperience`, `description`, `dateDebut`, `dateFin`, `typeExperience`, `idCandidat`) VALUES
(1,  'Développeur Web chez WebAgency',           '2021-09-01', '2024-08-31', 'CDD',       1),
(2,  'Développeur Java chez InfoTech',            '2024-09-01', NULL,         'CDI',       1),
(3,  'Stage analyse de données chez StatCorp',    '2025-03-01', '2025-08-31', 'Stage',     2),
(4,  'Administrateur réseau chez NetPro',         '2018-01-15', '2023-06-30', 'CDI',       3),
(5,  'Community Manager chez SocialMedia',        '2022-06-01', '2025-05-31', 'CDD',       4),
(6,  'Charpentier chez BatiPro Construction',     '2005-03-01', NULL,         'CDI',       5),
(7,  'Professeur vacataire au lycée Victor Hugo', '2023-09-01', '2024-06-30', 'CDD',       6),
(8,  'Soudeur chez MetalWork',                    '2019-04-01', '2025-03-31', 'CDD',       7),
(9,  'Stage développement chez StartupXYZ',       '2025-06-01', '2025-08-31', 'Stage',     8),
(10, 'Technicien maintenance chez IndustriePlus', '2023-01-15', '2025-12-31', 'CDD',       9),
(11, 'Assistante administrative chez AdminPro',   '2024-01-01', NULL,         'CDI',       10),
(12, 'Bénévolat association Les Restos du Coeur', '2022-01-01', '2022-12-31', 'Bénévolat', 6);
