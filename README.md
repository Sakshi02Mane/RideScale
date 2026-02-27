# 🚗 RideScale

A backend system for querying Uber-style cab ride data with high-performance caching and optimized database design. Built with **Node.js**, **Express**, **MySQL**, and **Redis**.

> Demonstrates real-world backend engineering concepts — Cache-Aside pattern, database normalization, hash-based sharding, and connection pooling.

---

## 📁 Project Structure

```
RideScale/
├── backend/
│   ├── server.js            # Entry point — starts Express server
│   ├── db.js                # MySQL connection pool
│   ├── redisClient.js       # Redis client setup
│   └── rideController.js    # Core business logic (cache + DB)
│
└── databasedesign/
    ├── raw_table.sql         # Stage 1 — flat raw data ingestion
    ├── normalized.sql        # Stage 2 — 3NF normalized schema
    └── sharding.sql          # Stage 3 — hash partitioned rides table
```

---

## ⚙️ Tech Stack

| Technology | Purpose |
|---|---|
| Node.js | Runtime environment |
| Express.js | HTTP server and routing |
| MySQL (mysql2) | Primary relational database |
| Redis | In-memory caching layer |
| dotenv | Environment variable management |

---

## 🏗️ System Architecture

```
Client Request
      ↓
  Express Server (server.js)
      ↓
  rideController.js
      ↓
  Check Redis Cache ──── Cache HIT? ──→ Return instantly ✅
      ↓ Cache MISS
  Query MySQL Database
      ↓
  Store result in Redis (TTL: 60s)
      ↓
  Return to Client
```

---

## 🗄️ Database Design

The database design is split into 3 progressive stages, each solving a real problem at scale.

### Stage 1 — Raw Data Ingestion

Data is first loaded into a single flat table `cab_rides_raw` with all columns in one place. This is the unnormalized starting point containing fields like `distance`, `cab_type`, `source`, `destination`, `price`, `surge_multiplier`, and `product_id`.

### Stage 2 — Normalization (3NF)

The raw table is broken down into 4 clean, normalized tables to eliminate redundancy and enforce data integrity:

```
cab_types    →  stores unique cab type names (Uber, Lyft etc.)
locations    →  stores unique source/destination location names
products     →  stores ride products, linked to cab types
rides        →  main fact table, references all 3 above via foreign keys
```

**Schema Overview:**
```
cab_types (cab_type_id PK, cab_type_name)
          ↑
products (product_id PK, product_name, cab_type_id FK)
          ↑
rides (ride_id PK, original_id, cab_type_id FK, product_id FK,
       source_location_id FK, destination_location_id FK,
       distance_km, price, surge_multiplier, ride_timestamp)
          ↑
locations (location_id PK, location_name)
```

**Why normalize?** Instead of storing "UberX" and "Haymarket" as raw strings in every single row, they are stored once in lookup tables and referenced by ID. This eliminates redundancy, saves storage, and keeps data consistent across the entire dataset.

### Stage 3 — Sharding (Hash Partitioning)

The `rides` table is partitioned using **HASH partitioning** across 4 partitions based on `ride_id`:

```sql
PARTITION BY HASH(ride_id)
PARTITIONS 4;
```

**Why shard?** As ride data grows to millions of rows, querying a single monolithic table becomes slow and expensive. Splitting data across 4 partitions means MySQL only scans the relevant partition for a given `ride_id` — not the entire table. This is horizontal scaling at the database layer, the same strategy used by Uber and Lyft in production.

---

## ⚡ Caching Strategy

RideScale uses a **Cache-Aside pattern** combined with **TTL-based eviction**:

1. Every incoming request checks **Redis** first
2. If the data exists in Redis (cache hit) → return it instantly
3. If not (cache miss) → query **MySQL**, store result in Redis, return to client
4. Redis entries expire automatically after **60 seconds** to prevent stale data
5. Under memory pressure, Redis uses **LRU (Least Recently Used)** eviction — keeping recently accessed rides in memory and evicting old unused ones

**Why 60 second TTL?** Ride data can change (status updates, fare adjustments), so a short TTL keeps the cache fresh while still absorbing repeated requests for the same ride within a short window — which is exactly the access pattern for a ride-hailing app.

---

## 🚀 Getting Started

### Prerequisites
- Node.js installed
- MySQL running locally
- Redis running locally

### Installation

```bash
# Clone the repository
git clone https://github.com/Sakshi02Mane/RideScale.git
cd RideScale/backend

# Install dependencies
npm install
```

### Environment Variables

Create a `.env` file inside the `backend/` folder:

```env
DB_HOST=localhost
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
DB_NAME=ridescale
```

### Database Setup

```bash
# Run the SQL files in order
mysql -u root -p < databasedesign/raw_table.sql
mysql -u root -p < databasedesign/normalized.sql
mysql -u root -p < databasedesign/sharding.sql
```

### Run the Server

```bash
node server.js
```

Server starts at `http://localhost:3000` 🚀

---

## 📡 API Endpoints

### Get Ride by ID
```
GET /ride/:id
```

**Example:**
```
GET http://localhost:3000/ride/42
```

**Response (200 OK):**
```json
{
  "id": "42",
  "cab_type": "Uber",
  "source": "Haymarket Square",
  "destination": "North End",
  "distance_km": 1.42,
  "price": 9.5,
  "surge_multiplier": 1.0
}
```

**Response (404 Not Found):**
```json
{
  "message": "Ride not found"
}
```

**Response (500 Server Error):**
```json
{
  "error": "Something went wrong"
}
```

---

## 🧠 Key Concepts Demonstrated

- **Cache-Aside Pattern** — application manages cache explicitly, not the database
- **TTL-based Expiry** — automatic cache invalidation after 60 seconds
- **LRU Eviction** — least recently used rides dropped first under memory pressure
- **Database Normalization (3NF)** — eliminated redundancy across 4 structured tables
- **Hash-based Sharding** — rides table partitioned across 4 shards for horizontal scalability
- **Foreign Key Constraints** — data integrity enforced at the database level
- **Connection Pooling** — reuses MySQL connections efficiently (limit: 10)
- **Async/Await** — fully non-blocking database and cache operations
- **Environment Variables** — sensitive credentials kept out of source code

---

## 📊 Dataset

Uses a `cab_rides_raw` dataset containing **1,000 cab ride records** (Boston area) with fields including pickup/dropoff locations, fare, distance, surge multiplier, cab type, and product ID. Used as the source for normalization, sharding, and query optimization demonstrations.

---

## 👩‍💻 Author

**Sakshi Mane** — [GitHub](https://github.com/Sakshi02Mane)
