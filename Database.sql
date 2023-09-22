CREATE TABLE geofences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT,
    name VARCHAR(255),
    latitude DOUBLE,
    longitude DOUBLE,
    radius DOUBLE,
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id)
);

CREATE TABLE estudiantes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    rut VARCHAR(15),
    correo varchar(255),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol_id INT,
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);

CREATE TABLE salas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL,
    nombre VARCHAR(255),
    latitude DOUBLE,
    longitude DOUBLE,
    radius DOUBLE
);

CREATE TABLE asistencias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT,
    sala_id INT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (sala_id) REFERENCES salas(id)
);

INSERT INTO roles (nombre) VALUES ('estudiante'), ('profesor');
INSERT INTO roles (nombre) VALUES ('administrador');



UPDATE usuarios
SET rol_id = 3
WHERE id = id;

Waren estudiante = colocolo1
Bastian admin = colocolo
Mondaca profe = 1234

select * from roles;
select * from geofences;
select * from estudiantes;
select * from usuarios;
delete from geofences;
drop table geofences;
drop table estudiantes;
drop table roles;
drop table usuarios;