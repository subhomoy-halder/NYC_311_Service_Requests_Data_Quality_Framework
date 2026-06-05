USE NYC_Service_Request_Database;

-- 1. Remove duplicate entries (exclude unique_key, keep the latest record)
CREATE OR ALTER VIEW silver.duplicates AS 
SELECT *
FROM (
	SELECT
		unique_key,created_date,closed_date,agency,complaint_type,incident_zip,city,status,due_date,borough,latitude,longitude,
		ROW_NUMBER() 
			OVER(
				PARTITION BY created_date,closed_date,agency,complaint_type,incident_zip,city,status,due_date,borough,latitude,longitude
				ORDER BY CAST(created_date AS DATETIME) DESC
		) AS rn
	FROM silver.NYC_Service_Requests
) AS t
WHERE rn > 1;

-- 1a. Insert duplicate data into exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'duplicate'
FROM silver.duplicates;

-- 1b. Delete duplicate from silver.NYC_Service_Requests table
DELETE FROM silver.NYC_Service_Requests
WHERE unique_key IN (SELECT unique_key FROM silver.duplicates);

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 2. Remove rows where created_date > closed_date
CREATE OR ALTER VIEW silver.dates_created_closed AS 
SELECT
	unique_key,created_date,closed_date,agency,complaint_type,incident_zip,city,status,due_date,borough,latitude,longitude
FROM silver.NYC_Service_Requests
WHERE 
	CAST(created_date AS DATETIME) > CAST(closed_date AS DATETIME);

-- 2a. Insert discrepant dates into exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'created_date > closed_date'
FROM silver.dates_created_closed;

-- 2b. Delete rows from silver.NYC_Service_Requests
DELETE FROM silver.NYC_Service_Requests
WHERE unique_key IN (SELECT unique_key FROM silver.dates_created_closed);

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 3. Remove rows where created_date > due_date
CREATE OR ALTER VIEW silver.dates_created_due AS 
SELECT
	unique_key,created_date,closed_date,agency,complaint_type,incident_zip,city,status,due_date,borough,latitude,longitude
FROM silver.NYC_Service_Requests
WHERE 
	CAST(created_date AS DATETIME) > CAST(due_date AS DATETIME);

-- 3a. Insert discrepant dates into exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'created_date > due_date'
FROM silver.dates_created_due;

-- 3b. Delete rows from silver.NYC_Service_Requests
DELETE FROM silver.NYC_Service_Requests
WHERE unique_key IN (SELECT unique_key FROM silver.dates_created_due);

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 4. Remove rows where closed_date > '2026-06-03'
-- 4a. Insert discrepant date into exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'closed_date > 2026-06-03'
FROM silver.NYC_Service_Requests
WHERE CAST(closed_date AS DATETIME) > CAST('2026-06-03' AS DATETIME);

-- 4b. Delete rows from silver.NYC_Service_Requests
DELETE FROM silver.NYC_Service_Requests
WHERE unique_key IN (
	SELECT unique_key
	FROM silver.NYC_Service_Requests
	WHERE CAST(closed_date AS DATETIME) > CAST('2026-06-03' AS DATETIME)
);

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 5. Update status with 'closed' where closed_date is present but status != closed
CREATE OR ALTER VIEW silver.close_status AS
SELECT unique_key
FROM silver.NYC_Service_Requests
WHERE 
	closed_date IS NOT NULL 
	AND status != 'Closed';

-- 5a. Insert the to-be-modified data into exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'Update status to Closed'
FROM silver.close_status;

-- 5b. Update data in silver.NYC_Service_Requests
UPDATE silver.NYC_Service_Requests
SET status = 'Closed'
WHERE unique_key IN (SELECT unique_key FROM silver.close_status);

SELECT * FROM silver.close_status;

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 6. Delete rows with closed_date is null but status = 'Closed'
CREATE OR ALTER VIEW silver.closed_date_null_status_closed AS
SELECT unique_key
FROM silver.NYC_Service_Requests
WHERE 
	closed_date IS NULL 
	AND status = 'Closed';

-- 6a. Insert discrepant data into exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'Status Closed but closed_date NULL - Delete'
FROM silver.closed_date_null_status_closed;

-- 6b. Delete from silver.NYC_Service_Request
DELETE FROM silver.NYC_Service_Requests
WHERE unique_key IN (SELECT unique_key FROM silver.closed_date_null_status_closed);

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 7. Standardize city column from mapping table
-- 7a. Insert unique_keys to be updated to exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'Standardize city names'
FROM silver.NYC_Service_Requests

