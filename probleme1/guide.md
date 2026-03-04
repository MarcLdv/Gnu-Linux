# Guide (How-to) pour la mise en place d'une solution d'anonymisation des données

## Objectif

Ce guide permet de comprendre dans un premier temps comment identifier les données personnelles et définir leurs durées de conservations d'un schéma de données MYSQL. Il décrit ensuite la mise en place d'un système automatique d'anonymisation des données à l'aide de CRON, puis la génération de rapports donnant le chiffre d'affaires TTC total par mois.

## Initialisation des données

En reprenant les tablet clients et factures on peut commencer à déterminer quelles données sont à classifier en tant que personelles. En prenant en compte le réglement du RGPD on peut aussi définir les durées de conservations pour les factures.

### Classification des données

**Client :**

| Champ | Classification |
| :------ | :------ |
| id | Donnée unique (ne permet pas d'identification) |
| nom | Donnée personnelle (identification indirecte) |
| prenom | Donnée personnelle (identification indirecte) |
| email | Identification directe (identifiant unique) |
| adresse | Donnée personnelle (localisation) |
| mot_de_passe | Donnée confidentielle (ne permet pas d'identification) |

**Facture :**

| Champ | Classification |
| :------ | :------ |
| id | Donnée unique (ne permet pas d'identification) |
| montant | Donnée non personnelle |
| date_facture | Donnée non personnelle |
| client_id | Donnée personnelle indirecte (clé étrangère vers client) |

Dans ces données on peut voir que plusieurs d'entre elles sont personelles d'une façon directe ou indirecte. Afin de respecter le RGPD et être en capacité de générer les rapports voulus elles doivent donc être anonymisées.

### Durée de conservation

| Entité | Durée active (base prod) | Durée totale (base prod + archive) | Justification |
| :------ | :------ | :------ | :------ |
| Client | 3 ans après dernière facture | 10 ans | RGPD : 3 ans fin relation commerciale |
| Facture | 10 ans | 10 ans | Obligation légale comptable |

### Fonctionnement du processus d'archivage

Pour mettre en place le processus d'archivage il y a deux étapes. D'un coté pour les clients, c'est après 3 ans d'inactivité (aucune nouvelle facture) que ces données sont archivées anonymement grâce à un identifiant unique généré aléatoirement dans la base d'archive puis supprimées de la base de production. Pour les factures, elles restent en base de production pendant 10 ans, puis sont archivées en utilisant ce même identifiant pour garder le lien avec les données archivées.

Pour ce qui est des durées de conservation, c'est la CNIL qui considère qu'une relation commerciale est terminée au bout 3 ans d'inactivité et qui impose ensuite l'anonymisation des données clients. Pour les factures le RPGD ne fournit pas de durée précise mais l'un des principe  majeurs est la limitation de conservation (Article 5). On peut donc prendre le délai minimum imposé par le code du commerce qu est de 10 ans pour des factures, pour ensuite les stockées également de façon anonyme.

## Méthode d'archivage

### Tables d'archivage

Afin d'obtenir des données réellement anonymisées il faut supprimer tous les champs permettant une identification direct ou indirecte. On garde tout de même un identifiant anonyme pour effectuer un lien entre les données clients archivées et leurs factures.

**Client Archivé :**

| Champ | Classification |
| :------ | :------ |
| id | Donnée unique (ne permet pas d'identification) |
| ano_id | Identifiant anonyme (UUID généré aléatoirement) |
| date_archivage | Donnée non personnelle |

**Facture Archivé :**

| Champ | Classification |
| :------ | :------ |
| id | Donnée unique (ne permet pas d'identification) |
| ano_id | Identifiant anonyme (UUID généré aléatoirement) |
| montant | Donnée non personnelle |
| date_facture | Donnée non personnelle |

Avec ces tables d'archivage on ne garde que les données essentielles et utiles pour la génération de rapports d'activités, en effet, souhaitant récupérer le CA TTC par mois il n'est pas nécessaire de garder les informations clientes. L'identifiant anonyme est généré de façon totalement aléatoire via un UUID, ce qui garantit qu'il n'existe aucun lien avec l'id original du client. Cet identifiant permet uniquement de lier les factures archivées entre elles pour les rapports.

## Mise en place des tâches CRON

