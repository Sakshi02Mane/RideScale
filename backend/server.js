const express = require("express");
const db = require("./db");

const app = express();

app.get("/", async (req, res) => {
    try {
        const [rows] = await db.execute("SELECT 1");
        res.send("Backend + MySQL connected!");
    } catch (error) {
        console.error(error);
        res.status(500).send("Database connection failed");
    }
});

app.listen(3000, () => {
    console.log("Server running on port 3000");
});
