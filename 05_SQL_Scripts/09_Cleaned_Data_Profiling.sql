USE NYC_Service_Request_Database;

-- Dataset Overview
-- 1. Total Columns
SELECT COUNT(*) AS total_columns
FROM sys.columns
WHERE object_id = OBJECT_ID('gold.NYC_Service_Requests');

-- 2. Total Rows
SELECT COUNT(*) AS total_rows
FROM gold.NYC_Service_Requests;

-- 3. File Size
EXEC sp_spaceused 'gold.NYC_Service_Requests';

-- 4. Data Recency 
SELECT
	MIN(CAST(created_date AS DATE)) AS min_date,
	MAX(CAST(created_date AS DATE)) AS max_date
FROM gold.NYC_Service_Requests;

-- Data Dictionary
EXEC sp_help 'gold.NYC_Service_Requests';

-- NULL Analysis
SELECT
	'Yes' AS is_null,
	SUM(CASE WHEN unique_key IS NULL THEN 1 END) AS unique_key,
	SUM(CASE WHEN created_date IS NULL THEN 1 END) AS created_date,
	SUM(CASE WHEN closed_date IS NULL THEN 1 END) AS closed_date,
	SUM(CASE WHEN agency IS NULL THEN 1 END) AS agency,
	SUM(CASE WHEN complaint_type IS NULL THEN 1 END) AS complaint_type,
	SUM(CASE WHEN incident_zip IS NULL THEN 1 END) AS incident_zip,
	SUM(CASE WHEN city IS NULL THEN 1 END) AS city,
	SUM(CASE WHEN status IS NULL THEN 1 END) AS status,
	SUM(CASE WHEN borough IS NULL THEN 1 END) AS borough,
	SUM(CASE WHEN latitude IS NULL THEN 1 END) AS latitude,
	SUM(CASE WHEN longitude IS NULL THEN 1 END) AS longitude
FROM gold.NYC_Service_Requests
UNION ALL
SELECT
	'No' AS is_null,
	SUM(CASE WHEN unique_key IS NOT NULL THEN 1 END) AS unique_key,
	SUM(CASE WHEN created_date IS NOT NULL THEN 1 END) AS created_date,
	SUM(CASE WHEN closed_date IS NOT NULL THEN 1 END) AS closed_date,
	SUM(CASE WHEN agency IS NOT NULL THEN 1 END) AS agency,
	SUM(CASE WHEN complaint_type IS NOT NULL THEN 1 END) AS complaint_type,
	SUM(CASE WHEN incident_zip IS NOT NULL THEN 1 END) AS incident_zip,
	SUM(CASE WHEN city IS NOT NULL THEN 1 END) AS city,
	SUM(CASE WHEN status IS NOT NULL THEN 1 END) AS status,
	SUM(CASE WHEN borough IS NOT NULL THEN 1 END) AS borough,
	SUM(CASE WHEN latitude IS NOT NULL THEN 1 END) AS latitude,
	SUM(CASE WHEN longitude IS NOT NULL THEN 1 END) AS longitude
FROM gold.NYC_Service_Requests;

-- Duplicate Row Analysis
-- 1. With unique_key column
WITH duplicates AS (
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY
								unique_key,
								created_date,
								closed_date,
								agency,
								complaint_type,
								incident_zip,
								city,
								status,
								borough,
								latitude,
								longitude
						  ORDER BY (SELECT NULL)
		) AS rn
	FROM gold.NYC_Service_Requests
)
SELECT
	COUNT(rn) AS total_duplicates
FROM duplicates
WHERE rn > 1;

-- 2. Without unique_key column
WITH duplicates AS (
	SELECT
		created_date,
		closed_date,
		agency,
		complaint_type,
		incident_zip,
		city,
		status,
		borough,
		latitude,
		longitude,
		ROW_NUMBER() OVER(PARTITION BY
								created_date,
								closed_date,
								agency,
								complaint_type,
								incident_zip,
								city,
								status,
								borough,
								latitude,
								longitude
						  ORDER BY (SELECT NULL)
		) AS rn
	FROM gold.NYC_Service_Requests
)
SELECT
	COUNT(rn) AS total_duplicates
FROM duplicates
WHERE rn > 1;

