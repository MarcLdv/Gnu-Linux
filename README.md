# Gnu-Linux

## Problème choisi

Problème 1 : Se conformer au RGPD, une application pratique

## Auteurs

Marc LEBRETON DE VONNE
Victor LE FLOCH

## Schéma de la solution

Un schéma de base de données illustrant l'architecture de la solution (tables de production et d'archive avec leurs relations) est disponible ici : [schema-rgpd.png](probleme1/schema-rgpd.png)

## Remarques / Commentaires / Motivations

### Motivations

Notre choix de sujet s'est porté vers le premier car nous avons auparavant déjà travaillé sur un système d'anonymisation de données pendant la troisième année de notre BUT. Pendant la réalisation de ce système nous avons rencontré beaucoup de difficultés à réellement anonymiser un jeu de données complet, car il était toujours possible de retrouver une personne en combinant plusieurs champs, cependant nous avions apprécié la réflexion derrière pour comprendre comment identifier les données personnelles et ce qu'il fallait mettre en place pour se conformer au RGPD. La mise en place d'un système automatique nous a donc intéressés pour savoir comment nous aurions pu mettre en place une solution plus simple et robuste. De plus, nous avons préféré prendre un sujet traitant de CRON dont nous avons peu de connaissance plutôt que le problème deux qui utilise des méthodes qu'on a vues en cours (sauf pour Candy que nous ne connaissions pas).  

### Remarques

Lors de la conception initiale, nous pensions mettre en place une anonymisation en conservant l'ID original du client dans la table d'archive. Cependant, en réfléchissant aux risques potentiels, nous avons réalisé qu'en cas de fuite ou d'accès à un log de la base de données, quelqu'un ayant eu connaissance de l'ancienne structure pourrait facilement retrouver l'identité des personnes concernées en croisant l'ID archivé avec d'anciennes sauvegardes. C'est à ce moment que nous avons compris notre erreur : nous étions en train de faire de la pseudonymisation, pas de l'anonymisation. Nous avons donc perdu du temps sur cette réflexion avant de réaliser qu'il fallait directement utiliser un UUID généré aléatoirement pour garantir une véritable anonymisation sans aucun lien retrouvable avec les données d'origine.

### Commentaires

Le format how-to était demandé dans le sujet, mais nous avons eu quelques difficultés à adopter le bon ton pour rédiger un véritable guide pratique plutôt qu'un simple tutoriel. L'enjeu était de trouver le bon équilibre entre les explications techniques, les justifications réglementaires et les instructions concrètes.

## Références

### RGPD et CNIL

- [RGPD - Article 5](https://eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX:32016R0679) : Principes relatifs au traitement des données personnelles (limitation de conservation)
- [CNIL - Durées de conservation](https://www.cnil.fr/fr/les-durees-de-conservation-des-donnees) : Guide sur les durées de conservation des données (3 ans pour fin de relation commerciale)
  
### Documentation technique

- [Cron - Crontab Guide](https://crontab.guru/) : Planification de tâches automatiques sous Linux
- [MySQL Documentation](https://dev.mysql.com/doc/) : Gestion des bases de données relationnelles
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/) : Automatisation des processus d'archivage et de reporting
