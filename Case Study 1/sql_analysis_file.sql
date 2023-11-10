CREATE database case_study_one;
USE case_study_one;

SELECT * FROM august_2022_divvy_tripdata LIMIT 10000000;
-- The table contains 106923 records

-- There are some column we are not going to use in our analysis
CREATE TABLE Aug22_tripdata (
	ride_id VARCHAR(50) PRIMARY KEY, 
    ride_type VARCHAR (50),
    start_time DATE, 
    end_time DATE, 
    start_station_id VARCHAR(50), 
    start_station_name VARCHAR(50), 
    end_station_id VARCHAR (50),
    end_station_name VARCHAR(50), 
    member_type VARCHAR(50)
    );
INSERT INTO aug22_tripdata (ride_id, ride_type, start_time, end_time, start_station_id, start_station_name, end_station_id, end_station_name, member_type)
SELECT
	ride_id,
    rideable_type,
    started_at, 
	ended_at, 
	start_station_id,
    start_station_name,
	end_station_id,
    end_station_name,
	member_casual
FROM august_2022_divvy_tripdata;
	
-- Some station names were too long for the 50 characters set. Adjust the length to 100
ALTER TABLE aug22_tripdata
MODIFY COLUMN end_station_name VARCHAR (100);

-- Lets first check how many records have an empty column in any of the column
SELECT	*
FROM aug22_tripdata
WHERE start_station_id = ''
    OR start_station_name = ''
    OR end_station_id = ''
	OR end_station_name = '';

-- There are empty values and lets replace them with NULL values
UPDATE aug22_tripdata
SET start_station_id = IF('', NULL, start_station_id),
	start_station_name = IF('', NULL, start_station_name),
    end_station_id = IF('', NULL, end_station_id),
    end_station_name = IF('', NULL, end_station_name)
WHERE
	start_station_id = ''
    OR start_station_name = ''
    OR end_station_id = ''
	OR end_station_name = ''
 