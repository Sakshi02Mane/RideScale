--splitting large dataset into smaller pieces across multiple servers
-- Drop only rides table (keep dimension tables)
DROP TABLE IF EXISTS rides;

CREATE TABLE rides (
    ride_id BIGINT AUTO_INCREMENT,
    original_id VARCHAR(50) NOT NULL,   -- FIXED
    cab_type_id INT NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    source_location_id INT NOT NULL,
    destination_location_id INT NOT NULL,
    distance_km DECIMAL(6,2),
    price DECIMAL(6,2),
    surge_multiplier DECIMAL(3,2) DEFAULT 1.0,
    ride_timestamp BIGINT NOT NULL,

    PRIMARY KEY (ride_id),

    FOREIGN KEY (cab_type_id) REFERENCES cab_types(cab_type_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (source_location_id) REFERENCES locations(location_id),
    FOREIGN KEY (destination_location_id) REFERENCES locations(location_id)

)
PARTITION BY HASH(ride_id)
PARTITIONS 4;
SHOW CREATE TABLE rides;
