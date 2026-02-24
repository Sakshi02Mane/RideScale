USE ridescale;

DROP TABLE IF EXISTS cab_rides_raw;

CREATE TABLE cab_rides_raw (
    distance DECIMAL(6,2) NULL,
    cab_type VARCHAR(50),
    time_stamp BIGINT,
    destination VARCHAR(100),
    source VARCHAR(100),
    price DECIMAL(6,2) NULL,
    surge_multiplier DECIMAL(3,2) NULL,
    id VARCHAR(50),
    product_id VARCHAR(50),
    name VARCHAR(100)
);
