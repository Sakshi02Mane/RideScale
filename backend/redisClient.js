const redis = require("redis");

const client = redis.createClient({
    url: "redis://localhost:6379"
});

client.on("error", (err) => {
    console.error("Redis Error:", err);
});

(async () => {
    await client.connect();
    console.log("Redis connected");
})();

module.exports = client;