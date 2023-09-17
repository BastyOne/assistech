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


select * from geofences;
select * from estudiantes;
delete from geofences;
drop table geofences;
drop table estudiantes;