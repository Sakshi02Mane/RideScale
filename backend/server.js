const express = require("express");
const rideController = require("./rideController");

const app = express();
const PORT = 3000;

app.get("/ride/:id", rideController.getRideById);

app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
});
