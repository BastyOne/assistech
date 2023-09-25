const express = require('express');
const app = express();
const port = 3000; // Puedes cambiar el puerto según tus preferencias
const db = require('./db'); // Importa la conexión a la base de datos
const bcrypt = require('bcrypt');
const saltRounds = 10;

app.use(express.json());

app.listen(port, () => {
  console.log(`Servidor Node.js en ejecución en http://192.168.100.81:${port}`);
});

// Define el punto final para registrar estudiantes (ruta POST)
app.post('/registrar-estudiante', (req, res) => {
  const { nombre, rut, correo } = req.body;

  const estudianteQuery = 'INSERT INTO estudiantes (nombre, rut, correo) VALUES (?, ?, ?)';
  const estudianteValues = [nombre, rut, correo];

  db.query(estudianteQuery, estudianteValues, (err, results) => {
    if (err) {
      console.error('Error al registrar estudiante: ' + err.message);
      res.status(500).json({ error: 'Error al registrar estudiante' });
    } else {
      console.log('Estudiante registrado con éxito');
      res.status(200).json({ message: 'Estudiante registrado con éxito', estudianteId: results.insertId });
    }
  });
});


app.post('/registrar-geofence', (req, res) => {
  const { name, latitude, longitude, radius, estudiante_id } = req.body;

  const geofenceQuery = 'INSERT INTO geofences (name, latitude, longitude, radius, estudiante_id) VALUES (?, ?, ?, ?, ?)';
  const geofenceValues = [name, latitude, longitude, radius, estudiante_id];

  db.query(geofenceQuery, geofenceValues, (err, geofenceResults) => {
    if (err) {
      console.error('Error al registrar geofence: ' + err.message);
      res.status(500).json({ error: 'Error al registrar geofence' });
    } else {
      console.log('Geofence registrado con éxito');
      res.status(200).json({ message: 'Geofence registrado con éxito' });
    }
  });
});


app.post('/login', async (req, res) => {
  const { rut, password } = req.body;

  // Buscar el usuario en la base de datos
  const userQuery = 'SELECT * FROM usuarios WHERE rut = ?';
  const userValues = [rut];

  db.query(userQuery, userValues, async (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Error del servidor' });
    }

    if (results.length === 0) {
      return res.status(401).json({ error: 'Usuario o contraseña incorrecta' });
    }

    const match = await bcrypt.compare(password, results[0].password);
    if (!match) {
      return res.status(401).json({ error: 'Usuario o contraseña incorrecta' });
    }

    // Buscar el rol del usuario
    const roleQuery = 'SELECT nombre FROM roles WHERE id = ?';
    const roleValues = [results[0].rol_id];

    db.query(roleQuery, roleValues, (err, roleResults) => {
      if (err) {
        return res.status(500).json({ error: 'Error del servidor' });
      }

      // Enviar la respuesta con los detalles del usuario y el rol
      res.status(200).json({ user: results[0], role: roleResults[0].nombre });
      console.log(`Usuario con RUT: ${rut} ha iniciado sesión correctamente.`);
    });
  });
});

app.post('/register', (req, res) => {
  const { rut, password, roleId } = req.body;

  bcrypt.hash(password, saltRounds, (err, hash) => {
    if (err) {
      return res.status(500).json({ error: 'Error del servidor' });
    }

    const userQuery = 'INSERT INTO usuarios (rut, password, rol_id) VALUES (?, ?, ?)';
    const userValues = [rut, hash, roleId];

    db.query(userQuery, userValues, (err, results) => {
      if (err) {
        console.error('Error al registrar usuario: ' + err.message);
        res.status(500).json({ error: 'Error al registrar usuario' });
      } else {
        console.log('Usuario registrado con éxito');
        res.status(200).json({ message: 'Usuario registrado con éxito', userId: results.insertId });
      }
    });
  });
});

app.get('/get-roles', (req, res) => {
  const roleQuery = 'SELECT * FROM roles';

  db.query(roleQuery, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Error del servidor' });
    }

    res.status(200).json(results);
  });
});

app.get('/get-salas', (req, res) => {
  const salasQuery = 'SELECT * FROM salas';

  db.query(salasQuery, (err, results) => {
    if (err) {
      console.error('Error al obtener las salas: ' + err.message);
      return res.status(500).json({ error: 'Error del servidor al obtener las salas' });
    }
    res.status(200).json(results);
  });
});

app.get('/get-materias', (req, res) => {
  const materiasQuery = 'SELECT * FROM materias';

  db.query(materiasQuery, (err, results) => {
    if (err) {
      console.error('Error al obtener las materias: ' + err.message);
      return res.status(500).json({ error: 'Error del servidor al obtener las materias' });
    }
    res.status(200).json(results);
  });
});

app.get('/salaDetails/:salaId', (req, res) => {
  const salaId = req.params.salaId;  // Obteniendo el ID de la sala desde los parámetros de la URL

  // Usando las columnas correctas de tu tabla `salas`
  const salaDetailsQuery = 'SELECT latitude, longitude, radius FROM salas WHERE id = ?';
  const salaDetailsValues = [salaId];

  db.query(salaDetailsQuery, salaDetailsValues, (err, results) => {
    if (err) {
      console.error('Error al obtener los detalles de la sala: ' + err.message);
      return res.status(500).json({ error: 'Error del servidor al obtener los detalles de la sala' });
    }

    if (results.length === 0) {
      // No se encontraron detalles para esa sala.
      return res.status(404).json({ error: 'No se encontraron detalles para esa sala' });
    }

    res.status(200).json(results[0]);  // Devolvemos el primer resultado ya que estamos buscando detalles por ID único
  });
});

app.post('/crear-clase-programada', (req, res) => {
  const { sala_id, materia_id, profesor_id } = req.body;

  const insertQuery = 'INSERT INTO clases_programadas (sala_id, materia_id, profesor_id) VALUES (?, ?, ?)';
  const values = [sala_id, materia_id, profesor_id];

  db.query(insertQuery, values, (err, results) => {
    if (err) {
      console.error('Error al crear una clase programada: ' + err.message);
      return res.status(500).json({ error: 'Error al crear una clase programada' });
    }

    // Una vez creada la clase programada, asignamos la materia al profesor
    const assignMateriaQuery = 'INSERT INTO profesor_materia (profesor_id, materia_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE profesor_id = profesor_id';
    db.query(assignMateriaQuery, [profesor_id, materia_id], (err, _) => {
      if (err) {
        console.error('Error al asignar materia a profesor: ' + err.message);
        return res.status(500).json({ error: 'Error al asignar materia a profesor' });
      }
      console.log('Clase programada creada con éxito y materia asignada al profesor')
      res.status(200).json({ message: 'Clase programada creada con éxito y materia asignada al profesor', claseId: results.insertId });
    });
  });
});
app.post('/registrar-asistencia', (req, res) => {
  const { estudiante_id, clase_programada_id } = req.body;

  const insertQuery = 'INSERT INTO asistencias (estudiante_id, clase_programada_id) VALUES (?, ?)';
  const values = [estudiante_id, clase_programada_id];

  db.query(insertQuery, values, (err, results) => {
    if (err) {
      console.error('Error al registrar asistencia: ' + err.message);
      return res.status(500).json({ error: 'Error al registrar asistencia' });
    }
    res.status(200).json({ message: 'Asistencia registrada con éxito' });
  });
});

