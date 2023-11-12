const express = require('express');
const app = express();
const port = 3000; // Puedes cambiar el puerto según tus preferencias
const db = require('./db'); // Importa la conexión a la base de datos
const bcrypt = require('bcrypt');
const saltRounds = 10;
const moment = require('moment');

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

app.post('/registersala', (req, res) => {
  const { codigo, nombre, latitude, longitude, radius } = req.body;

  const salaQuery = 'INSERT INTO salas (codigo, nombre, latitude, longitude, radius) VALUES (?, ?, ?, ?, ?)';
  const salaValues = [codigo, nombre, latitude, longitude, radius];

  db.query(salaQuery, salaValues, (err, results) => {
    if (err) {
      console.error('Error al registrar sala: ' + err.message);
      res.status(500).json({ error: 'Error al registrar sala' });
    } else {
      console.log('Sala registrada con éxito');
      res.status(200).json({ message: 'Sala registrada con éxito', salaId: results.insertId });
    }
  });
});

app.post('/register-materia', async (req, res) => {
  try {
    const { nombre } = req.body;

    // Asegúrate de que el nombre no esté vacío
    if (!nombre) {
      return res.status(400).json({ error: 'El campo nombre no puede estar vacío' });
    }

    // Realiza la inserción en la base de datos
    const insertQuery = 'INSERT INTO materias (nombre) VALUES (?)';
    const insertValues = [nombre];

    db.query(insertQuery, insertValues, (err, results) => {
      if (err) {
        console.error('Error al registrar la materia: ' + err.message);
        return res.status(500).json({ error: 'Error al registrar la materia' });
      }

      console.log('Materia registrada exitosamente');
      return res.status(200).json({ message: 'Materia registrada exitosamente', materiaId: results.insertId });
    });
  } catch (error) {
    console.error('Error al procesar la solicitud: ' + error.message);
    return res.status(500).json({ error: 'Error al procesar la solicitud' });
  }
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
    console.log(`Asistencia registrada con éxito para el estudiante con ID: ${estudiante_id} en la clase con ID: ${clase_programada_id}`);
    res.status(200).json({ message: 'Asistencia registrada con éxito' });
  });
});

app.post('/crear-chequeo', (req, res) => {
  const { estudiante_id, clase_programada_id } = req.body;
  // Asegúrate de validar los datos recibidos!

  const insertQuery = 'INSERT INTO chequeos (estudiante_id, clase_programada_id, fecha_hora_entrada) VALUES (?, ?, CURRENT_TIMESTAMP)';
  const values = [estudiante_id, clase_programada_id];

  db.query(insertQuery, values, (err, results) => {
    if (err) {
      console.error('Error al crear chequeo: ' + err.message);
      return res.status(500).json({ error: 'Error al crear chequeo' });
    }
    console.log(`Chequeo creado con éxito para el estudiante con ID: ${estudiante_id} en la clase con ID: ${clase_programada_id}`);
    res.status(200).json({ message: 'Chequeo creado con éxito', chequeoId: results.insertId });
  });
});

app.put('/actualizar-chequeo', (req, res) => {
  const { chequeo_id, hora_salida } = req.body;

  // Validación de los datos recibidos
  if (!chequeo_id || !hora_salida) {
    return res.status(400).json({ error: 'chequeo_id y hora_salida son requeridos' });
  }

  const updateQuery = 'UPDATE chequeos SET fecha_hora_salida = ? WHERE id = ?';
  const values = [hora_salida, chequeo_id];

  db.query(updateQuery, values, (err, results) => {
    if (err) {
      console.error('Error al actualizar chequeo: ' + err.message);
      return res.status(500).json({ error: 'Error al actualizar chequeo' });
    }
    console.log(`Chequeo con ID: ${chequeo_id} actualizado con éxito`);
    res.status(200).json({ message: 'Chequeo actualizado con éxito' });
  });
});

