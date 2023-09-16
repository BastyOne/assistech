const express = require('express');
const app = express();
const port = 3000; // Puedes cambiar el puerto según tus preferencias
const db = require('./db'); // Importa la conexión a la base de datos

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
