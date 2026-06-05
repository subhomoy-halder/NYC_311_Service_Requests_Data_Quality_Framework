USE NYC_Service_Request_Database;

-- Dataset Overview
-- 1. Total Columns
SELECT COUNT(*) AS total_columns
FROM sys.columns
WHERE object_id = OBJECT_ID('bronze.NYC_Service_Requests_raw');

-- 2. Total Rows
SELECT COUNT(*) AS total_rows
FROM bronze.NYC_Service_Requests_raw;

-- 3. File Size
EXEC sp_spaceused 'bronze.NYC_Service_Requests_raw';

-- 4. Data Recency 
SELECT
	MIN(CAST(created_date AS DATE)) AS min_date,
	MAX(CAST(created_date AS DATE)) AS max_date
FROM bronze.NYC_Service_Requests_raw;

-- Data Dictionary
EXEC sp_help 'bronze.NYC_Service_Requests_raw';

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
	SUM(CASE WHEN due_date IS NULL THEN 1 END) AS due_date,
	SUM(CASE WHEN borough IS NULL THEN 1 END) AS borough,
	SUM(CASE WHEN latitude IS NULL THEN 1 END) AS latitude,
	SUM(CASE WHEN longitude IS NULL THEN 1 END) AS longitude
FROM bronze.NYC_Service_Requests_raw
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
	SUM(CASE WHEN due_date IS NOT NULL THEN 1 END) AS due_date,
	SUM(CASE WHEN borough IS NOT NULL THEN 1 END) AS borough,
	SUM(CASE WHEN latitude IS NOT NULL THEN 1 END) AS latitude,
	SUM(CASE WHEN longitude IS NOT NULL THEN 1 END) AS longitude
FROM bronze.NYC_Service_Requests_raw;

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
								due_date,
								borough,
								latitude,
								longitude
						  ORDER BY (SELECT NULL)
		) AS rn
	FROM bronze.NYC_Service_Requests_raw
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
		due_date,
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
								due_date,
								borough,
								latitude,
								longitude
						  ORDER BY (SELECT NULL)
		) AS rn
	FROM bronze.NYC_Service_Requests_raw
)
SELECT
	COUNT(rn) AS total_duplicates
FROM duplicates
WHERE rn > 1;

-- Cardinality Analysis
SELECT
    COUNT(DISTINCT unique_key COLLATE Latin1_General_CS_AS) AS unique_key_count,
    COUNT(DISTINCT created_date COLLATE Latin1_General_CS_AS) AS created_date_count,
    COUNT(DISTINCT closed_date COLLATE Latin1_General_CS_AS) AS closed_date_count,
    COUNT(DISTINCT agency COLLATE Latin1_General_CS_AS) AS agency_count,
    COUNT(DISTINCT complaint_type COLLATE Latin1_General_CS_AS) AS complaint_type_count,
    COUNT(DISTINCT incident_zip COLLATE Latin1_General_CS_AS) AS incident_zip_count,
    COUNT(DISTINCT city COLLATE Latin1_General_CS_AS) AS city_count,
    COUNT(DISTINCT status COLLATE Latin1_General_CS_AS) AS status_count,
    COUNT(DISTINCT due_date COLLATE Latin1_General_CS_AS) AS due_date_count,
    COUNT(DISTINCT borough COLLATE Latin1_General_CS_AS) AS borough_count,
    COUNT(DISTINCT latitude COLLATE Latin1_General_CS_AS) AS latitude_count,
    COUNT(DISTINCT longitude COLLATE Latin1_General_CS_AS) AS longitude_count
FROM bronze.NYC_Service_Requests_raw;

-- Consistency Analysis
SELECT
	COUNT(DISTINCT city) AS count_city,
	COUNT(DISTINCT TRIM(city)) AS count_city_trim,
	COUNT(DISTINCT city COLLATE Latin1_General_CS_AS) AS city_count
FROM bronze.NYC_Service_Requests_raw;

SELECT
	COUNT(DISTINCT complaint_type) AS count_complaint_type,
	COUNT(DISTINCT TRIM(complaint_type)) AS count_complaint_type_trim,
	COUNT(DISTINCT complaint_type COLLATE Latin1_General_CS_AS) AS complaint_type_count
FROM bronze.NYC_Service_Requests_raw;

