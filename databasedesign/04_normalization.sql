USE ridescale;

DROP TABLE IF EXISTS rides;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS cab_types;
CREATE TABLE cab_types (
    cab_type_id INT AUTO_INCREMENT PRIMARY KEY,
    cab_type_name VARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    cab_type_id INT NOT NULL,
    FOREIGN KEY (cab_type_id) REFERENCES cab_types(cab_type_id)
);
CREATE TABLE rides (
    ride_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    original_id VARCHAR(50) NOT NULL,   -- FIXED
    cab_type_id INT NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    source_location_id INT NOT NULL,
    destination_location_id INT NOT NULL,
    distance_km DECIMAL(6,2),
    price DECIMAL(6,2),
    surge_multiplier DECIMAL(3,2) DEFAULT 1.0,
    ride_timestamp BIGINT NOT NULL,
    FOREIGN KEY (cab_type_id) REFERENCES cab_types(cab_type_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (source_location_id) REFERENCES locations(location_id),
    FOREIGN KEY (destination_location_id) REFERENCES locations(location_id)
);
 
INSERT INTO cab_types (cab_type_name)
SELECT DISTINCT cab_type
FROM cab_rides_raw
WHERE cab_type IS NOT NULL;

INSERT INTO locations (location_name)
SELECT DISTINCT source
FROM cab_rides_raw
WHERE source IS NOT NULL
UNION
SELECT DISTINCT destination
FROM cab_rides_raw
WHERE destination IS NOT NULL;

INSERT INTO products (product_id, product_name, cab_type_id)
SELECT DISTINCT
    r.product_id,
    r.name,
    c.cab_type_id
FROM cab_rides_raw r
JOIN cab_types c
    ON r.cab_type = c.cab_type_name
WHERE r.product_id IS NOT NULL;
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
    s.location_id,
    d.location_id,
    r.distance,
    r.price,
    IFNULL(r.surge_multiplier, 1.0),
    r.time_stamp
FROM cab_rides_raw r
JOIN cab_types c
    ON r.cab_type = c.cab_type_name
JOIN locations s
    ON r.source = s.location_name
JOIN locations d
    ON r.destination = d.location_name;
