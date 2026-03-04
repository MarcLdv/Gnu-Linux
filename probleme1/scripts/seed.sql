# Jeu de données d'exemple pour la base de production
USE app_prod;

INSERT INTO client (nom, prenom, email, adresse, mot_de_passe, date_creation) VALUES
('Dupont', 'Jean', 'jean.dupont@email.com', '12 Rue de la Paix, 75001 Paris', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', '2021-03-15 10:30:00'),
('Martin', 'Sophie', 'sophie.martin@email.com', '45 Avenue des Champs, 69002 Lyon', '$2y$10$xyz789abcdefghijklmnopqrstuvwx', '2022-06-20 14:15:00'),
('Bernard', 'Lucas', 'lucas.bernard@email.com', '8 Boulevard Victor Hugo, 31000 Toulouse', '$2y$10$123456789abcdefghijklmnopqrstu', '2020-01-10 09:00:00'),
('Petit', 'Marie', 'marie.petit@email.com', '23 Rue du Commerce, 44000 Nantes', '$2y$10$uvwxyz123456789abcdefghijklmno', '2023-02-28 16:45:00'),
('Dubois', 'Pierre', 'pierre.dubois@email.com', '67 Cours de l\'Intendance, 33000 Bordeaux', '$2y$10$pqrstuv123456789abcdefghijklmn', '2021-09-05 11:20:00'),
('Moreau', 'Claire', 'claire.moreau@email.com', '15 Place Bellecour, 69002 Lyon', '$2y$10$mnopqrs987654321zyxwvutsrqpon', '2020-11-12 13:30:00');

INSERT INTO
    facture (
        client_id,
        montant,
        date_facture
    )
VALUES (1, 150.50, '2021-04-10'),
    (1, 320.00, '2021-07-22'),
    (1, 89.99, '2022-01-15'),
    (2, 450.75, '2022-08-05'),
    (2, 210.00, '2023-03-18'),
    (2, 680.50, '2024-01-10'),
    (3, 125.00, '2020-02-20'),
    (3, 95.30, '2020-08-14'),
    (3, 340.00, '2021-05-30'),
    (4, 580.00, '2023-04-12'),
    (4, 220.50, '2024-02-28'),
    (5, 790.00, '2021-10-08'),
    (5, 415.25, '2022-06-15'),
    (6, 260.00, '2021-01-25'),
    (6, 510.75, '2021-09-10');