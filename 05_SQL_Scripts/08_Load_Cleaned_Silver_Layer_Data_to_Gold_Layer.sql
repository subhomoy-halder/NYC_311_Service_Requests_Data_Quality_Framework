USE NYC_Service_Request_Database;

INSERT INTO gold.NYC_Service_Requests (
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
)
SELECT 
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
FROM silver.NYC_Service_Requests;

SELECT * FROM gold.NYC_Service_Requests;