app.get('/filtrar-asistencia/fecha', (req, res) => {
  let fecha = req.query.fecha;
  const profesorId = req.query.profesor_id; // Recibir el profesor_id como parámetro

  // Validación de la fecha
  if (!fecha || !moment(fecha, 'YYYY-MM-DD', true).isValid()) {
    return res.status(400).json({ error: 'Formato de fecha inválido. Utilice YYYY-MM-DD.' });
  }

  // Validación del profesor_id
  if (!profesorId || isNaN(profesorId)) {
    return res.status(400).json({ error: 'ID de profesor inválido o no proporcionado.' });
  }

  // Ajustar formato de fecha si es necesario
  fecha = moment(fecha).format('YYYY-MM-DD');

  const query = `
    SELECT a.*, e.nombre, cp.fecha_hora, s.nombre AS nombre_sala, m.nombre AS nombre_materia
    FROM asistencias a
    JOIN estudiantes e ON a.estudiante_id = e.id
    JOIN clases_programadas cp ON a.clase_programada_id = cp.id
    JOIN salas s ON cp.sala_id = s.id
    JOIN materias m ON cp.materia_id = m.id
    WHERE DATE(cp.fecha_hora) = ? AND cp.profesor_id = ?
  `;

  db.query(query, [fecha, profesorId], (err, results) => {
    if (err) {
      console.error('Error al filtrar asistencias por fecha: ' + err.message);
      return res.status(500).json({ error: 'Error interno del servidor' });
    }
    res.status(200).json(results);
  });
});


app.get('/filtrar-asistencia/materia', (req, res) => {
  const nombreMateria = req.query.nombre_materia;
  const profesorId = req.query.profesor_id;

  // Validación del nombre de la materia
  if (!nombreMateria) {
    return res.status(400).json({ error: 'El nombre de la materia es requerido.' });
  }

  // Validación del profesor_id
  if (!profesorId || isNaN(profesorId)) {
    return res.status(400).json({ error: 'ID de profesor inválido o no proporcionado.' });
  }

  const query = `
    SELECT a.*, e.nombre AS nombre_estudiante, cp.fecha_hora, m.nombre AS nombre_materia
    FROM asistencias a
    JOIN estudiantes e ON a.estudiante_id = e.id
    JOIN clases_programadas cp ON a.clase_programada_id = cp.id
    JOIN materias m ON cp.materia_id = m.id
    WHERE m.nombre = ? AND cp.profesor_id = ?
  `;

  db.query(query, [nombreMateria, profesorId], (err, results) => {
    if (err) {
      console.error('Error al filtrar asistencias por materia: ' + err.message);
      return res.status(500).json({ error: 'Error interno del servidor' });
    }
    res.status(200).json(results);
  });
});


app.get('/filtrar-asistencia/sala', (req, res) => {
  const codigoSala = req.query.codigo_sala;
  const profesorId = req.query.profesor_id;

  // Validación del código de la sala
  if (!codigoSala) {
    return res.status(400).json({ error: 'El código de la sala es requerido.' });
  }

  // Validación del profesor_id
  if (!profesorId || isNaN(profesorId)) {
    return res.status(400).json({ error: 'ID de profesor inválido o no proporcionado.' });
  }

  const query = `
    SELECT a.*, e.nombre AS nombre_estudiante, cp.fecha_hora, s.nombre AS nombre_sala
    FROM asistencias a
    JOIN estudiantes e ON a.estudiante_id = e.id
    JOIN clases_programadas cp ON a.clase_programada_id = cp.id
    JOIN salas s ON cp.sala_id = s.id
    WHERE s.codigo = ? AND cp.profesor_id = ?
  `;

  db.query(query, [codigoSala, profesorId], (err, results) => {
    if (err) {
      console.error('Error al filtrar asistencias por sala: ' + err.message);
      return res.status(500).json({ error: 'Error interno del servidor' });
    }
    res.status(200).json(results);
  });
});

app.get('/filtrar-asistencia', (req, res) => {
  const { fecha, materia, sala, profesor_id } = req.query;

  // Aquí, construirías la consulta SQL basándote en los parámetros proporcionados
  let baseQuery = `
    SELECT a.*, e.nombre AS nombre_estudiante, cp.fecha_hora, s.nombre AS nombre_sala, m.nombre AS nombre_materia
    FROM asistencias a
    JOIN estudiantes e ON a.estudiante_id = e.id
    JOIN clases_programadas cp ON a.clase_programada_id = cp.id
    JOIN salas s ON cp.sala_id = s.id
    JOIN materias m ON cp.materia_id = m.id
    WHERE cp.profesor_id = ?
  `;
  let queryParams = [profesor_id];
  
  // Agregar condiciones adicionales a la consulta si se proporcionan parámetros específicos
  if (fecha) {
    baseQuery += ' AND DATE(cp.fecha_hora) = ?';
    queryParams.push(fecha);
  }
  if (materia) {
    baseQuery += ' AND m.nombre = ?';
    queryParams.push(materia);
  }
  if (sala) {
    baseQuery += ' AND s.codigo = ?';
    queryParams.push(sala);
  }

  db.query(baseQuery, queryParams, (err, results) => {
    if (err) {
      console.error('Error al filtrar asistencias: ' + err.message);
      return res.status(500).json({ error: 'Error al filtrar asistencias' });
    }
    res.status(200).json(results);
  });
});





