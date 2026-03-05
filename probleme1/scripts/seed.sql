-- Peuplement de la base

USE app_prod;

INSERT INTO clients (nom, prenom, email, adresse, mot_de_passe) VALUES 
    (
        'Martin',
        'Jean',
        'jean.martin@email.com',
        '12 Rue de la Paix, 75001 Paris',
        '$2y$10$abcdefghijklmnopqrstuv'
    ),
    (
        'Dupont',
        'Marie',
        'marie.dupont@email.com',
        '45 Avenue des Champs, 75008 Paris',
        '$2y$10$wxyzabcdefghijklmnopqr'
    ),
    (
        'Bernard',
        'Pierre',
        'pierre.bernard@email.com',
        '78 Boulevard Saint-Michel, 75005 Paris',
        '$2y$10$stuvwxyzabcdefghijklmn'
    ),
    (
        'Dubois',
        'Sophie',
        'sophie.dubois@email.com',
        '23 Rue du Faubourg, 69001 Lyon',
        '$2y$10$opqrstuvwxyzabcdefghi'
    ),
    (
        'Thomas',
        'Luc',
        'luc.thomas@email.com',
        '56 Place Bellecour, 69002 Lyon',
        '$2y$10$jklmnopqrstuvwxyzabcd'
    ),
    (
        'Robert',
        'Julie',
        'julie.robert@email.com',
        '89 Cours Mirabeau, 13100 Aix',
        '$2y$10$efghijklmnopqrstuvwxy'
    ),
    (
        'Richard',
        'Paul',
        'paul.richard@email.com',
        '34 Rue Nationale, 59000 Lille',
        '$2y$10$zabcdefghijklmnopqrst'
    ),
    (
        'Petit',
        'Claire',
        'claire.petit@email.com',
        '67 Avenue de la République, 33000 Bordeaux',
        '$2y$10$uvwxyzabcdefghijklmno'
    ),
    (
        'Durand',
        'Marc',
        'marc.durand@email.com',
        '12 Quai des Chartrons, 33000 Bordeaux',
        '$2y$10$pqrstuvwxyzabcdefghij'
    ),
    (
        'Leroy',
        'Anne',
        'anne.leroy@email.com',
        '90 Rue de la Liberté, 59000 Lille',
        '$2y$10$klmnopqrstuvwxyzabcde'
    );

INSERT INTO factures (montant, date_facture, client_id) VALUES 
    (150.50, '2024-01-15', 1),
    (230.75, '2024-03-22', 1),
    (89.99, '2024-06-10', 2),
    (456.20, '2024-08-05', 2),
    (125.00, '2025-01-12', 3),
    (340.80, '2025-02-28', 3),
    (78.50, '2025-05-14', 4),
    (567.30, '2025-09-20', 4),
    (190.00, '2025-11-03', 5),
    (425.60, '2026-01-08', 5);

INSERT INTO factures (montant, date_facture, client_id) VALUES 
    (200.00, '2020-03-15', 6),
    (150.00, '2020-06-22', 6),
    (300.50, '2019-11-10', 7),
    (450.75, '2020-01-18', 7),
    (180.00, '2018-08-05', 8),
    (220.30, '2019-12-20', 8);

INSERT INTO factures (montant, date_facture, client_id) VALUES
    (500.00, '2010-05-12', 9),
    (350.25, '2011-09-18', 9),
    (280.60, '2012-03-22', 10),
    (420.90, '2013-07-14', 10),
    (190.40, '2014-11-30', 1);