-- 7b. Update silver.NYC_Service_Requests
UPDATE silver.NYC_Service_Requests
SET city = CASE
    WHEN LOWER(city) IN ('albany') THEN 'Albany'
    WHEN LOWER(city) IN ('annapolis') THEN 'Annapolis'
    WHEN LOWER(city) IN ('apopka') THEN 'Apopka'
    WHEN LOWER(city) IN ('arverne') THEN 'Arverne'
    WHEN LOWER(city) IN ('astoria') THEN 'Astoria'
    WHEN LOWER(city) IN ('austin') THEN 'Austin'
    WHEN LOWER(city) IN ('bay park') THEN 'Bay Park'
    WHEN LOWER(city) IN ('bay shore') THEN 'Bay Shore'
    WHEN LOWER(city) IN ('bayside') THEN 'Bayside'
    WHEN LOWER(city) IN ('beaverton') THEN 'Beaverton'
    WHEN LOWER(city) IN ('bedford') THEN 'Bedford'
    WHEN LOWER(city) IN ('bellerose') THEN 'Bellerose'
    WHEN LOWER(city) IN ('bovina center') THEN 'Bovina Center'
    WHEN LOWER(city) IN ('bradenton') THEN 'Bradenton'
    WHEN LOWER(city) IN ('braintree') THEN 'Braintree'
    WHEN LOWER(city) IN ('breezy point') THEN 'Breezy Point'
    WHEN LOWER(city) IN ('bronx') THEN 'Bronx'
    WHEN LOWER(city) IN ('brooklyn') THEN 'Brooklyn'
    WHEN LOWER(city) IN ('buffalo') THEN 'Buffalo'
    WHEN LOWER(city) IN ('camarillo') THEN 'Camarillo'
    WHEN LOWER(city) IN ('cambria heights') THEN 'Cambria Heights'
    WHEN LOWER(city) IN ('canton') THEN 'Canton'
    WHEN LOWER(city) IN ('cedar falls') THEN 'Cedar Falls'
    WHEN LOWER(city) IN ('cedarhurst', 'cerdarhurst') THEN 'Cedarhurst'
    WHEN LOWER(city) IN ('centerport') THEN 'Centerport'
    WHEN LOWER(city) IN ('charlotte') THEN 'Charlotte'
    WHEN LOWER(city) IN ('chesapeake') THEN 'Chesapeake'
    WHEN LOWER(city) IN ('chester') THEN 'Chester'
    WHEN LOWER(city) IN ('cleveland') THEN 'Cleveland'
    WHEN LOWER(city) IN ('college point') THEN 'College Point'
    WHEN LOWER(city) IN ('columbia') THEN 'Columbia'
    WHEN LOWER(city) IN ('columbus') THEN 'Columbus'
    WHEN LOWER(city) IN ('conshohocken') THEN 'Conshohocken'
    WHEN LOWER(city) IN ('coram') THEN 'Coram'
    WHEN LOWER(city) IN ('corona') THEN 'Corona'
    WHEN LOWER(city) IN ('dallas') THEN 'Dallas'
    WHEN LOWER(city) IN ('darien') THEN 'Darien'
    WHEN LOWER(city) IN ('denver') THEN 'Denver'
    WHEN LOWER(city) IN ('east elmhurst') THEN 'East Elmhurst'
    WHEN LOWER(city) IN ('east hanover') THEN 'East Hanover'
    WHEN LOWER(city) IN ('east setauket') THEN 'East Setauket'
    WHEN LOWER(city) IN ('edina') THEN 'Edina'
    WHEN LOWER(city) IN ('elmhurst') THEN 'Elmhurst'
    WHEN LOWER(city) IN ('elmont') THEN 'Elmont'
    WHEN LOWER(city) IN ('elmsford') THEN 'Elmsford'
    WHEN LOWER(city) IN ('far rockaway', 'far rockway, queens') THEN 'Far Rockaway'
    WHEN LOWER(city) IN ('farmingdale') THEN 'Farmingdale'
    WHEN LOWER(city) IN ('fishkill') THEN 'Fishkill'
    WHEN LOWER(city) IN ('floral park') THEN 'Floral Park'
    WHEN LOWER(city) IN ('flushing') THEN 'Flushing'
    WHEN LOWER(city) IN ('forest hills') THEN 'Forest Hills'
    WHEN LOWER(city) IN ('ford washington', 'fort washington', 'ft washington') THEN 'Fort Washington'
    WHEN LOWER(city) IN ('forked river') THEN 'Forked River'
    WHEN LOWER(city) IN ('franklin square') THEN 'Franklin Square'
    WHEN LOWER(city) IN ('freeport') THEN 'Freeport'
    WHEN LOWER(city) IN ('fresh meadows') THEN 'Fresh Meadows'
    WHEN LOWER(city) IN ('fridley') THEN 'Fridley'
    WHEN LOWER(city) IN ('getzville') THEN 'Getzville'
    WHEN LOWER(city) IN ('glen clove', 'glen cove') THEN 'Glen Cove'
    WHEN LOWER(city) IN ('glen oaks') THEN 'Glen Oaks'
    WHEN LOWER(city) IN ('goodlettsville') THEN 'Goodlettsville'
    WHEN LOWER(city) IN ('great neck') THEN 'Great Neck'
    WHEN LOWER(city) IN ('greenvile') THEN 'Greenvile'
    WHEN LOWER(city) IN ('greenville') THEN 'Greenville'
    WHEN LOWER(city) IN ('greenwich') THEN 'Greenwich'
    WHEN LOWER(city) IN ('hamden') THEN 'Hamden'
    WHEN LOWER(city) IN ('harrisburg') THEN 'Harrisburg'
    WHEN LOWER(city) IN ('hauppauge') THEN 'Hauppauge'
    WHEN LOWER(city) IN ('hicksville') THEN 'Hicksville'
    WHEN LOWER(city) IN ('hoffman estates', 'holfman estate') THEN 'Hoffman Estates'
    WHEN LOWER(city) IN ('holladay') THEN 'Holladay'
    WHEN LOWER(city) IN ('hollis') THEN 'Hollis'
    WHEN LOWER(city) IN ('hoover') THEN 'Hoover'
    WHEN LOWER(city) IN ('horseheads') THEN 'Horseheads'
    WHEN LOWER(city) IN ('houston') THEN 'Houston'
    WHEN LOWER(city) IN ('howard beach') THEN 'Howard Beach'
    WHEN LOWER(city) IN ('indianapolis') THEN 'Indianapolis'
    WHEN LOWER(city) IN ('inwood') THEN 'Inwood'
    WHEN LOWER(city) IN ('irvine') THEN 'Irvine'
    WHEN LOWER(city) IN ('jackson heights') THEN 'Jackson Heights'
    WHEN LOWER(city) IN ('jamaica') THEN 'Jamaica'
    WHEN LOWER(city) IN ('jersey city') THEN 'Jersey City'
    WHEN LOWER(city) IN ('katy') THEN 'Katy'
    WHEN LOWER(city) IN ('kearny') THEN 'Kearny'
    WHEN LOWER(city) IN ('kew gardens') THEN 'Kew Gardens'
    WHEN LOWER(city) IN ('laguardia airport') THEN 'Laguardia Airport'
    WHEN LOWER(city) IN ('las vagus', 'las vegas') THEN 'Las Vegas'
    WHEN LOWER(city) IN ('lehi') THEN 'Lehi'
    WHEN LOWER(city) IN ('little neck') THEN 'Little Neck'
    WHEN LOWER(city) IN ('long island') THEN 'Long Island'
    WHEN LOWER(city) IN ('long island city') THEN 'Long Island City'
    WHEN LOWER(city) IN ('los angeles') THEN 'Los Angeles'
    WHEN LOWER(city) IN ('macon') THEN 'Macon'
    WHEN LOWER(city) IN ('manhattan') THEN 'Manhattan'
    WHEN LOWER(city) IN ('marshfield') THEN 'Marshfield'
    WHEN LOWER(city) IN ('maspeth') THEN 'Maspeth'
    WHEN LOWER(city) IN ('mastic') THEN 'Mastic'
    WHEN LOWER(city) IN ('melville') THEN 'Melville'
    WHEN LOWER(city) IN ('miami') THEN 'Miami'
    WHEN LOWER(city) IN ('middle village') THEN 'Middle Village'
    WHEN LOWER(city) IN ('mineola') THEN 'Mineola'
    WHEN LOWER(city) IN ('mobile') THEN 'Mobile'
    WHEN LOWER(city) IN ('moline') THEN 'Moline'
    WHEN LOWER(city) IN ('mount laurel') THEN 'Mount Laurel'
    WHEN LOWER(city) IN ('nesconset') THEN 'Nesconset'
    WHEN LOWER(city) IN ('new hyde park') THEN 'New Hyde Park'
    WHEN LOWER(city) IN ('new jersey', 'nj') THEN 'New Jersey'
    WHEN LOWER(city) IN ('new york', 'ny', 'nyc') THEN 'New York City'
    WHEN LOWER(city) IN ('newark') THEN 'Newark'
    WHEN LOWER(city) IN ('newburgh') THEN 'Newburgh'
    WHEN LOWER(city) IN ('newcastle') THEN 'Newcastle'
    WHEN LOWER(city) IN ('norfolk') THEN 'Norfolk'
    WHEN LOWER(city) IN ('norwood') THEN 'Norwood'
    WHEN LOWER(city) IN ('noxville') THEN 'Noxville'
    WHEN LOWER(city) IN ('oakland gardens') THEN 'Oakland Gardens'
    WHEN LOWER(city) IN ('oceanside') THEN 'Oceanside'
    WHEN LOWER(city) IN ('ozone park') THEN 'Ozone Park'
    WHEN LOWER(city) IN ('patchogue') THEN 'Patchogue'
    WHEN LOWER(city) IN ('paterson') THEN 'Paterson'
    WHEN LOWER(city) IN ('pelham') THEN 'Pelham'
    WHEN LOWER(city) IN ('piscataway') THEN 'Piscataway'
    WHEN LOWER(city) IN ('pittburgh', 'pittsburg') THEN 'Pittsburgh'
    WHEN LOWER(city) IN ('pittston') THEN 'Pittston'
    WHEN LOWER(city) IN ('plainview') THEN 'Plainview'
    WHEN LOWER(city) IN ('pomona') THEN 'Pomona'
    WHEN LOWER(city) IN ('port chester') THEN 'Port Chester'
    WHEN LOWER(city) IN ('port jefferson station') THEN 'Port Jefferson Station'
    WHEN LOWER(city) IN ('80th street queens(ozone park)', 'queens', 'queens(south jamaica)') THEN 'Queens'
    WHEN LOWER(city) IN ('queens village') THEN 'Queens Village'
    WHEN LOWER(city) IN ('rego park') THEN 'Rego Park'
    WHEN LOWER(city) IN ('richmond hill') THEN 'Richmond Hill'
    WHEN LOWER(city) IN ('ridgewood') THEN 'Ridgewood'
    WHEN LOWER(city) IN ('rochester') THEN 'Rochester'
    WHEN LOWER(city) IN ('ronkonkoma') THEN 'Ronkonkoma'
    WHEN LOWER(city) IN ('roosevelt') THEN 'Roosevelt'
    WHEN LOWER(city) IN ('rosedale') THEN 'Rosedale'
    WHEN LOWER(city) IN ('saint albans') THEN 'Saint Albans'
    WHEN LOWER(city) IN ('san diego') THEN 'San Diego'
    WHEN LOWER(city) IN ('san francisco') THEN 'San Francisco'
    WHEN LOWER(city) IN ('san lane') THEN 'San Lane'
    WHEN LOWER(city) IN ('sartell') THEN 'Sartell'
    WHEN LOWER(city) IN ('seagoville') THEN 'Seagoville'
    WHEN LOWER(city) IN ('shoreview') THEN 'Shoreview'
    WHEN LOWER(city) IN ('sioux falls') THEN 'Sioux Falls'
    WHEN LOWER(city) IN ('smithtown') THEN 'Smithtown'
    WHEN LOWER(city) IN ('solon') THEN 'Solon'
    WHEN LOWER(city) IN ('south ozone park') THEN 'South Ozone Park'
    WHEN LOWER(city) IN ('south richmond hill') THEN 'South Richmond Hill'
    WHEN LOWER(city) IN ('spanish fork') THEN 'Spanish Fork'
    WHEN LOWER(city) IN ('spring valley') THEN 'Spring Valley'
    WHEN LOWER(city) IN ('springfield') THEN 'Springfield'
    WHEN LOWER(city) IN ('springfield gardens') THEN 'Springfield Gardens'
    WHEN LOWER(city) IN ('staten island') THEN 'Staten Island'
    WHEN LOWER(city) IN ('stream valley') THEN 'Stream Valley'
    WHEN LOWER(city) IN ('sunnyside') THEN 'Sunnyside'
    WHEN LOWER(city) IN ('syoffet', 'syosset', 'syossett') THEN 'Syosset'
    WHEN LOWER(city) IN ('tarrytown') THEN 'Tarrytown'
    WHEN LOWER(city) IN ('taylorsville') THEN 'Taylorsville'
    WHEN LOWER(city) IN ('toledo') THEN 'Toledo'
    WHEN LOWER(city) IN ('troy') THEN 'Troy'
    WHEN LOWER(city) IN ('uniondale') THEN 'Uniondale'
    WHEN LOWER(city) IN ('valley stream', 'valleystream') THEN 'Valley Stream'
    WHEN LOWER(city) IN ('venice') THEN 'Venice'
    WHEN LOWER(city) IN ('wantagh') THEN 'Wantagh'
    WHEN LOWER(city) IN ('wappingers falls') THEN 'Wappingers Falls'
    WHEN LOWER(city) IN ('ware town') THEN 'Ware Town'
    WHEN LOWER(city) IN ('warwick') THEN 'Warwick'
    WHEN LOWER(city) IN ('west hempstead') THEN 'West Hempstead'
    WHEN LOWER(city) IN ('westbury') THEN 'Westbury'
    WHEN LOWER(city) IN ('whitestone') THEN 'Whitestone'
    WHEN LOWER(city) IN ('wilmington') THEN 'Wilmington'
    WHEN LOWER(city) IN ('woodhaven') THEN 'Woodhaven'
    WHEN LOWER(city) IN ('woodside') THEN 'Woodside'
    WHEN LOWER(city) IN ('yonkers') THEN 'Yonkers'
    WHEN LOWER(city) IN ('york town heights') THEN 'York Town Heights'
    ELSE 'Others'
