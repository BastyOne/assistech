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
  const { username, password } = req.body;

  // Buscar el usuario en la base de datos
  const userQuery = 'SELECT * FROM usuarios WHERE username = ?';
  const userValues = [username];

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
    });
  });
});

app.post('/register', (req, res) => {
  const { username, password, roleId } = req.body;

  bcrypt.hash(password, saltRounds, (err, hash) => {
    if (err) {
      return res.status(500).json({ error: 'Error del servidor' });
    }

    const userQuery = 'INSERT INTO usuarios (username, password, rol_id) VALUES (?, ?, ?)';
    const userValues = [username, hash, roleId];

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
