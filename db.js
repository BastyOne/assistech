// db.js
const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: 'localhost', // Cambia esto al host de tu base de datos MySQL
  user: 'root', // Cambia esto a tu usuario de MySQL
  password: '12345', // Cambia esto a tu contraseña de MySQL
  database: 'assistech' // Cambia esto al nombre de tu base de datos
});

connection.connect((err) => {
  if (err) {
    console.error('Error al conectar a la base de datos: ' + err.message);
  } else {
    console.log('Conexión a la base de datos MySQL exitosa');
  }
});

module.exports = connection;
