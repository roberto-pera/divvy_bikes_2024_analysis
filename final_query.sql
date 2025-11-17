/*
  DIVVY 2024 – Data Combination & Cleaning Pipeline
  Author: Roberto Pera
  Date: 2025-09-05
  Description:
    - Combine 12 monthly DIVVY trip data CSVs (2024) into one unified table
    - Clean and standardize fields for analysis
    - Remove duplicates and invalid records
    - Add engineered features (trip duration, hour, weekday)
  Requirements:
    - SQLite (or similar SQL engine)
*/

/* ----------------------------------------------------
   STEP 1: Combine all monthly tables into one dataset
---------------------------------------------------- */
DROP TABLE IF EXISTS divvy_2024_combined;

CREATE TABLE divvy_2024_combined AS
SELECT *, 'January'   AS month_source FROM "202401-divvy-tripdata"
UNION ALL
SELECT *, 'February'  AS month_source FROM "202402-divvy-tripdata"
UNION ALL
SELECT *, 'March'     AS month_source FROM "202403-divvy-tripdata"
UNION ALL
SELECT *, 'April'     AS month_source FROM "202404-divvy-tripdata"
UNION ALL
SELECT *, 'May'       AS month_source FROM "202405-divvy-tripdata"
UNION ALL
SELECT *, 'June'      AS month_source FROM "202406-divvy-tripdata"
UNION ALL
SELECT *, 'July'      AS month_source FROM "202407-divvy-tripdata"
UNION ALL
SELECT *, 'August'    AS month_source FROM "202408-divvy-tripdata"
UNION ALL
SELECT *, 'September' AS month_source FROM "202409-divvy-tripdata"
UNION ALL
SELECT *, 'October'   AS month_source FROM "202410-divvy-tripdata"
UNION ALL
SELECT *, 'November'  AS month_source FROM "202411-divvy-tripdata"
UNION ALL
SELECT *, 'December'  AS month_source FROM "202412-divvy-tripdata";


/* ----------------------------------------------------
   STEP 2: Clean data, remove duplicates, add features
---------------------------------------------------- */
DROP TABLE IF EXISTS divvy_2024_cleaned;

CREATE TABLE divvy_2024_cleaned AS
SELECT
    -- Core identifiers
    ride_id,
    rideable_type,

    -- Standardized datetime fields
    DATETIME(started_at) AS started_at,
    DATETIME(ended_at)   AS ended_at,

    -- Station info
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,

    -- Coordinates converted to REAL
    CAST(start_lat AS REAL) AS start_lat,
    CAST(start_lng AS REAL) AS start_lng,
    CAST(end_lat   AS REAL) AS end_lat,
    CAST(end_lng   AS REAL) AS end_lng,

    -- User type
    member_casual,
    month_source,

    -- Engineered feature: trip duration in minutes
    (julianday(ended_at) - julianday(started_at)) * 24 * 60 AS trip_duration_minutes,

    -- Engineered feature: start hour (for time-of-day analysis)
    strftime('%H', started_at) AS start_hour,

    -- Engineered feature: day of week
    CASE
        WHEN CAST(strftime('%w', started_at) AS INTEGER) = 0 THEN 'Sunday'
        WHEN CAST(strftime('%w', started_at) AS INTEGER) = 1 THEN 'Monday'
        WHEN CAST(strftime('%w', started_at) AS INTEGER) = 2 THEN 'Tuesday'
        WHEN CAST(strftime('%w', started_at) AS INTEGER) = 3 THEN 'Wednesday'
        WHEN CAST(strftime('%w', started_at) AS INTEGER) = 4 THEN 'Thursday'
        WHEN CAST(strftime('%w', started_at) AS INTEGER) = 5 THEN 'Friday'
        WHEN CAST(strftime('%w', started_at) AS INTEGER) = 6 THEN 'Saturday'
    END AS day_of_week

FROM (
    -- Remove duplicates: keep one row per ride_id
    SELECT *
    FROM divvy_2024_combined
    GROUP BY ride_id
)

-- ----------------------------------------------------
-- STEP 3: Data quality filters
-- ----------------------------------------------------
WHERE
    -- Ensure timestamps are valid
    started_at IS NOT NULL AND ended_at IS NOT NULL
    AND started_at != '' AND ended_at != ''

    -- Ensure station names exist
    AND start_station_name IS NOT NULL AND end_station_name IS NOT NULL
    AND start_station_name != '' AND end_station_name != ''

    -- Ensure coordinates are valid (non-null, non-zero)
    AND start_lat IS NOT NULL AND start_lng IS NOT NULL
    AND end_lat IS NOT NULL AND end_lng IS NOT NULL
    AND start_lat != 0 AND start_lng != 0
    AND end_lat != 0 AND end_lng != 0

    -- Ensure trip duration is positive and < 24h
    AND (julianday(ended_at) - julianday(started_at)) * 24 * 60 > 0
    AND (julianday(ended_at) - julianday(started_at)) * 24 * 60 < 1440

    -- Keep only rides from 2024
    AND strftime('%Y', started_at) = '2024';