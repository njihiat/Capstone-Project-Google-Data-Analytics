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
MODIFY COLUMN start_station_name VARCHAR(100) ; -- Changes the lenght of start_station_name column from 50 to 100. Change the end_ column also.

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
MODIFY COLUMN end_time DATETIME ; -- Changes the end_time column to DATETIME data type. Change the Start_time also.

-- and update the data again by replacing the date with the original dates.

UPDATE aug22_tripdata
JOIN august_2022_divvy_tripdata ON august_2022_divvy_tripdata.ride_id = aug22_tripdata.ride_id
SET aug22_tripdata.end_time = august_2022_divvy_tripdata.ended_at;

-- Lets drop the original table august_2022_divvy_tripdata.
DROP TABLE august_2022_divvy_tripdata;

-- Lets add the other 11 tables up to JULY 2023
CREATE TABLE jul23_tripdata(
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
SELECT * FROM jul23_tripdata; -- Counter check the columns name to see if they are correct
-- Use INSERT IGNORE to insert only the unique records only, ignoring the duplicates record
INSERT IGNORE INTO jul23_tripdata(ride_id, ride_type, start_time, end_time, start_station_id, start_station_name, end_station_id, end_station_name, member_type)
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
	FROM july_2023_divvy_tripdata;
    
SELECT * FROM jul23_tripdata ; -- confirm that the data has been inserted correctly.
DROP TABLE july_2023_divvy_tripdata; -- Delete the source table after successful insertion.

/* Encountered a duplicate ride_id error for some _2023_divvy_tripdata tables. Lets check it out.*/
SELECT ride_id, COUNT(ride_id) AS count_id
FROM jul23_tripdata
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

-- Having loaded the 12 dataset as tables to the Case_study_one database, we need to some pre-processing to get an indepth look at the dataset.
    
-- PROCESSING PHASE--
-- For performance purposes, we are going to reduce each table to 15000 records.

DELETE FROM nov22_tripdata 
ORDER BY RAND()
LIMIT 30000 ;
-- aug22_tripdata now has 15009 records
-- sep22_tripdata now has 15800 records
-- oct22_tripdata now has 15962 records
-- nov22_tripdata now has 15974 records
-- dec22_tripdata now has 15789 records
-- jan23_tripdata now has 15679 records
-- feb23_tripdata now has 15029 records
-- mar23_tripdata now has 15209 records
-- apr23_tripdata now has 15027 records
-- may23_tripdata now has 15633 records
-- jun23_tripdata now has 15465 records
-- jul23_tripdata now has 15021 records

-- Create one combined table joining the 12 tables
CREATE TABLE cyclistic_tripdata AS
SELECT * FROM apr23_tripdata
UNION SELECT * FROM aug22_tripdata
UNION SELECT * FROM dec22_tripdata
UNION SELECT * FROM feb23_tripdata
UNION SELECT * FROM jan23_tripdata 
UNION SELECT * FROM jul23_tripdata
UNION SELECT * FROM jun23_tripdata
UNION SELECT * FROM mar23_tripdata
UNION SELECT * FROM may23_tripdata
UNION SELECT * FROM nov22_tripdata
UNION SELECT * FROM oct22_tripdata
UNION SELECT * FROM sep22_tripdata;

-- Perform the processing on the cyclistic_tripdata table which has 185260 records

-- create a column ride_length by subtracting start_time from end_time
ALTER TABLE cyclistic_tripdata
ADD COLUMN ride_length TIME;

UPDATE cyclistic_tripdata
SET ride_length = SEC_TO_TIME((TIMESTAMPDIFF(SECOND, start_time, end_time)));

/* 
- While creating the ride_length column, I realized there are 5641 records where the start_time is later than the end_time. This is an
abnormality. I deleted the rows 
- Another abnormality is when the ride_length exceeded one day, There are 6118 rows 
*/
DELETE FROM cyclistic_tripdata
WHERE ride_length < 0 AND ride_length > 86400;

-- Create a column start_day_of_week for the name of the day the ride started
ALTER TABLE cyclistic_tripdata
ADD COLUMN start_day_of_week VARCHAR(30);

UPDATE cyclistic_tripdata
SET start_day_of_week = DAYNAME(start_time);

-- DESCRIPTIVE ANALYSIS --
-- Mean of ride_lenght

SELECT AVG(ride_length) AS Mean_ride_length
FROM cyclistic_tripdata;  --  The mean ride_length is 1666.0460 seconds OR 27.77 minutes

-- Mode start_day of the week
SELECT start_day_of_week, COUNT(*) AS Frequency
FROM cyclistic_tripdata
GROUP BY start_day_of_week
ORDER BY Frequency DESC
LIMIT 1;
		/* Results:
			Thursday	27383
            */

-- Maximum ride length
SELECT MAX(ride_length) AS Highest_ride_length
FROM cyclistic_tripdata; -- The highest ride_length is 23:43:47

-- mean ride_length for members and casual riders.
SELECT member_type, AVG(ride_length) AS Mean_ride_length
FROM cyclistic_tripdata
GROUP BY member_type; 
			/* 	casual	2315.1882 seconds OR 38.58 minutes 
				member	1313.5088 seconds OR 21.88 minutes
			*/

-- Average ride length per day of the week
SELECT start_day_of_week, AVG(ride_length) AS Mean_ride_length
FROM cyclistic_tripdata
GROUP BY start_day_of_week
ORDER BY Mean_ride_length DESC;
		/* 	Saturday	2076.1928
			Sunday		2073.3629
			Friday		1618.1863
			Thursday	1538.9061
			Monday		1518.0737
			Tuesday		1469.8323
			Wednesday	1435.8562
		*/
        
-- No of rides by day of the week
SELECT start_day_of_week, COUNT(*) AS Number_of_rides
FROM cyclistic_tripdata
GROUP BY start_day_of_week
ORDER BY Number_of_rides DESC;
		/* Results
			Thursday	27383
			Friday		26034
			Wednesday	25924
			Saturday	25893
			Tuesday		25201
			Monday		22550
			Sunday		20516
		*/



			
    

    
 