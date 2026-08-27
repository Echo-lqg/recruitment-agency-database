# Base de données pour une agence d'intérim - MySQL

Base de données relationnelle conçue pour soutenir les activités principales d'une agence d'intérim : gestion des personnes et des candidats, entreprises, offres d'emploi, candidatures, métiers, compétences, diplômes et expériences professionnelles.

Ce dépôt présente un projet universitaire en équipe sous la forme d'un portfolio technique concis. Il contient le modèle de données, des scripts MySQL exécutables, des requêtes métier représentatives et des automatisations au niveau de la base. Les consignes de cours et le rapport universitaire complet sont volontairement exclus.

## Contexte métier

L'agence doit disposer d'un modèle cohérent pour :

- gérer les employés, les candidats et les entreprises clientes ;
- publier et suivre les offres d'emploi et les candidatures ;
- relier candidats et offres par les métiers et les compétences ;
- enregistrer le candidat retenu pour une offre pourvue ;
- analyser les placements, les commissions et la performance des employés ;
- appliquer les règles de recrutement et de conservation des données au plus près de la base.

Tous les noms, coordonnées, entreprises et enregistrements opérationnels présents dans les données d'exemple sont fictifs.

## Conception de la base

L'implémentation contient 14 tables. Les entités principales, notamment `PERSONNE`, `CANDIDAT`, `EMPLOYE`, `ENTREPRISE` et `OFFRE_EMPLOI`, sont séparées des tables d'association comme `CANDIDATURE`, `MAITRISE`, `CANDIDAT_METIER`, `OFFRE_METIER` et `OFFRE_COMPETENCE`.

Le modèle a été structuré jusqu'à la troisième forme normale (3FN) : les attributs sont atomiques, les relations plusieurs-à-plusieurs sont représentées par des tables d'association avec clés composites, et chaque information descriptive est stockée avec l'entité dont elle dépend. Les clés étrangères, contraintes `CHECK` et index renforcent l'intégrité référentielle et la validation des domaines.

### Modèle conceptuel de données

![Modèle conceptuel de données](schema/conceptual-model.png)

### Modèle logique relationnel

![Modèle relationnel](schema/relational-model.png)


## Principaux cas d'usage SQL

Le fichier de requêtes traduit plusieurs questions opérationnelles en SQL :

- lister les candidatures avec le candidat, l'offre et l'entreprise ;
- analyser les candidatures par candidat et par offre ;
- calculer la commission mensuelle de l'agence et le nombre de postes pourvus ;
- calculer les commissions et placements par employé de recrutement ;
- identifier avec un `LEFT JOIN` les compétences sans candidat associé ;
- rapprocher une offre ouverte de candidats disponibles partageant un métier ou une compétence, en excluant ceux qui ont déjà postulé ;
- créer des candidatures en attente à partir de la vue de rapprochement ;
- fermer une offre, enregistrer le candidat retenu et mettre à jour les statuts des candidatures.

Le rapprochement de candidats combine une vue, `UNION`, plusieurs jointures, `DISTINCT` et une sous-requête. Il s'agit d'une logique déterministe fondée sur des règles métier, et non d'un système de recommandation par IA.

## Vues, triggers et procédures stockées

`03_business_queries.sql` crée `V_CANDIDATS_POTENTIELS`, une vue réutilisable pour identifier les candidats potentiels.

`04_business_rules.sql` implémente sept triggers et deux procédures stockées. Ces règles permettent notamment de :

- bloquer la suppression physique des offres ;
- enregistrer automatiquement la date de fermeture d'une offre ;
- conserver l'historique de recrutement grâce à l'anonymisation d'un candidat ;
- empêcher l'affectation d'un candidat déjà sous contrat actif ;
- empêcher la réattribution d'une offre déjà pourvue ;
- rétablir la disponibilité après la fin d'un contrat ;
- imposer un âge minimum de 16 ans lors de l'inscription d'un candidat.

Le même script contient des cas d'échec commentés et des exemples de validation réussie.

## Structure du dépôt

```text
recruitment-agency-database/
├── README.md
├── schema/
│   ├── conceptual-model.png
│   ├── relational-model.png
│   └── source-model.mwb
└── sql/
    ├── 01_schema.sql
    ├── 02_sample_data.sql
    ├── 03_business_queries.sql
    └── 04_business_rules.sql
```

## Exécution locale

Prérequis : MySQL 8.0+ et, facultativement, MySQL Workbench.

Exécuter les scripts dans l'ordre numérique :

```bash
mysql -u <utilisateur> -p < sql/01_schema.sql
mysql -u <utilisateur> -p < sql/02_sample_data.sql
mysql -u <utilisateur> -p < sql/03_business_queries.sql
mysql -u <utilisateur> -p < sql/04_business_rules.sql
```

Les scripts recréent et utilisent un schéma nommé `recruitment_agency`. Le premier script supprime ce schéma s'il existe déjà : utilisez donc une instance locale dédiée aux essais.

## Technologies et méthodes

MySQL 8.0+, MySQL Workbench, SQL, modélisation relationnelle, MCD/MLD, normalisation en 3FN, jointures, agrégations, sous-requêtes, vues, triggers, procédures stockées, contraintes et index.

## Attribution du projet

Ce travail a été réalisé dans le cadre d'un projet universitaire en binôme. La modélisation, les requêtes SQL, les vues, triggers, procédures stockées, tests et revues ont été partagés au sein de l'équipe. Ce dépôt réorganise le travail technique existant pour le présenter dans un portfolio ; il ne revendique pas l'attribution individuelle de l'intégralité du projet.
