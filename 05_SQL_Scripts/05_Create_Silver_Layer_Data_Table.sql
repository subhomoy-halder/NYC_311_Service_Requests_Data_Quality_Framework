USE NYC_Service_Request_Database;

-- Create Silver Layer Data Table
SELECT * 
INTO silver.NYC_Service_Requests
FROM bronze.NYC_Service_Requests_raw;

-- Create Exception Table
CREATE TABLE silver.exception_table (
    unique_key VARCHAR(10),
    exception VARCHAR(100),
    time_stamp DATETIME NOT NULL DEFAULT GETDATE()
);