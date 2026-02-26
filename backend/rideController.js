const db = require("./db");
const redisClient = require("./redisClient");

exports.getRideById = async (req, res) => {
    const rideId = req.params.id;
    const cacheKey = `ride:${rideId}`;

    try {
        // 1️⃣ Check Redis
        const cachedRide = await redisClient.get(cacheKey);

        if (cachedRide) {
            console.log("✅ Cache HIT");
            return res.json(JSON.parse(cachedRide));
        }

        console.log("❌ Cache MISS - Fetching from MySQL");

        // 2️⃣ Fetch from MySQL
        const [rows] = await db.execute(
            "SELECT * FROM cab_rides_raw WHERE id = ?",
            [rideId]
        );

        if (rows.length === 0) {
            return res.status(404).json({ message: "Ride not found" });
        }

        const ride = rows[0];

        // 3️⃣ Store in Redis (TTL 60 seconds)
        await redisClient.setEx(cacheKey, 60, JSON.stringify(ride));

        res.json(ride);

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Something went wrong" });
    }
};