END;

SELECT TOP 100 * FROM silver.NYC_Service_Requests;

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 8. Standardize borough column from mapping table
-- 8a. Insert unique_keys to be updated to exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'Standardize boroughs'
FROM silver.NYC_Service_Requests

-- 8b. Update silver.NYC_Service_Requests
UPDATE silver.NYC_Service_Requests
SET borough = CASE
    WHEN LOWER(borough) IN ('manhattan') THEN 'Manhattan'
    WHEN LOWER(borough) IN ('queens') THEN 'Queens'
    WHEN LOWER(borough) IN ('bronx') THEN 'Bronx'
    WHEN LOWER(borough) IN ('brooklyn') THEN 'Brooklyn'
    WHEN LOWER(borough) IN ('staten island') THEN 'Staten Island'
    ELSE 'Others'
END;

SELECT TOP 100 * FROM silver.NYC_Service_Requests;

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 9. Standardize complaint_type column from mapping table
-- 9a. Insert unique_key to be updated to exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'Standardize complaint_types'
FROM silver.NYC_Service_Requests

-- 9b. Update silver.NYC_Service_Requests

UPDATE silver.NYC_Service_Requests
SET complaint_type = CASE
    WHEN LOWER(complaint_type) IN ('ahv inspection unit') THEN 'AHV Inspection Unit'
    WHEN LOWER(complaint_type) IN ('abandoned bike') THEN 'Abandoned Bike'
    WHEN LOWER(complaint_type) IN ('abandoned vehicle') THEN 'Abandoned Vehicle'
    WHEN LOWER(complaint_type) IN ('air quality') THEN 'Air Quality'
    WHEN LOWER(complaint_type) IN ('animal facility - no permit') THEN 'Animal Facility - No Permit'
    WHEN LOWER(complaint_type) IN ('animal in a park') THEN 'Animal In A Park'
    WHEN LOWER(complaint_type) IN ('animal-abuse') THEN 'Animal-Abuse'
    WHEN LOWER(complaint_type) IN ('appliance') THEN 'Appliance'
    WHEN LOWER(complaint_type) IN ('asbestos') THEN 'Asbestos'
    WHEN LOWER(complaint_type) IN ('best/site safety') THEN 'BEST/Site Safety'
    WHEN LOWER(complaint_type) IN ('beach/pool/sauna complaint') THEN 'Beach/Pool/Sauna Complaint'
    WHEN LOWER(complaint_type) IN ('bench') THEN 'Bench'
    WHEN LOWER(complaint_type) IN ('bike rack') THEN 'Bike Rack'
    WHEN LOWER(complaint_type) IN ('bike/roller/skate') THEN 'Bike/Roller/Skate'
    WHEN LOWER(complaint_type) IN ('bike/roller/skate chronic') THEN 'Bike/Roller/Skate Chronic'
    WHEN LOWER(complaint_type) IN ('blocked driveway') THEN 'Blocked Driveway'
    WHEN LOWER(complaint_type) IN ('boilers') THEN 'Boilers'
    WHEN LOWER(complaint_type) IN ('borough office') THEN 'Borough Office'
    WHEN LOWER(complaint_type) IN ('bridge condition') THEN 'Bridge Condition'
    WHEN LOWER(complaint_type) IN ('broken parking meter') THEN 'Broken Parking Meter'
    WHEN LOWER(complaint_type) IN ('building condition') THEN 'Building Condition'
    WHEN LOWER(complaint_type) IN ('building drinking water tank') THEN 'Building Drinking Water Tank'
    WHEN LOWER(complaint_type) IN ('building marshal''s office', 'building marshals office') THEN 'Building Marshal''s Office'
    WHEN LOWER(complaint_type) IN ('building/use') THEN 'Building/Use'
    WHEN LOWER(complaint_type) IN ('bus stop shelter complaint') THEN 'Bus Stop Shelter Complaint'
    WHEN LOWER(complaint_type) IN ('bus stop shelter placement') THEN 'Bus Stop Shelter Placement'
    WHEN LOWER(complaint_type) IN ('calorie labeling') THEN 'Calorie Labeling'
    WHEN LOWER(complaint_type) IN ('cannabis retailer') THEN 'Cannabis Retailer'
    WHEN LOWER(complaint_type) IN ('commercial disposal complaint') THEN 'Commercial Disposal Complaint'
    WHEN LOWER(complaint_type) IN ('construction lead dust') THEN 'Construction Lead Dust'
    WHEN LOWER(complaint_type) IN ('construction safety enforcement') THEN 'Construction Safety Enforcement'
    WHEN LOWER(complaint_type) IN ('consumer complaint') THEN 'Consumer Complaint'
    WHEN LOWER(complaint_type) IN ('cooling tower') THEN 'Cooling Tower'
    WHEN LOWER(complaint_type) IN ('cranes and derricks') THEN 'Cranes And Derricks'
    WHEN LOWER(complaint_type) IN ('curb condition') THEN 'Curb Condition'
    WHEN LOWER(complaint_type) IN ('dep highway condition') THEN 'DEP Highway Condition'
    WHEN LOWER(complaint_type) IN ('dep sidewalk condition') THEN 'DEP Sidewalk Condition'
    WHEN LOWER(complaint_type) IN ('dep street condition') THEN 'DEP Street Condition'
    WHEN LOWER(complaint_type) IN ('dsny internal') THEN 'DSNY Internal'
    WHEN LOWER(complaint_type) IN ('damaged tree') THEN 'Damaged Tree'
    WHEN LOWER(complaint_type) IN ('day care') THEN 'Day Care'
    WHEN LOWER(complaint_type) IN ('dead animal') THEN 'Dead Animal'
    WHEN LOWER(complaint_type) IN ('dead/dying tree') THEN 'Dead/Dying Tree'
    WHEN LOWER(complaint_type) IN ('dept of investigations') THEN 'Dept Of Investigations'
    WHEN LOWER(complaint_type) IN ('derelict vehicles') THEN 'Derelict Vehicles'
    WHEN LOWER(complaint_type) IN ('dirty condition') THEN 'Dirty Condition'
    WHEN LOWER(complaint_type) IN ('disorderly youth') THEN 'Disorderly Youth'
    WHEN LOWER(complaint_type) IN ('door/window') THEN 'Door/Window'
    WHEN LOWER(complaint_type) IN ('drinking') THEN 'Drinking'
    WHEN LOWER(complaint_type) IN ('drinking water') THEN 'Drinking Water'
    WHEN LOWER(complaint_type) IN ('drug activity') THEN 'Drug Activity'
    WHEN LOWER(complaint_type) IN ('dumpster complaint') THEN 'Dumpster Complaint'
    WHEN LOWER(complaint_type) IN ('e-scooter') THEN 'E-Scooter'
    WHEN LOWER(complaint_type) IN ('electric') THEN 'Electric'
    WHEN LOWER(complaint_type) IN ('electrical') THEN 'Electrical'
    WHEN LOWER(complaint_type) IN ('elevator') THEN 'Elevator'
    WHEN LOWER(complaint_type) IN ('emergency response team (ert)') THEN 'Emergency Response Team (ERT)'
    WHEN LOWER(complaint_type) IN ('encampment') THEN 'Encampment'
    WHEN LOWER(complaint_type) IN ('fhv licensee complaint') THEN 'FHV Licensee Complaint'
    WHEN LOWER(complaint_type) IN ('ferry complaint') THEN 'Ferry Complaint'
    WHEN LOWER(complaint_type) IN ('ferry inquiry') THEN 'Ferry Inquiry'
    WHEN LOWER(complaint_type) IN ('flooring/stairs') THEN 'Flooring/Stairs'
    WHEN LOWER(complaint_type) IN ('food establishment') THEN 'Food Establishment'
    WHEN LOWER(complaint_type) IN ('food poisoning') THEN 'Food Poisoning'
    WHEN LOWER(complaint_type) IN ('for hire vehicle complaint') THEN 'For Hire Vehicle Complaint'
    WHEN LOWER(complaint_type) IN ('for hire vehicle report') THEN 'For Hire Vehicle Report'
    WHEN LOWER(complaint_type) IN ('found property') THEN 'Found Property'
    WHEN LOWER(complaint_type) IN ('general') THEN 'General'
    WHEN LOWER(complaint_type) IN ('general construction/plumbing') THEN 'General Construction/Plumbing'
    WHEN LOWER(complaint_type) IN ('graffiti') THEN 'Graffiti'
    WHEN LOWER(complaint_type) IN ('green taxi complaint') THEN 'Green Taxi Complaint'
    WHEN LOWER(complaint_type) IN ('green taxi report') THEN 'Green Taxi Report'
    WHEN LOWER(complaint_type) IN ('harboring bees/wasps') THEN 'Harboring Bees/Wasps'
    WHEN LOWER(complaint_type) IN ('hazardous materials') THEN 'Hazardous Materials'
    WHEN LOWER(complaint_type) IN ('heat/hot water') THEN 'Heat/Hot Water'
    WHEN LOWER(complaint_type) IN ('highway condition') THEN 'Highway Condition'
    WHEN LOWER(complaint_type) IN ('highway sign - damaged') THEN 'Highway Sign - Damaged'
    WHEN LOWER(complaint_type) IN ('highway sign - dangling') THEN 'Highway Sign - Dangling'
    WHEN LOWER(complaint_type) IN ('highway sign - missing') THEN 'Highway Sign - Missing'
    WHEN LOWER(complaint_type) IN ('homeless person assistance') THEN 'Homeless Person Assistance'
    WHEN LOWER(complaint_type) IN ('illegal animal kept as pet') THEN 'Illegal Animal Kept As Pet'
    WHEN LOWER(complaint_type) IN ('illegal animal sold') THEN 'Illegal Animal Sold'
    WHEN LOWER(complaint_type) IN ('illegal dumping') THEN 'Illegal Dumping'
    WHEN LOWER(complaint_type) IN ('illegal fireworks') THEN 'Illegal Fireworks'
    WHEN LOWER(complaint_type) IN ('illegal parking') THEN 'Illegal Parking'
    WHEN LOWER(complaint_type) IN ('illegal posting') THEN 'Illegal Posting'
    WHEN LOWER(complaint_type) IN ('illegal tree damage') THEN 'Illegal Tree Damage'
    WHEN LOWER(complaint_type) IN ('incorrect data') THEN 'Incorrect Data'
    WHEN LOWER(complaint_type) IN ('indoor air quality') THEN 'Indoor Air Quality'
    WHEN LOWER(complaint_type) IN ('indoor sewage') THEN 'Indoor Sewage'
    WHEN LOWER(complaint_type) IN ('industrial waste') THEN 'Industrial Waste'
    WHEN LOWER(complaint_type) IN ('institution disposal complaint') THEN 'Institution Disposal Complaint'
    WHEN LOWER(complaint_type) IN ('investigations and discipline (iad)') THEN 'Investigations and Discipline (IAD)'
    WHEN LOWER(complaint_type) IN ('lead') THEN 'Lead'
    WHEN LOWER(complaint_type) IN ('leaning bar') THEN 'Leaning Bar'
    WHEN LOWER(complaint_type) IN ('lifeguard') THEN 'Lifeguard'
    WHEN LOWER(complaint_type) IN ('linknyc') THEN 'LinkNYC'
    WHEN LOWER(complaint_type) IN ('litter basket complaint') THEN 'Litter Basket Complaint'
    WHEN LOWER(complaint_type) IN ('litter basket request') THEN 'Litter Basket Request'
    WHEN LOWER(complaint_type) IN ('lost property') THEN 'Lost Property'
    WHEN LOWER(complaint_type) IN ('lot condition') THEN 'Lot Condition'
    WHEN LOWER(complaint_type) IN ('maintenance or facility') THEN 'Maintenance Or Facility'
    WHEN LOWER(complaint_type) IN ('missed collection') THEN 'Missed Collection'
    WHEN LOWER(complaint_type) IN ('mobile food vendor') THEN 'Mobile Food Vendor'
    WHEN LOWER(complaint_type) IN ('mold') THEN 'Mold'
    WHEN LOWER(complaint_type) IN ('mosquitoes') THEN 'Mosquitoes'
    WHEN LOWER(complaint_type) IN ('municipal parking facility') THEN 'Municipal Parking Facility'
    WHEN LOWER(complaint_type) IN ('new tree request') THEN 'New Tree Request'
    WHEN LOWER(complaint_type) IN ('noise') THEN 'Noise'
    WHEN LOWER(complaint_type) IN ('noise - commercial') THEN 'Noise - Commercial'
    WHEN LOWER(complaint_type) IN ('noise - helicopter') THEN 'Noise - Helicopter'
    WHEN LOWER(complaint_type) IN ('noise - house of worship') THEN 'Noise - House Of Worship'
    WHEN LOWER(complaint_type) IN ('noise - park') THEN 'Noise - Park'
    WHEN LOWER(complaint_type) IN ('noise - residential') THEN 'Noise - Residential'
    WHEN LOWER(complaint_type) IN ('noise - street/sidewalk') THEN 'Noise - Street/Sidewalk'
    WHEN LOWER(complaint_type) IN ('noise - vehicle') THEN 'Noise - Vehicle'
    WHEN LOWER(complaint_type) IN ('non-emergency police matter') THEN 'Non-Emergency Police Matter'
    WHEN LOWER(complaint_type) IN ('non-residential heat') THEN 'Non-Residential Heat'
    WHEN LOWER(complaint_type) IN ('obstruction') THEN 'Obstruction'
    WHEN LOWER(complaint_type) IN ('oil or gas spill') THEN 'Oil Or Gas Spill'
    WHEN LOWER(complaint_type) IN ('outdoor dining') THEN 'Outdoor Dining'
    WHEN LOWER(complaint_type) IN ('outside building') THEN 'Outside Building'
    WHEN LOWER(complaint_type) IN ('overgrown tree/branches') THEN 'Overgrown Tree/Branches'
    WHEN LOWER(complaint_type) IN ('paint/plaster') THEN 'Paint/Plaster'
    WHEN LOWER(complaint_type) IN ('panhandling') THEN 'Panhandling'
    WHEN LOWER(complaint_type) IN ('pet sale') THEN 'Pet Sale'
    WHEN LOWER(complaint_type) IN ('pet shop') THEN 'Pet Shop'
    WHEN LOWER(complaint_type) IN ('plant') THEN 'Plant'
    WHEN LOWER(complaint_type) IN ('plumbing') THEN 'Plumbing'
    WHEN LOWER(complaint_type) IN ('poison ivy') THEN 'Poison Ivy'
    WHEN LOWER(complaint_type) IN ('posting advertisement') THEN 'Posting Advertisement'
    WHEN LOWER(complaint_type) IN ('public payphone complaint') THEN 'Public Payphone Complaint'
    WHEN LOWER(complaint_type) IN ('public toilet') THEN 'Public Toilet'
    WHEN LOWER(complaint_type) IN ('radioactive material') THEN 'Radioactive Material'
    WHEN LOWER(complaint_type) IN ('real time enforcement') THEN 'Real Time Enforcement'
    WHEN LOWER(complaint_type) IN ('recycling basket complaint') THEN 'Recycling Basket Complaint'
    WHEN LOWER(complaint_type) IN ('residential disposal complaint') THEN 'Residential Disposal Complaint'
    WHEN LOWER(complaint_type) IN ('rodent') THEN 'Rodent'
    WHEN LOWER(complaint_type) IN ('root/sewer/sidewalk condition') THEN 'Root/Sewer/Sidewalk Condition'
    WHEN LOWER(complaint_type) IN ('safety') THEN 'Safety'
    WHEN LOWER(complaint_type) IN ('sanitation worker or vehicle complaint') THEN 'Sanitation Worker Or Vehicle Complaint'
    WHEN LOWER(complaint_type) IN ('scaffold safety') THEN 'Scaffold Safety'
    WHEN LOWER(complaint_type) IN ('school maintenance') THEN 'School Maintenance'
    WHEN LOWER(complaint_type) IN ('sewer') THEN 'Sewer'
    WHEN LOWER(complaint_type) IN ('sidewalk condition') THEN 'Sidewalk Condition'
    WHEN LOWER(complaint_type) IN ('smoking or vaping') THEN 'Smoking Or Vaping'
    WHEN LOWER(complaint_type) IN ('snow or ice') THEN 'Snow Or Ice'
    WHEN LOWER(complaint_type) IN ('snw') THEN 'SNW'
    WHEN LOWER(complaint_type) IN ('special natural area district (snad)') THEN 'Special Natural Area District (SNAD)'
    WHEN LOWER(complaint_type) IN ('special operations') THEN 'Special Operations'
    WHEN LOWER(complaint_type) IN ('special projects inspection team (spit)') THEN 'Special Projects Inspection Team (SPIT)'
    WHEN LOWER(complaint_type) IN ('squeegee') THEN 'Squeegee'
    WHEN LOWER(complaint_type) IN ('standing water') THEN 'Standing Water'
    WHEN LOWER(complaint_type) IN ('street condition') THEN 'Street Condition'
    WHEN LOWER(complaint_type) IN ('street light condition') THEN 'Street Light Condition'
    WHEN LOWER(complaint_type) IN ('street sign - damaged') THEN 'Street Sign - Damaged'
    WHEN LOWER(complaint_type) IN ('street sign - dangling') THEN 'Street Sign - Dangling'
    WHEN LOWER(complaint_type) IN ('street sign - missing') THEN 'Street Sign - Missing'
    WHEN LOWER(complaint_type) IN ('street sweeping complaint') THEN 'Street Sweeping Complaint'
    WHEN LOWER(complaint_type) IN ('tanning') THEN 'Tanning'
    WHEN LOWER(complaint_type) IN ('tattooing') THEN 'Tattooing'
    WHEN LOWER(complaint_type) IN ('taxi complaint') THEN 'Taxi Complaint'
    WHEN LOWER(complaint_type) IN ('taxi compliment') THEN 'Taxi Compliment'
    WHEN LOWER(complaint_type) IN ('taxi licensee complaint') THEN 'Taxi Licensee Complaint'
    WHEN LOWER(complaint_type) IN ('taxi report') THEN 'Taxi Report'
    WHEN LOWER(complaint_type) IN ('tobacco or non-tobacco sale') THEN 'Tobacco Or Non-Tobacco Sale'
    WHEN LOWER(complaint_type) IN ('traffic') THEN 'Traffic'
    WHEN LOWER(complaint_type) IN ('traffic signal condition') THEN 'Traffic Signal Condition'
    WHEN LOWER(complaint_type) IN ('transfer station complaint') THEN 'Transfer Station Complaint'
    WHEN LOWER(complaint_type) IN ('trapping pigeon') THEN 'Trapping Pigeon'
    WHEN LOWER(complaint_type) IN ('tunnel condition') THEN 'Tunnel Condition'
    WHEN LOWER(complaint_type) IN ('unleashed dog') THEN 'Unleashed Dog'
    WHEN LOWER(complaint_type) IN ('unsanitary animal facility') THEN 'Unsanitary Animal Facility'
    WHEN LOWER(complaint_type) IN ('unsanitary animal pvt property') THEN 'Unsanitary Animal Pvt Property'
    WHEN LOWER(complaint_type) IN ('unsanitary condition') THEN 'Unsanitary Condition'
    WHEN LOWER(complaint_type) IN ('unsanitary pigeon condition') THEN 'Unsanitary Pigeon Condition'
    WHEN LOWER(complaint_type) IN ('unspecified') THEN 'Unspecified'
    WHEN LOWER(complaint_type) IN ('uprooted stump') THEN 'Uprooted Stump'
    WHEN LOWER(complaint_type) IN ('urinating in public') THEN 'Urinating In Public'
    WHEN LOWER(complaint_type) IN ('vendor enforcement') THEN 'Vendor Enforcement'
    WHEN LOWER(complaint_type) IN ('violation of park rules') THEN 'Violation Of Park Rules'
    WHEN LOWER(complaint_type) IN ('water conservation') THEN 'Water Conservation'
    WHEN LOWER(complaint_type) IN ('water leak') THEN 'Water Leak'
    WHEN LOWER(complaint_type) IN ('water quality') THEN 'Water Quality'
    WHEN LOWER(complaint_type) IN ('water system') THEN 'Water System'
    WHEN LOWER(complaint_type) IN ('wayfinding') THEN 'Wayfinding'
    WHEN LOWER(complaint_type) IN ('window guard') THEN 'Window Guard'
    WHEN LOWER(complaint_type) IN ('wood pile remaining') THEN 'Wood Pile Remaining'
    WHEN LOWER(complaint_type) IN ('x-ray machine/equipment') THEN 'X-Ray Machine/Equipment'
    ELSE 'Others'