SELECT
	COUNT(DISTINCT agency) AS count_agency,
	COUNT(DISTINCT TRIM(agency)) AS count_agency_trim,
	COUNT(DISTINCT agency COLLATE Latin1_General_CS_AS) AS agency_count
FROM bronze.NYC_Service_Requests_raw;

SELECT
	COUNT(DISTINCT status) AS count_status,
	COUNT(DISTINCT TRIM(status)) AS count_status_trim,
	COUNT(DISTINCT status COLLATE Latin1_General_CS_AS) AS status_count
FROM bronze.NYC_Service_Requests_raw;

SELECT
	COUNT(DISTINCT borough) AS count_borough,
	COUNT(DISTINCT TRIM(borough)) AS count_borough_trim,
	COUNT(DISTINCT borough COLLATE Latin1_General_CS_AS) AS borough_count
FROM bronze.NYC_Service_Requests_raw;

SELECT DISTINCT city COLLATE Latin1_General_CS_AS AS city FROM bronze.NYC_Service_Requests_raw;
SELECT DISTINCT borough COLLATE Latin1_General_CS_AS AS borough FROM bronze.NYC_Service_Requests_raw;
SELECT DISTINCT complaint_type COLLATE Latin1_General_CS_AS AS complaint_type FROM bronze.NYC_Service_Requests_raw;
SELECT DISTINCT status COLLATE Latin1_General_CS_AS AS status FROM bronze.NYC_Service_Requests_raw;
SELECT DISTINCT agency COLLATE Latin1_General_CS_AS AS agency FROM bronze.NYC_Service_Requests_raw;

-- Check Date Consistency
-- 1. Check if any non date format exists
SELECT
	CAST(created_date AS DATETIME) AS created_date,
	CAST(closed_date AS DATETIME) AS closed_date,
	CAST(due_date AS DATETIME) AS due_date
FROM bronze.NYC_Service_Requests_raw;

-- 2. Check if discrepancies in creation and closing dates exist
SELECT
	created_date,
	closed_date,
	due_date
FROM bronze.NYC_Service_Requests_raw
WHERE
	CAST(created_date AS DATETIME) > CAST(closed_date AS DATETIME)
	OR CAST(created_date AS DATETIME) > CAST(due_date AS DATETIME)
	OR CAST(closed_date AS DATETIME) > CAST(due_date AS DATETIME);

-- 3. Check for creation date greater than closing date
SELECT COUNT(*)
FROM(
	SELECT
		CAST(created_date AS DATETIME) AS create_date,
		CAST(closed_date AS DATETIME) AS close_date
	FROM bronze.NYC_Service_Requests_raw
	WHERE CAST(created_date AS DATETIME) > CAST(closed_date AS DATETIME)
) AS t;

-- 4. Check for close date greater than due date
SELECT COUNT(*)
FROM(
	SELECT
		CAST(closed_date AS DATETIME) AS close_date,
		CAST(due_date AS DATETIME) AS due_date
	FROM bronze.NYC_Service_Requests_raw
	WHERE CAST(closed_date AS DATETIME) > CAST(due_date AS DATETIME)
) AS t;

-- 5. Check for creation date greater than due date
SELECT COUNT(*)
FROM(
	SELECT
		CAST(created_date AS DATETIME) AS create_date,
		CAST(due_date AS DATETIME) AS due_date
	FROM bronze.NYC_Service_Requests_raw
	WHERE CAST(created_date AS DATETIME) > CAST(due_date AS DATETIME)
) AS t;

-- 6. Check if creation date greater than today's date (2026-06-03)
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE CAST(created_date AS DATETIME) > GETDATE();

-- 7. Check if Closing date greater than today's date (2026-06-03)
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE CAST(closed_date AS DATETIME) > GETDATE();

-- 8. Check if Due date greater than today's date (2026-06-03)
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE CAST(due_date AS DATETIME) > GETDATE();

-- 9. Check for count of closing date greater then creation date
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE CAST(created_date AS DATETIME) <= CAST(closed_date AS DATETIME);

-- Geographic Validation
-- 1. Check min and max latitude and longitude
SELECT
	MIN(CAST(latitude AS DECIMAL(15, 11))) AS min_lat,
	MAX(CAST(latitude AS DECIMAL(15, 11))) AS max_lat,
	MIN(CAST(longitude AS DECIMAL(15, 11))) AS min_lon,
	MAX(CAST(longitude AS DECIMAL(15, 11))) AS max_lon
FROM bronze.NYC_Service_Requests_raw;

