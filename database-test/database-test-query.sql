-- SIPERPUS - Database Test
-- Target: MySQL 8+

DROP DATABASE IF EXISTS siperpus;
CREATE DATABASE siperpus;
USE siperpus;

CREATE TABLE categories (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(255) NOT NULL,
    ktp_number VARCHAR(32) NOT NULL UNIQUE,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE books (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    category_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL,
    publisher VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    publication_year YEAR NOT NULL,
    available_quantity INT UNSIGNED NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_books_category
        FOREIGN KEY (category_id) REFERENCES categories(id),
    CONSTRAINT chk_books_quantity CHECK (available_quantity >= 0)
);

CREATE TABLE loans (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    book_id BIGINT UNSIGNED NOT NULL,
    borrowed_at DATE NOT NULL,
    due_at DATE NOT NULL,
    returned_at DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_loans_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_loans_book
        FOREIGN KEY (book_id) REFERENCES books(id),
    CONSTRAINT chk_loan_dates CHECK (due_at >= borrowed_at),
    CONSTRAINT chk_return_date CHECK (returned_at IS NULL OR returned_at >= borrowed_at)
);

CREATE INDEX idx_loans_user ON loans(user_id);
CREATE INDEX idx_loans_book ON loans(book_id);
CREATE INDEX idx_loans_returned_due ON loans(returned_at, due_at);

-- 5 categories
INSERT INTO categories (name) VALUES
('Teknologi'),
('Pemrograman'),
('Bisnis'),
('Sains'),
('Novel');

-- 5 users
INSERT INTO users (name, address, ktp_number, phone, email) VALUES
('User 1', 'Jl. Melati No. 1', '3273010101010001', '081200000001', 'user1@example.com'),
('User 2', 'Jl. Melati No. 2', '3273010101010002', '081200000002', 'user2@example.com'),
('User 3', 'Jl. Melati No. 3', '3273010101010003', '081200000003', 'user3@example.com'),
('User 4', 'Jl. Melati No. 4', '3273010101010004', '081200000004', 'user4@example.com'),
('User 5', 'Jl. Melati No. 5', '3273010101010005', '081200000005', 'user5@example.com');

-- 10 books; Buku 10 intentionally has no loan record.
INSERT INTO books (category_id, title, author, publisher, isbn, publication_year, available_quantity) VALUES
(1, 'Buku 1', 'Author 1', 'Publisher 1', '9780000000001', 2020, 1),
(2, 'Buku 2', 'Author 2', 'Publisher 2', '9780000000002', 2020, 1),
(3, 'Buku 3', 'Author 3', 'Publisher 3', '9780000000003', 2021, 1),
(4, 'Buku 4', 'Author 4', 'Publisher 4', '9780000000004', 2021, 1),
(5, 'Buku 5', 'Author 5', 'Publisher 5', '9780000000005', 2022, 1),
(1, 'Buku 6', 'Author 6', 'Publisher 1', '9780000000006', 2022, 1),
(2, 'Buku 7', 'Author 7', 'Publisher 2', '9780000000007', 2023, 1),
(3, 'Buku 8', 'Author 8', 'Publisher 3', '9780000000008', 2023, 1),
(4, 'Buku 9', 'Author 9', 'Publisher 4', '9780000000009', 2024, 1),
(5, 'Buku 10', 'Author 10', 'Publisher 5', '9780000000010', 2024, 1);

-- 9 loans: User 1 -> books 1-3, User 2 -> 4-6, User 3 -> 7-9.
-- User 3 / Buku 9 is returned 5 days after the due date.
INSERT INTO loans (user_id, book_id, borrowed_at, due_at, returned_at) VALUES
(1, 1, '2026-09-01', '2026-09-08', '2026-09-07'),
(1, 2, '2026-09-01', '2026-09-08', '2026-09-08'),
(1, 3, '2026-09-02', '2026-09-09', '2026-09-09'),
(2, 4, '2026-09-03', '2026-09-10', '2026-09-10'),
(2, 5, '2026-09-03', '2026-09-10', '2026-09-09'),
(2, 6, '2026-09-04', '2026-09-11', '2026-09-11'),
(3, 7, '2026-09-05', '2026-09-12', '2026-09-12'),
(3, 8, '2026-09-05', '2026-09-12', '2026-09-12'),
(3, 9, '2026-09-05', '2026-09-12', '2026-09-17');

-- ============================================================
-- 1. Buku yang tidak pernah dipinjam oleh siapapun
-- Expected: Buku 10
-- ============================================================
SELECT
    b.title AS Buku
FROM books b
LEFT JOIN loans l ON l.book_id = b.id
WHERE l.id IS NULL
ORDER BY b.id;

-- ============================================================
-- 2. User yang pernah mengembalikan buku terlambat beserta denda
-- Denda = Rp1.000 per hari terlambat.
-- Expected: User 3 | Rp5000
-- ============================================================
SELECT
    u.name AS User,
    SUM(DATEDIFF(l.returned_at, l.due_at) * 1000) AS Denda
FROM users u
JOIN loans l ON l.user_id = u.id
WHERE l.returned_at IS NOT NULL
  AND l.returned_at > l.due_at
GROUP BY u.id, u.name
ORDER BY u.id;

-- ============================================================
-- 3. User dengan daftar buku yang dipinjam
-- Expected order: User 1 -> Buku 3, Buku 2, Buku 1, etc.
-- ============================================================
SELECT
    u.id AS No,
    u.name AS User,
    GROUP_CONCAT(b.title ORDER BY b.id DESC SEPARATOR ', ') AS Buku
FROM users u
JOIN loans l ON l.user_id = u.id
JOIN books b ON b.id = l.book_id
GROUP BY u.id, u.name
ORDER BY u.id;