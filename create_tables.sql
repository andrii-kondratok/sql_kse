DROP DATABASE IF EXISTS as1;
CREATE DATABASE as1;
use as1;

create table names_monsters(
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

create table hp_monsters(
	id INT AUTO_INCREMENT PRIMARY KEY,
    hp INT NOT NULL
);

create table alig_monsters(
	id INT AUTO_INCREMENT PRIMARY KEY,
    alignment VARCHAR(100) NOT NULL
);

create table cr_monsters(
	id INT AUTO_INCREMENT PRIMARY KEY,
    cr INT NOT NULL
);

create table speed_monsters(
	id INT AUTO_INCREMENT PRIMARY KEY,
    speed INT NOT NULL
);