const mysql = require("mysql2/promise");

const pool = mysql.createPool({
    host: "localhost",
    user: "root",
    password: "123@Sonumonu",
    database: "ridescale",
    waitForConnections: true,
    connectionLimit: 10
});

module.exports = pool;
