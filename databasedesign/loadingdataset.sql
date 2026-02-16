-- ================================
-- LOAD DATA INTO EXISTING SCHEMA
-- ================================

-- 1️⃣ Create Raw Staging Table (if not already created)
USE ridescale;
DROP TABLE IF EXISTS cab_rides_raw;

CREATE TABLE cab_rides_raw (
    distance DECIMAL(6,2),
    cab_type VARCHAR(50),
    time_stamp BIGINT,
    destination VARCHAR(100),
    source VARCHAR(100),
    price DECIMAL(6,2),
    surge_multiplier DECIMAL(3,2),
    id VARCHAR(50),
    product_id VARCHAR(50),
    name VARCHAR(100)
);


-- 2️⃣ Load CSV into Raw Table

LOAD DATA LOCAL INFILE 'E:/Projects/RideScale/cab_rides.csv'
INTO TABLE cab_rides_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- 3️⃣ Insert Unique Locations

INSERT IGNORE INTO locations (location_name)
SELECT DISTINCT source FROM cab_rides_raw;

INSERT IGNORE INTO locations (location_name)
SELECT DISTINCT destination FROM cab_rides_raw;


-- 4️⃣ Insert Cab Types

INSERT IGNORE INTO cab_types (cab_type_name)
SELECT DISTINCT cab_type FROM cab_rides_raw;


-- 5️⃣ Insert Products

INSERT IGNORE INTO products (product_id, product_name, cab_type_id)
SELECT DISTINCT
    r.product_id,
    r.name,
    c.cab_type_id
FROM cab_rides_raw r
JOIN cab_types c
ON r.cab_type = c.cab_type_name;


-- 6️⃣ Insert Into Sharded rides Table

INSERT INTO rides (
    original_id,
    cab_type_id,
    product_id,
    source_location_id,
    destination_location_id,
    distance_km,
    price,
    surge_multiplier,
    ride_timestamp
)
SELECT
    r.id,
    c.cab_type_id,
    r.product_id,
    ls.location_id,
    ld.location_id,
    r.distance,
    r.price,
    r.surge_multiplier,
    r.time_stamp
FROM cab_rides_raw r
JOIN cab_types c
    ON r.cab_type = c.cab_type_name
JOIN locations ls
    ON r.source = ls.location_name
JOIN locations ld
    ON r.destination = ld.location_name;


-- 7️⃣ Check Final Result

SELECT COUNT(*) AS total_rides FROM rides;

SELECT 
    PARTITION_NAME,
    TABLE_ROWS
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'rides'
AND TABLE_SCHEMA = DATABASE();

SELECT COUNT(*) FROM cab_rides_raw;