-- Cardinality Analysis
SELECT
    COUNT(DISTINCT CAST(unique_key AS VARCHAR(10)) COLLATE Latin1_General_CS_AS) AS unique_key_count,
    COUNT(DISTINCT CAST(created_date AS VARCHAR(30)) COLLATE Latin1_General_CS_AS) AS created_date_count,
    COUNT(DISTINCT CAST(closed_date AS VARCHAR(30)) COLLATE Latin1_General_CS_AS) AS closed_date_count,
    COUNT(DISTINCT agency COLLATE Latin1_General_CS_AS) AS agency_count,
    COUNT(DISTINCT complaint_type COLLATE Latin1_General_CS_AS) AS complaint_type_count,
    COUNT(DISTINCT CAST(incident_zip AS VARCHAR(10)) COLLATE Latin1_General_CS_AS) AS incident_zip_count,
    COUNT(DISTINCT city COLLATE Latin1_General_CS_AS) AS city_count,
    COUNT(DISTINCT status COLLATE Latin1_General_CS_AS) AS status_count,
    COUNT(DISTINCT borough COLLATE Latin1_General_CS_AS) AS borough_count,
    COUNT(DISTINCT CAST(latitude AS VARCHAR(20)) COLLATE Latin1_General_CS_AS) AS latitude_count,
    COUNT(DISTINCT CAST(longitude AS VARCHAR(20)) COLLATE Latin1_General_CS_AS) AS longitude_count
FROM gold.NYC_Service_Requests;

-- Consistency Analysis
SELECT
	COUNT(DISTINCT city) AS count_city,
	COUNT(DISTINCT TRIM(city)) AS count_city_trim,
	COUNT(DISTINCT city COLLATE Latin1_General_CS_AS) AS city_count
FROM gold.NYC_Service_Requests;

SELECT
	COUNT(DISTINCT complaint_type) AS count_complaint_type,
	COUNT(DISTINCT TRIM(complaint_type)) AS count_complaint_type_trim,
	COUNT(DISTINCT complaint_type COLLATE Latin1_General_CS_AS) AS complaint_type_count
FROM gold.NYC_Service_Requests;

SELECT
	COUNT(DISTINCT agency) AS count_agency,
	COUNT(DISTINCT TRIM(agency)) AS count_agency_trim,
	COUNT(DISTINCT agency COLLATE Latin1_General_CS_AS) AS agency_count
FROM gold.NYC_Service_Requests;

SELECT
	COUNT(DISTINCT status) AS count_status,
	COUNT(DISTINCT TRIM(status)) AS count_status_trim,
	COUNT(DISTINCT status COLLATE Latin1_General_CS_AS) AS status_count
FROM gold.NYC_Service_Requests;

SELECT
	COUNT(DISTINCT borough) AS count_borough,
	COUNT(DISTINCT TRIM(borough)) AS count_borough_trim,
	COUNT(DISTINCT borough COLLATE Latin1_General_CS_AS) AS borough_count
FROM gold.NYC_Service_Requests;

SELECT DISTINCT city COLLATE Latin1_General_CS_AS AS city FROM gold.NYC_Service_Requests;
SELECT DISTINCT borough COLLATE Latin1_General_CS_AS AS borough FROM gold.NYC_Service_Requests;
SELECT DISTINCT complaint_type COLLATE Latin1_General_CS_AS AS complaint_type FROM gold.NYC_Service_Requests;
SELECT DISTINCT status COLLATE Latin1_General_CS_AS AS status FROM gold.NYC_Service_Requests;
SELECT DISTINCT agency COLLATE Latin1_General_CS_AS AS agency FROM gold.NYC_Service_Requests;

-- Check Date Consistency
-- 1. Check if any non date format exists
SELECT
	created_date,
	closed_date
FROM gold.NYC_Service_Requests;

-- 2. Check if discrepancies in creation and closing dates exist
SELECT
	created_date,
	closed_date
FROM gold.NYC_Service_Requests
WHERE
	created_date > closed_date;

-- 3. Check for creation date greater than closing date
SELECT COUNT(*)
FROM(
	SELECT
		created_date AS create_date,
		closed_date AS close_date
	FROM gold.NYC_Service_Requests
	WHERE created_date > closed_date
) AS t;

-- 4. Check if creation date greater than today's date (2026-06-03)
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE created_date > CAST('2026-06-03' AS DATETIME);

-- 5. Check if Closing date greater than today's date (2026-06-03)
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE closed_date > CAST('2026-06-03' AS DATETIME);

-- 6. Check for count of closing date greater then creation date
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE created_date <= closed_date;

-- Geographic Validation
-- 1. Check min and max latitude and longitude
SELECT
	MIN(CAST(latitude AS DECIMAL(15, 11))) AS min_lat,
	MAX(CAST(latitude AS DECIMAL(15, 11))) AS max_lat,
	MIN(CAST(longitude AS DECIMAL(15, 11))) AS min_lon,
	MAX(CAST(longitude AS DECIMAL(15, 11))) AS max_lon