SELECT TOP 5 latitude FROM bronze.NYC_Service_Requests_raw WHERE latitude IS NOT NULL ORDER BY 1;
SELECT TOP 5 latitude FROM bronze.NYC_Service_Requests_raw ORDER BY 1 DESC;
SELECT TOP 5 longitude FROM bronze.NYC_Service_Requests_raw WHERE longitude IS NOT NULL ORDER BY 1;
SELECT TOP 5 longitude FROM bronze.NYC_Service_Requests_raw ORDER BY 1 DESC;

-- 2. Check for distinct combos
SELECT COUNT(*)
FROM (
	SELECT DISTINCT
		city,
		borough,
		incident_zip,
		latitude,
		longitude
	FROM bronze.NYC_Service_Requests_raw
) AS t;

SELECT COUNT(*)
FROM (
	SELECT
		city,
		borough,
		incident_zip,
		COUNT(*) AS count_all
	FROM bronze.NYC_Service_Requests_raw
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
	FROM bronze.NYC_Service_Requests_raw
	GROUP BY
		city,
		borough
) AS t;
	
-- 3. Check for missing lat and lon
SELECT
	SUM(CASE WHEN latitude IS NULL THEN 1 END) AS lat_count,
	SUM(CASE WHEN longitude IS NULL THEN 1 END) AS lon_count
FROM bronze.NYC_Service_Requests_raw;

-- 4. Check for lat without lon
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE latitude IS NOT NULL AND longitude IS NULL;

-- 5. Check for lon without lat
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE longitude IS NOT NULL AND latitude IS NULL;

-- 6. Check for city and borough validity
SELECT
	city,
	borough
FROM bronze.NYC_Service_Requests_raw
GROUP BY
	city,
	borough
ORDER BY borough, city

-- Status Validation
-- 1. Check if closed date present and status is closed
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE closed_date IS NOT NULL AND status = 'Closed';

-- 2. Check if closed date is null but status is closed
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE closed_date IS NULL AND status = 'Closed';

-- 3. Check if closed date present but status is not closed
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE closed_date IS NOT NULL AND status != 'Closed';

-- 4. Check if closed date present but status is null
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE closed_date IS NOT NULL AND status IS NULL;

-- 5. Check if closed date is null and status is null
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE closed_date IS NULL AND status IS NULL;

-- Text Validation
-- 1. Check for blank strings
SELECT
	agency
FROM bronze.NYC_Service_Requests_raw
WHERE agency = '' OR agency != TRIM(agency);

SELECT
	status
FROM bronze.NYC_Service_Requests_raw
WHERE status = '' OR status != TRIM(status);

SELECT
	borough
FROM bronze.NYC_Service_Requests_raw
WHERE borough = '' OR borough != TRIM(borough);

SELECT
	complaint_type
FROM bronze.NYC_Service_Requests_raw
WHERE complaint_type = '' OR complaint_type != TRIM(complaint_type);

SELECT
	city
FROM bronze.NYC_Service_Requests_raw
WHERE city = '' OR city != TRIM(city);

-- 2. Check for outlier lengths
SELECT DISTINCT
	agency,
	LEN(agency)
FROM bronze.NYC_Service_Requests_raw
ORDER BY LEN(agency);

SELECT DISTINCT
	city,
	LEN(city)
FROM bronze.NYC_Service_Requests_raw
ORDER BY LEN(city);

SELECT DISTINCT
	borough,
	LEN(borough)
FROM bronze.NYC_Service_Requests_raw
ORDER BY LEN(borough);

SELECT DISTINCT
	complaint_type,
	LEN(complaint_type)
FROM bronze.NYC_Service_Requests_raw
ORDER BY LEN(complaint_type);

SELECT DISTINCT
	status,
	LEN(status)
FROM bronze.NYC_Service_Requests_raw
ORDER BY LEN(status);

-- Zip Code Validation
-- 1. Check for valid zip codes
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE incident_zip LIKE '[0-9][0-9][0-9][0-9][0-9]';

-- 2. Check for invalid zip codes excluding NULLs
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE incident_zip NOT LIKE '[0-9][0-9][0-9][0-9][0-9]';

-- 3. Check for invalid zip codes including NULLs
SELECT COUNT(*)
FROM bronze.NYC_Service_Requests_raw
WHERE incident_zip NOT LIKE '[0-9][0-9][0-9][0-9][0-9]' OR incident_zip IS NULL;