-- Run once as an admin user (phpMyAdmin or the mysql CLI).
-- Creates a database and user dedicated to GeoWars, separate from every other project.
-- Replace CHANGE_ME with a real password and put the same value in .env (DB_PASSWORD).

CREATE DATABASE IF NOT EXISTS geowars CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'geowars'@'localhost' IDENTIFIED BY 'CHANGE_ME';
CREATE USER IF NOT EXISTS 'geowars'@'127.0.0.1' IDENTIFIED BY 'CHANGE_ME';
GRANT ALL PRIVILEGES ON geowars.* TO 'geowars'@'localhost';
GRANT ALL PRIVILEGES ON geowars.* TO 'geowars'@'127.0.0.1';
FLUSH PRIVILEGES;
