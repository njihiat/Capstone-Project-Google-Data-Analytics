CREATE database case_study_one;
USE case_study_one;

SELECT * FROM august_2022_divvy_tripdata LIMIT 10000000;
-- The table contains 106923 records.

-- There are longitudes and latitudes column that we are not going to use in our analysis.

-- Lets create a new table with only the fields we are going to use, Set the primary key and change the Data types.
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

-- Lets insert data into the created table from the august_2022_divvy_tripdata table.

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
MODIFY COLUMN start_station_name VARCHAR(50) ;

-- Lets first check how many records have an empty column in any of the column
SELECT	*
FROM aug22_tripdata
WHERE start_station_id = '' -- 28384 empty values 
    OR start_station_name = '' -- 28384 empty values
	OR end_station_id = ''		-- 40634 empty values
	OR end_station_name = ''	-- 40634 empty values
    ;
-- There are 47348 records with empty values in the four fields.

-- There are empty values and lets replace them with NULL values 
SET SQL_SAFE_UPDATES = 0;
UPDATE aug22_tripdata
SET start_station_id = IF(start_station_id = '', NULL, start_station_id),
    start_station_name = IF(start_station_name = '', NULL, start_station_name),
    end_station_id = IF(end_station_id = '', NULL, end_station_id),
    end_station_name = IF(end_station_name = '', NULL, end_station_name)
WHERE
	start_station_id = ' '
    OR start_station_name = ''
    OR end_station_id = ''
	OR end_station_name = '';
    
SELECT * FROM aug22_tripdata  LIMIT 10000000 ;

-- When creating the table, I set the start_time and end_time to date data type rather than the datetime data type.
-- modify the columns first  
ALTER TABLE aug22_tripdata
MODIFY COLUMN end_time DATETIME ;

-- and update the data again by replacing the date with the original dates.

UPDATE aug22_tripdata
JOIN august_2022_divvy_tripdata ON august_2022_divvy_tripdata.ride_id = aug22_tripdata.ride_id
SET aug22_tripdata.end_time = august_2022_divvy_tripdata.ended_at;

-- Lets drop the original table august_2022_divvy_tripdata.
DROP TABLE august_2022_divvy_tripdata;

-- Lets add the other 11 tables up to JULY 2023
CREATE TABLE jun23_tripdata(
	ride_id VARCHAR (50) PRIMARY KEY,
    ride_type VARCHAR (50),
    start_time DATETIME,
    end_time DATETIME,
    start_station_id VARCHAR (50),
    start_station_name VARCHAR (100),
    end_station_id VARCHAR (50),
    end_station_name VARCHAR (100),
    member_type VARCHAR (50)
    );
-- lets insert data into this table. First we import the CSV and extract the fields that we need.
SELECT * FROM jun23_tripdata; -- Counter check the columns name to see if they are correct
-- Use INSERT IGNORE to insert only the unique records only ignoring the duplicates record
INSERT IGNORE INTO jun23_tripdata(ride_id, ride_type, start_time, end_time, start_station_id, start_station_name, end_station_id, end_station_name, member_type)
	SELECT
		ride_id,
		rideable_type, 
		started_at,
		ended_at,
		IF(start_station_id = '', NULL, start_station_id), -- some station were not recorded, so we insert null incase of empty values.
		IF(start_station_name = '', NULL, start_station_name) ,
		IF(end_station_id = '', NULL, end_station_id),
		IF(end_station_name = '', NULL, end_station_name), 
		member_casual
	FROM june_2023_divvy_tripdata;
    
SELECT * FROM jun23_tripdata ; -- confirm that the data has been inserted correctly.
DROP TABLE june_2023_divvy_tripdata; -- Delete the source table after successful insertion.

/* Encountered a duplicate ride_id error for some _2023_divvy_tripdata tables. Lets check it out.*/
SELECT ride_id, COUNT(ride_id) AS count_id
FROM february_2023_divvy_tripdata
GROUP BY ride_id
HAVING count_id > 2;
/*There are some duplicates ride_id. Each ride should be unique. It should have a specific start and end time.
Lets remove the duplicates*/
SET SQL_SAFE_UPDATES = 0; -- First, turn off the safe SQL updates.

-- This query is an alternative of the INSERT IGNORE.
/* In this query*, join two tables. The inner query returns a table of ride_id which are duplicates ie having
count > 1. The other table is the table we want to delete the duplicates from. By joining the two tables,
we return rows which are common in both tables which are the duplicates.*/
DELETE feb23_divvy_tripdata
FROM february_2023_divvy_tripdata AS feb23_divvy_tripdata 
JOIN
	(SELECT ride_id
	FROM february_2023_divvy_tripdata
    GROUP BY ride_id
    HAVING COUNT(ride_id) > 1) AS ride_id_table
ON ride_id_table.ride_id = feb23_divvy_tripdata.ride_id;

-- the table contains unique records.

-- DESCRIPTIVE STATISTICS--

			
    

    
 