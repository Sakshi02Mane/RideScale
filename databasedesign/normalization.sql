USE ridescale;

-- ==========================================
-- DROP SECTION (Child → Parent)
-- ==========================================

DROP TABLE IF EXISTS rides_normal;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS cab_types;


-- ==========================================
-- CREATE SECTION (Parent → Child)
-- ==========================================

-- 1️⃣ Cab Types (Parent Table)
CREATE TABLE cab_types (
    cab_type_id INT AUTO_INCREMENT PRIMARY KEY,
    cab_type_name VARCHAR(50) NOT NULL UNIQUE
);

-- 2️⃣ Locations (Parent Table)
CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL UNIQUE
);

-- 3️⃣ Products (Depends on cab_types)
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    cab_type_id INT NOT NULL,
    FOREIGN KEY (cab_type_id) REFERENCES cab_types(cab_type_id)
);

-- 4️⃣ Rides (Depends on everything)
CREATE TABLE rides_normal (
    ride_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    original_id BIGINT NOT NULL,
    cab_type_id INT NOT NULL,
    product_id VARCHAR(50) NOT NULL,

    source_location_id INT NOT NULL,
    destination_location_id INT NOT NULL,

    distance_km DECIMAL(5,2) NOT NULL,
    price DECIMAL(6,2) NOT NULL,
    surge_multiplier DECIMAL(3,2) DEFAULT 1.0,

    ride_timestamp BIGINT NOT NULL,

    FOREIGN KEY (cab_type_id) REFERENCES cab_types(cab_type_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (source_location_id) REFERENCES locations(location_id),
    FOREIGN KEY (destination_location_id) REFERENCES locations(location_id)
);