END;

SELECT TOP 100 * FROM silver.NYC_Service_Requests;

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 10. Delete invalid zip codes (excluding NULLs)
CREATE OR ALTER VIEW silver.invalid_non_null_zip AS
SELECT unique_key
FROM silver.NYC_Service_Requests
WHERE 
    incident_zip NOT LIKE '[0-9][0-9][0-9][0-9][0-9]' 
    AND incident_zip IS NOT NULL;

-- 10a. Insert discrepant data into exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'Invalid Non NULL zip code'
FROM silver.invalid_non_null_zip;

-- 10b. Delete invalid zips from silver.NYC_Service_Requests
DELETE FROM silver.NYC_Service_Requests
WHERE unique_key IN (SELECT unique_key FROM silver.invalid_non_null_zip);

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 11. Alter ingestion VARCHAR columns to appropriate datatypes
-- 11a. Record column datatype update in exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'all column datatype update'
FROM silver.NYC_Service_Requests;

-- 11b. Alter columns
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN unique_key INT;
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN created_date DATETIME;
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN closed_date DATETIME;
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN agency VARCHAR(10);
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN complaint_type VARCHAR(40);
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN incident_zip INT;
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN city VARCHAR(30);
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN status VARCHAR(12);
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN due_date DATETIME;
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN borough VARCHAR(14);
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN latitude DECIMAL(15, 11);
ALTER TABLE silver.NYC_Service_Requests ALTER COLUMN longitude DECIMAL(15, 11);

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 12. Recheck for duplicates after cleaning
CREATE OR ALTER VIEW silver.check_duplicates_after_cleaning AS
SELECT unique_key
FROM (
    SELECT
        unique_key,created_date,closed_date,agency,complaint_type,incident_zip,city,status,due_date,borough,latitude,longitude,
        ROW_NUMBER() OVER(PARTITION BY created_date,closed_date,agency,complaint_type,incident_zip,city,status,due_date,borough,latitude,longitude
                          ORDER BY created_date DESC
        ) AS rn
    FROM silver.NYC_Service_Requests
) AS t
WHERE rn > 1;

