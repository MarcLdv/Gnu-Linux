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

## Mise en place de la base de données

### Préparation de l'environnement

Avant de commencer il faut configurer les variables d'environnement pour la connexion à MYSQL. Pour cela, créez un fichier `.env` à partir du fichier [.env.example](./.env.example) avec les commandes qui suivent :

```bash
cp .env.example .env
nano .env
```

Chaque variables doit être définie selon votre configuration MySQL, notamment le mot de passe (`DB_PASSWORD`) et les noms de bases de données (`DB_PROD` et `DB_ARCHIVE`). Si c'est la premère fois que vous utiliser MYSQL vous aurez besoin de définir le mot de passe via la commande :

```bash
sudo mysql_secure_installation`
```

### Initialisation des bases de données

Une fois l'environnement configuré, il faut créer les bases de données ainsi que leurs tables. Pour cela, il faut se déplacer dans le dossier des scripts à l'aide de :

```bash
cd scripts/
```

Puis il faut éxecuter le script d'initialisation qui va créer la base de production et d'archive avec leurs tables associées :

```bash
mysql -u root -p < init.sql
```

Cette commande exécute le script [init.sql](scripts/init.sql) en tant qu'utilisateur root, il faudrait donc indiquer votre mot de passe associé à l'utilisateur. En cas d'erreur d'accès ou si les bases existent déjà, vérifiez votre mot de passe et variables dans le fichier `.env`.

Si tout s'est déroulé comme prévu vous pouvez vous connecter à la base de production et lister les tables créées :

```bash
mysql -u root -p app_prod
```

Une fois connecté avec le prompt `mysql>`, listez les tables :

```sql
SHOW TABLES;
```

Les tables clients et factures devraient alors apparaître. Pour quitter MYSQL il suffit de tapper `exit`.

### Peuplement de la base

Maintenant que les bases sont créées, il faut y ajouter des données de test. Le script [seed.sql](scripts/seed.sql) va créer des données fictives dans la base de production.

Depuis le dossier `scripts/`, exécutez la commande :

```bash
mysql -u root -p < seed.sql
```

Le mot de passe root sera de nouveau demandé. Une fois de plus vous pouvez vérifier que le peuplement a fonctionné, en se reconnectant à la base de production :

```bash
mysql -u root -p app_prod
```

Et en vérifiant le nombre d'enregistrements dans les deux tables :

```sql
SELECT COUNT(*) FROM clients;
SELECT COUNT(*) FROM factures;
```

Si les résultats sont supérieures à zéro, c'est que le peuplement a bien fonctionné.

## Archivage automatique

### Script d'archivage

Une fois la base initialisée, la prochaine étape est la mise en place d'un script s'exécutant automatiquement afin d'archiver les données inactives. Ce dernier sera exécuté tous les jours à la même horraire pour toujours avoir les données d'archives à jour.

Le détail du script est accessible ici [archive_data.sh](scripts/archive_data.sh)

### Automatisation

Pour planifier l'exécution automatique du script d'archivage, il faut ajouter une tâche CRON grâce à  l'éditeur crontab :

```bash
crontab -e
```

Le système vous demandera dans un premier temps choisir un éditeur, vous pouvez prendre celui par défault (nano) ou bien en choisir un autre plus adapté. Il faut ensuite ajouter cette ligne dans le fichier :

```bash
0 2 * * * /chemin/vers/scripts/archive_data.sh >> /var/log/archives.log 2>&1
```

Cette configuration lance le script tous les jours à 2h du matin. Remplacez `/chemin/vers/scripts/` par le chemin absolu vers votre dossier de scripts. Le résultat de l'exécution sera enregistré dans le fichier de log `/var/log/archives.log`.

Une fois la ligne ajoutée, sauvegardez et quittez l'éditeur (avec nano : `Ctrl+S`, puis `Ctrl+X`). Pour vérifier si tâche a bien été ajoutée, il est possible de lister les CRON via la commande :

```bash
crontab -l
```

## Génération automatique de rapports

Une fois les données archivées et supprimées on peut mettre en place le système de génération de rapports. Pour cela il faudra suivre les mêmes étapes que pour l'archivage.

### Script de génération des rapports

Ce script va prendre en paramètre deux périodes écrites de cette façon `mois/année, mois/année` par exemple `01/25, 03/25`. Le script va alors récupérer toutes les factures depuis la date de départ puis il va afficher le CA TTC par mois jusqu'à la date de fin. Le tout sera placé dans un fichier report.

### Automatisation des rapports

Pour planifier la génération automatique des rapports, il faut ouvrir à nouveau l'éditeur crontab :

```bash
crontab -e
```

Et y ajouter les lignes suivantes pour programmer les deux types de rapports :

```bash
# RAPPORT mensuel automatique (mois précédent) - 1er du mois à 3h
0 3 1 * * /chemin/vers/scripts/rapport-mensuel.sh >> /var/log/rgpd-mensuel.log 2>&1

# RAPPORT annuel - 22 décembre à 4h
0 4 22 12 * /chemin/vers/scripts/rapport.sh 202512 >> /var/log/rgpd-annuel.log 2>&1
```

Comme pour l'archivage, remplacez `/chemin/vers/scripts/` par le chemin absolu vers votre dossier de scripts. Sauvegardez et quittez l'éditeur. Les rapports seront maintenant générés automatiquement selon les horaires définis.
