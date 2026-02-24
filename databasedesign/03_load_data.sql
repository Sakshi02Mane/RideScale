USE ridescale;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cab_rides.csv'
INTO TABLE cab_rides_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(distance, cab_type, time_stamp, destination, source, @price, @surge_multiplier, id, product_id, name)
SET
price = NULLIF(@price, ''),
surge_multiplier = NULLIF(@surge_multiplier, '');