SELECT COUNT(*) FROM silver.check_duplicates_after_cleaning;

-- 12a. Record new dupicates to be deleted in exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'New duplicates after cleaning (28 new duplicates)'
FROM silver.check_duplicates_after_cleaning;

-- 12b. Delete new duplicates from silver.NYC_Service_Requests
DELETE FROM silver.NYC_Service_Requests
WHERE unique_key IN (SELECT unique_key FROM silver.check_duplicates_after_cleaning)

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 13. Drop due_date column due to lack of sufficient values
-- 13a. Record dropping due_date column in exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT 'all rows', 'drop due_date';

-- 13b. Drop column due_date from silver.NYC_Service_Requests
ALTER TABLE silver.NYC_Service_Requests
DROP COLUMN due_date;

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 14. Recheck for duplicates after column drop
SELECT *
FROM (
    SELECT
        unique_key,created_date,closed_date,agency,complaint_type,incident_zip,city,status,borough,latitude,longitude,
        ROW_NUMBER() OVER(PARTITION BY created_date,closed_date,agency,complaint_type,incident_zip,city,status,borough,latitude,longitude
                          ORDER BY created_date DESC
        ) AS rn
    FROM silver.NYC_Service_Requests
) AS t
WHERE rn > 1;

-- No duplicates found

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- 15. Check zip code validity
CREATE OR ALTER VIEW silver.zip_code_validity AS 
SELECT unique_key
FROM silver.NYC_Service_Requests
WHERE LEN(incident_zip) != 5 AND incident_zip IS NOT NULL;

-- 15a. Record invalid zip codes in exception table
INSERT INTO silver.exception_table (unique_key, exception)
SELECT unique_key, 'Invalid Zip Code'
FROM silver.zip_code_validity;

-- 15b. Delete rows from silver.NYC_Service_Requests
DELETE FROM silver.NYC_Service_Requests
WHERE unique_key IN (SELECT unique_key FROM silver.zip_code_validity);

-------------------------------------------------------------------------
-------------------------------------------------------------------------