USE NYC_Service_Request_Database;

-- Create the Bronze schema for raw data
CREATE SCHEMA bronze;
GO

-- Create the Silver schema for cleansed data
CREATE SCHEMA silver;
GO

-- Create the Gold schema aggregation and analysis
CREATE SCHEMA gold;
GO