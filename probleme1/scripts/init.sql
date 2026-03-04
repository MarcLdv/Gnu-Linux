# Script SQL d'initialisation de la base de données prod d'exemple
CREATE DATABASE IF NOT EXISTS app_prod;

CREATE TABLE client (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    email VARCHAR(255) NOT NULL UNIQUE,
    adresse TEXT,
    mot_de_passe VARCHAR(255) NOT NULL,
    date_creation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE facture (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    montant DECIMAL(10, 2) NOT NULL,
    date_facture DATE NOT NULL,
    FOREIGN KEY (client_id) REFERENCES client (id) ON DELETE CASCADE
);

# Script SQL d'initialisation de la base de données archive avec données anonymsées
CREATE DATABASE IF NOT EXISTS app_archive;

CREATE TABLE clients_archive (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pseudo_client_id VARCHAR(64) NOT NULL UNIQUE,
    date_archivage DATE
);

CREATE TABLE factures_archive (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pseudo_client_id VARCHAR(64) NOT NULL,
    montant DECIMAL(10, 2) NOT NULL,
    date_facture DATE NOT NULL,
    FOREIGN KEY (pseudo_client_id) REFERENCES clients_archive (pseudo_client_id)
);