FROM gold.NYC_Service_Requests;

SELECT TOP 5 latitude FROM gold.NYC_Service_Requests WHERE latitude IS NOT NULL ORDER BY 1;
SELECT TOP 5 latitude FROM gold.NYC_Service_Requests ORDER BY 1 DESC;
SELECT TOP 5 longitude FROM gold.NYC_Service_Requests WHERE longitude IS NOT NULL ORDER BY 1;
SELECT TOP 5 longitude FROM gold.NYC_Service_Requests ORDER BY 1 DESC;

-- 2. Check for distinct combos
SELECT COUNT(*)
FROM (
	SELECT DISTINCT
		city,
		borough,
		incident_zip,
		latitude,
		longitude
	FROM gold.NYC_Service_Requests
) AS t;

SELECT COUNT(*)
FROM (
	SELECT
		city,
		borough,
		incident_zip,
		COUNT(*) AS count_all
	FROM gold.NYC_Service_Requests
	GROUP BY
		city,
		borough,
		incident_zip
) AS t;

SELECT COUNT(*)
FROM (
	SELECT
		city,
		borough,
		COUNT(*) AS count_all
	FROM gold.NYC_Service_Requests
	GROUP BY
		city,
		borough
) AS t;
	
-- 3. Check for missing lat and lon
SELECT
	SUM(CASE WHEN latitude IS NULL THEN 1 END) AS lat_count,
	SUM(CASE WHEN longitude IS NULL THEN 1 END) AS lon_count
FROM gold.NYC_Service_Requests;

-- 4. Check for lat without lon
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE latitude IS NOT NULL AND longitude IS NULL;

-- 5. Check for lon without lat
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE longitude IS NOT NULL AND latitude IS NULL;

-- 6. Check for city and borough validity
SELECT
	city,
	borough
FROM gold.NYC_Service_Requests
GROUP BY
	city,
	borough
ORDER BY borough, city

-- Status Validation
-- 1. Check if closed date present and status is closed
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE closed_date IS NOT NULL AND status = 'Closed';

-- 2. Check if closed date is null but status is closed
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE closed_date IS NULL AND status = 'Closed';

-- 3. Check if closed date present but status is not closed
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE closed_date IS NOT NULL AND status != 'Closed';

-- 4. Check if closed date present but status is null
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE closed_date IS NOT NULL AND status IS NULL;

-- 5. Check if closed date is null and status is null
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE closed_date IS NULL AND status IS NULL;

-- Text Validation
-- 1. Check for blank strings
SELECT
	agency
FROM gold.NYC_Service_Requests
WHERE agency = '' OR agency != TRIM(agency);

SELECT
	status
FROM gold.NYC_Service_Requests
WHERE status = '' OR status != TRIM(status);

SELECT
	borough
FROM gold.NYC_Service_Requests
WHERE borough = '' OR borough != TRIM(borough);

SELECT
	complaint_type
FROM gold.NYC_Service_Requests
WHERE complaint_type = '' OR complaint_type != TRIM(complaint_type);

SELECT
	city
FROM gold.NYC_Service_Requests
WHERE city = '' OR city != TRIM(city);

-- 2. Check for outlier lengths
SELECT DISTINCT
	agency,
	LEN(agency)
FROM gold.NYC_Service_Requests
ORDER BY LEN(agency);

SELECT DISTINCT
	city,
	LEN(city)
FROM gold.NYC_Service_Requests
ORDER BY LEN(city);

SELECT DISTINCT
	borough,
	LEN(borough)
FROM gold.NYC_Service_Requests
ORDER BY LEN(borough);

SELECT DISTINCT
	complaint_type,
	LEN(complaint_type)
FROM gold.NYC_Service_Requests
ORDER BY LEN(complaint_type);

SELECT DISTINCT
	status,
	LEN(status)
FROM gold.NYC_Service_Requests
ORDER BY LEN(status);

-- Zip Code Validation
-- 1. Check for valid zip codes
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE LEN(incident_zip) = 5;

-- 2. Check for invalid zip codes - NULLs
SELECT COUNT(*)
FROM gold.NYC_Service_Requests
WHERE incident_zip IS NULL;

-- 3. Check for invalid zip codes including NULLs
SELECT *
FROM gold.NYC_Service_Requests
WHERE LEN(incident_zip) != 5 AND incident_zip IS NOT NULL;