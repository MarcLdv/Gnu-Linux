-- Création de la base de production
CREATE DATABASE IF NOT EXISTS app_prod;

USE app_prod;

CREATE TABLE IF NOT EXISTS clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    adresse TEXT,
    mot_de_passe VARCHAR(255) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS factures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    montant DECIMAL(10, 2) NOT NULL,
    date_facture DATE NOT NULL,
    client_id INT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE CASCADE,
    INDEX idx_date_facture (date_facture),
    INDEX idx_client_id (client_id)
);

-- Création de la base d'archive
CREATE DATABASE IF NOT EXISTS app_archive;

USE app_archive;

CREATE TABLE IF NOT EXISTS clients_archives (
    id INT PRIMARY KEY,
    ano_id VARCHAR(36) NOT NULL UNIQUE,
    date_archivage TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ano_id (ano_id)
);

CREATE TABLE IF NOT EXISTS factures_archives (
    id INT PRIMARY KEY,
    ano_id VARCHAR(36) NOT NULL,
    montant DECIMAL(10, 2) NOT NULL,
    date_facture DATE NOT NULL,
    date_archivage TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ano_id) REFERENCES clients_archives (ano_id),
    INDEX idx_date_facture (date_facture),
    INDEX idx_ano_id (ano_id)
);