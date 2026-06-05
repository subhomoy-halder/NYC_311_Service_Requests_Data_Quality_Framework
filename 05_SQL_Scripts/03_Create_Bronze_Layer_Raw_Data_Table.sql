USE NYC_Service_Request_Database;

-- Create Bronze layer raw data table
CREATE TABLE bronze.NYC_Service_Requests_raw (
    unique_key VARCHAR(30),
    created_date VARCHAR(30),
    closed_date VARCHAR(30),
    agency VARCHAR(30),
    complaint_type VARCHAR(100),
    incident_zip VARCHAR(10),
    city VARCHAR(30),
    status VARCHAR(30),
    due_date VARCHAR(30),
    borough VARCHAR(30),
    latitude VARCHAR(30),
    longitude VARCHAR(30)
);

-- Insert raw data from CSV file to the Bronze Schema Raw data table
BULK INSERT bronze.NYC_Service_Requests_raw
FROM '311_Service_Requests_from_2020_to_Present_20260602.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,                
    FIELDTERMINATOR = ',',       
    ROWTERMINATOR = '0x0a'
);

-- Check all rows are loaded
SELECT TOP 100 * FROM bronze.NYC_Service_Requests_raw;