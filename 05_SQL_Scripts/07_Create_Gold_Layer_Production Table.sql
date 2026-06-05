USE NYC_Service_Request_Database;

CREATE TABLE gold.NYC_Service_Requests (
    unique_key INT PRIMARY KEY,
    created_date DATETIME NOT NULL,
    closed_date DATETIME,
    agency VARCHAR(10) NOT NULL,
    complaint_type VARCHAR(40) NOT NULL,
    incident_zip INT,
    city VARCHAR(30),
    status VARCHAR(12) NOT NULL,
    borough VARCHAR(14),
    latitude DECIMAL(15, 11),
    longitude DECIMAL(15, 11)
);