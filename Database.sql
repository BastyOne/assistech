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
    rut VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol_id INT,
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);

CREATE TABLE salas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
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

CREATE TABLE materias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL
);


CREATE TABLE profesor_materia (
    profesor_id INT,
    materia_id INT,
    PRIMARY KEY (profesor_id, materia_id),
    FOREIGN KEY (profesor_id) REFERENCES usuarios(id),
    FOREIGN KEY (materia_id) REFERENCES materias(id)
);

CREATE TABLE clases_programadas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sala_id INT,
    materia_id INT,
    profesor_id INT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sala_id) REFERENCES salas(id),
    FOREIGN KEY (materia_id) REFERENCES materias(id),
    FOREIGN KEY (profesor_id) REFERENCES usuarios(id)
);

ALTER TABLE asistencias ADD COLUMN clase_programada_id INT;
ALTER TABLE asistencias ADD FOREIGN KEY (clase_programada_id) REFERENCES clases_programadas(id);











INSERT INTO roles (nombre) VALUES ('estudiante'), ('profesor');
INSERT INTO roles (nombre) VALUES ('administrador');


-- Insertar la sala 101 con coordenadas específicas y un radio de 10 metros
INSERT INTO salas (codigo, nombre, latitude, longitude, radius) 
VALUES ('S101', 'Sala 101', 40.7128, -74.0060, 10.0);

-- Insertar la sala 102 con coordenadas diferentes y un radio de 15 metros
INSERT INTO salas (codigo, nombre, latitude, longitude, radius) 
VALUES ('S102', 'Sala 102', 34.0522, -118.2437, 15.0);

-- Insertar la sala 103 con otras coordenadas y un radio de 20 metros
INSERT INTO salas (codigo, nombre, latitude, longitude, radius) 
VALUES ('S103', 'Sala 103', 51.5074, -0.1278, 20.0);



INSERT INTO materias (nombre) 
VALUES ('Gestion Informática');

INSERT INTO materias (nombre) 
VALUES ('Seguridad de la Informacion')

INSERT INTO materias (nombre) 
VALUES ('Taller de desarrollo de software');



UPDATE usuarios
SET rol_id = 3
WHERE id = id;

20519669 admin = colocolo1
20565639 profesor = 1234

select * from roles;
select * from salas;
select * from geofences;
select * from estudiantes;
select * from usuarios;
delete from geofences;
drop table geofences;
drop table estudiantes;
drop table roles;
drop table usuarios;
