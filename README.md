# Enterprise Data Quality Assessment and Remediation for NYC 311 Service Requests

### SQL Driven Data Cleaning and Quality Engineering Project with Responsible AI Augmentation

> **A production style SQL Server data quality pipeline that profiles, validates, remediates, standardizes and audits over 5.3 million NYC 311 service request records before analytical consumption.**

------------------------------------------------------------------------

## Executive Summary

Operational datasets are rarely analysis ready when they arrive. This project demonstrates how a large operational dataset can be transformed into a structured, validated analytical dataset using a **rule driven data quality framework** rather than adhoc cleaning.

Using the **NYC 311 Service Requests** dataset, I designed and implemented an end to end data quality workflow in **Microsoft SQL Server** covering:

1.   Raw data ingestion
2.   Medallion data architecture
3.   Data profiling
4.   NULL and completeness analysis
5.   Duplicate detection
6.   Cardinality analysis
7.   Temporal validation
8.   Geographic validation
9.   Categorical consistency analysis
10.   Formal Data Quality Rulebook
11.   Rule based remediation
12.   Reference data standardization
13.   Exception management
14.   Data type enforcement
15.   Post clean validation
16.   Data quality scorecard
17.   Cleaning impact analysis
18.   Responsible AI assisted development

The result was a cleaned analytical dataset containing **5,206,784 records across 11 production columns**, compared with **5,314,955 raw records across 12 columns**.

------------------------------------------------------------------------

# 1. Project at a Glance

```text
Project Type:                     Data Quality Engineering / SQL Data Cleaning
Dataset:                          NYC 311 Service Requests
Source:                           NYC Open Data
Raw Records:                      5,314,955
Clean Records:                    5,206,784
Records Removed / Quarantined:    108,171
Raw Columns:                      12
Production Columns:               11
Database:                         Microsoft SQL Server
Architecture:                     Medallion Architecture (Bronze → Silver → Gold)
Primary Language:                 T-SQL
Validation Framework:             Rule based Data Quality Rulebook
Quality Dimensions:               Completeness, Uniqueness, Validity, Timeliness
AI Usage:                         Development assistance with analyst controlled validation
Dataset coverage:                 2025-01-01 to 2026-06-01.
```

------------------------------------------------------------------------

# 2. Business Problem

NYC 311 is a large operational service request system containing information about citizen complaints, responsible agencies, request status, timestamps, locations and complaint classifications.

At this scale, data quality problems can affect:

1.   Operational reporting
2.   Service request volumes
3.   Geographic analysis
4.   Complaint categorization
5.   Resolution time analysis
6.   Agency performance reporting
7.   Downstream dashboards
8.   Analytical models

The project therefore treats data quality as a formal engineering problem and not as a preprocessing step.

### Core question

> **How can a large operational dataset be systematically assessed, remediated, validated and made trustworthy for analytical consumption while preserving traceability of the changes made?**

------------------------------------------------------------------------

# 3. Project Objectives

The project was designed around seven objectives:

1.  Assess the quality of the raw dataset through systematic profiling.
2.  Identify quality problems across multiple dimensions.
3.  Translate identified issues into explicit business and technical rules.
4.  Remediate data using reproducible SQL logic.
5.  Preserve traceability of records removed or modified.
6.  Re profile and revalidate the cleaned dataset.
7.  Demonstrate responsible use of AI as a development accelerator rather than as an autonomous decision maker.

The overall workflow is:

``` text
Raw Ingestion
      ↓
Data Profiling
      ↓
Data Quality Assessment
      ↓
Rulebook Development
      ↓
Data Cleaning
      ↓
Exception Management
      ↓
Post-Clean Validation
      ↓
Quality Scorecard
      ↓
Reporting
```

------------------------------------------------------------------------

# 4. Project Architecture

The database follows the **Medallion Architecture**.

``` text
                         ┌───────────────────────┐
                         │     NYC Open Data     │
                         │       311 CSV         │
                         └───────────┬───────────┘
                                     │
                                     ▼
                    ┌────────────────────────────┐
                    │          BRONZE            │
                    │                            │
                    │ Raw ingestion              │
                    │ VARCHAR based source data  │
                    └─────────────┬──────────────┘
                                  │
                                  ▼
                    ┌────────────────────────────┐
                    │       DATA PROFILING       │
                    │                            │
                    │ Completeness               │
                    │ Uniqueness                 │
                    │ Validity                   │
                    │ Consistency                │
                    │ Timeliness                 │
                    └─────────────┬──────────────┘
                                  │
                                  ▼
                    ┌────────────────────────────┐
                    │      DATA QUALITY          │
                    │        RULEBOOK            │
                    │                            │
                    │ Business rules             │
                    │ Validation logic           │
                    │ Severity classification    │
                    └─────────────┬──────────────┘
                                  │
                                  ▼
                    ┌────────────────────────────┐
                    │          SILVER            │
                    │                            │
                    │ Duplicate removal          │
                    │ Date validation            │
                    │ Status reconciliation      │
                    │ Geographic validation      │
                    │ Standardization            │
                    │ ZIP validation             │
                    │ Datatype enforcement       │
                    └─────────────┬──────────────┘
                                  │
                       ┌──────────┴──────────┐
                       ▼                     ▼
             ┌──────────────────┐  ┌──────────────────┐
             │ EXCEPTION TABLE  │  │ POST CLEAN       │
             │                  │  │ VALIDATION       │
             │ unique_key       │  │                  │
             │ exception reason │  │ Rule retesting   │
             │ timestamp        │  │ Profiling        │
             └──────────────────┘  └────────┬─────────┘
                                             │
                                             ▼
                              ┌────────────────────────┐
                              │          GOLD          │
                              │                        │
                              │ Production Ready       │
                              │ Dataset                │
                              └────────────┬───────────┘
                                           │
                                           ▼
                              ┌────────────────────────┐
                              │   QUALITY SCORECARD    │
                              │                        │
                              │ Completeness           │
                              │ Uniqueness             │
                              │ Validity               │
                              │ Timeliness             │
                              └────────────────────────┘
```

<img src="07_readme_images/medallion_architecture.png" />
Image Source: dataforgelabs.com

------------------------------------------------------------------------

# 5. Bronze Layer - Raw Data Ingestion

The Bronze layer preserves the source data in an ingestion oriented structure. All source columns initially enter as `VARCHAR`, allowing the raw ingestion layer to accept the source file before analytical datatype enforcement.

### Bronze Layer - Raw Data schema
```text

  Column           Raw Type
  ---------------- --------------
  unique_key       VARCHAR(30)
  created_date     VARCHAR(30)
  closed_date      VARCHAR(30)
  agency           VARCHAR(30)
  complaint_type   VARCHAR(100)
  incident_zip     VARCHAR(10)
  city             VARCHAR(30)
  status           VARCHAR(30)
  due_date         VARCHAR(30)
  borough          VARCHAR(30)
  latitude         VARCHAR(30)
  longitude        VARCHAR(30)
```

The raw data was loaded using SQL Server using `BULK INSERT`.

### Ingestion considerations

The ingestion process required handling:

-   CSV parsing
-   Header exclusion
-   Field termination
-   Row termination
-   Raw datatype sizing
-   Large volume loading

AI assisted with troubleshooting issues including row terminators, insufficient `VARCHAR` lengths and bulk load failures. Implementation and validation remained analyst controlled.

------------------------------------------------------------------------

# 6. Initial Data Profiling

Profiling was performed before transformation so remediation decisions were based on observed data quality problems rather than assumptions. The profiling framework assessed:

### Completeness

-   NULL counts
-   Missing value percentages
-   Important vs optional attributes

### Uniqueness

-   Exact duplicate records
-   Duplicate rates
-   Uniqueness with and without `unique_key`

### Validity

-   Date validity
-   ZIP code validity
-   Latitude bounds
-   Longitude bounds
-   Coordinate pair completeness

### Consistency

-   City variations
-   Borough variations
-   Complaint type variations
-   Status values
-   Agency values

### Timeliness

-   Future dates
-   Service request lifecycle sequence validity

------------------------------------------------------------------------

# 7. Raw Dataset Findings

The raw dataset contained:

-   **5,314,955 records**
-   **12 columns**
-   **100,984 exact duplicate rows** when `unique_key` was excluded from the duplicate comparison
-   **1.90% duplicate rate** under that comparison
-   **183,739 NULL `closed_date` values**
-   **45,981 NULL `incident_zip` values**
-   **239,099 NULL `city` values**
-   **96,369 NULL `latitude` values**
-   **96,369 NULL `longitude` values**
-   **5,293,055 NULL `due_date` values**
-   **240 city values**
-   **194 complaint type values**
-   **383 ZIP code values**
-   **7 status values**
-   **16 agency values**

The findings show that the raw dataset contained more than formatting inconsistencies. It contained structural problems involving duplicates, temporal integrity, workflow status inconsistency, geographic incompleteness, and non standardized reference values.

------------------------------------------------------------------------

# 8. Data Quality Rulebook

Instead of writing isolated cleaning queries, the project formalized expected data behavior into a **Data Quality Rulebook**. Rules were classified as:
```text
-   Critical        integrity, identification and core business process issues
-   High            analytical, geographic and operational issues
-   Medium          consistency and standardization issues
-   Low             presentation/reporting issues
```
---
## Rule Catalogue
```text
  Rule     Description                                 Severity
  -------- ------------------------------------------- ----------
  DQ-001   Unique service request identifier           Critical
  DQ-002   Created date mandatory                      Critical
  DQ-003   Valid datetime format                       Critical
  DQ-004   Closed date ≥ created date                  Critical
  DQ-005   Due date ≥ created date                     High
  DQ-006   No future dates                             High
  DQ-007   Closed requests require closed date         Critical
  DQ-008   Open requests should not have closed date   High
  DQ-009   Latitude validity                           High
  DQ-010   Longitude validity                          High
  DQ-011   Coordinate pair completeness                High
  DQ-012   Borough standardization                     Medium
  DQ-013   City standardization                        Medium
  DQ-014   Complaint type standardization              Medium
  DQ-015   Blank string validation                     Medium
  DQ-016   Leading/trailing whitespace                 Low
  DQ-017   Complaint type mandatory                    High
  DQ-018   Agency mandatory                            High
  DQ-019   ZIP code format validation                  Medium
  DQ-020   Geographic consistency                      High
```
---

# 9. Data Cleaning & Remediation

The Silver layer contains the primary remediation workflow.

## 9.1 Duplicate Removal

Duplicate detection excludes `unique_key` from the business attribute comparison. Where duplicate records existed, the most recent record was retained.

### Result

**100,984 duplicate records were removed.**

---

# 10. Temporal Validation

Several temporal integrity rules were applied.

### Created date must not exceed closed date

``` text
created_date <= closed_date
```

### Created date must not exceed due date

``` text
created_date <= due_date
```

### Future dates

Future dated records were identified against the project's reference date.

### Results
```text
  Validation                       Before   After
  ------------------------------ -------- -------
  created_date > closed_date        1,097       0
  Future date violations              706       0
```
------------------------------------------------------------------------

# 11. Status Reconciliation

The dataset contained inconsistencies between workflow status and closure timestamps.

### Reconciliation rule

If:

``` text
closed_date IS NOT NULL
AND status <> 'Closed'
```

then:

``` text
status = 'Closed'
```

This reconciles workflow status with closure information.

### Impact

**20,672 status values were corrected.**

A separate lifecycle violation occurred when:

``` text
status = 'Closed'
AND closed_date IS NULL
```

These records were removed from the analytical layer.

### Impact

**6,039 closed status violations were removed.**

------------------------------------------------------------------------

# 12. Geographic Data Validation

Geographic quality was treated as more than simply checking whether coordinates were populated.

### Latitude

``` text
-90 <= latitude <= 90
```

### Longitude

``` text
-180 <= longitude <= 180
```

### Coordinate pair completeness

Latitude and longitude should either:

``` text
both be NULL
```

or:

``` text
both be populated
```

The raw data contained:

-   **823 latitude only records**
-   **217 longitude only records**

For a total of: **1,040 coordinate pair violations.**

After remediation: **0 coordinate pair violations remained.**

------------------------------------------------------------------------

# 13. Categorical Standardization

Reference mapping tables were used to standardize categorical attributes. This prevents analytical fragmentation caused by variations in capitalization, spelling, punctuation or naming.

## Borough Standardization

Examples:

``` text
MANHATTAN      → Manhattan
QUEENS         → Queens
BRONX          → Bronx
```

The final standardized borough set contains six approved values.

## City Standardization

The raw dataset contained: **240 distinct city values**

which were standardized to: **159 values**

Examples include:

``` text
NYC
New York
NY
Ny
ny

 ↓

New York City
```

Other spelling and casing variations were consolidated using the mapping table.

## Complaint Type Standardization

Complaint categories were standardized while preserving business meaning.

Examples:

``` text
HEAT/HOT WATER        → Heat/Hot Water
PLUMBING, Plumbing    → Plumbing
SAFETY, Safety        → Safety
```

Distinct complaint type values were reduced: **194 → 189**

------------------------------------------------------------------------

# 14. ZIP Code Validation

Non NULL ZIP codes were required to contain five numeric digits. Invalid non NULL ZIP values were removed.

### Result

**5 invalid ZIP code records removed** and **0 invalid non NULL ZIP code failures remained after validation.** NULL ZIP values were preserved rather than automatically imputed.

------------------------------------------------------------------------

# 15. Data Type Enforcement

The ingestion layer deliberately used VARCHAR based storage. After validation and cleaning, fields were converted into analytical datatypes.

### Production datatype examples
```text
  Column           Production Type
  ---------------- -----------------
  unique_key       INT
  created_date     DATETIME
  closed_date      DATETIME
  agency           VARCHAR(10)
  complaint_type   VARCHAR(40)
  incident_zip     INT
  city             VARCHAR(30)
  status           VARCHAR(12)
  borough          VARCHAR(14)
  latitude         DECIMAL(15,11)
  longitude        DECIMAL(15,11)
```
------------------------------------------------------------------------

# 16. Due Date Column Rationalization

The raw dataset contained a `due_date` column but: **5,293,055 of 5,314,955 records were NULL.**

Because the field had extremely limited population and limited analytical value, it was removed from the production analytical layer.

This reduced the final schema from: **12 → 11 columns**

------------------------------------------------------------------------

# 17. Exception Management

A central design principle of the project was:

> **Do not silently delete bad records.**

Records affected by remediation were logged in an exception table.

The exception record contains information such as:
```text
  Field          Purpose
  -------------- ---------------------------------------
  `unique_key`   Identifies the affected record
  `exception`    Reason for remediation
  `time_stamp`   Records when the exception was logged
```

Examples include:

``` text
duplicate
created_date > closed_date
created_date > due_date
closed_date > 2026-06-03
```

This provides traceability between the raw Bronze layer and records removed from the analytical layer.

``` text
Bronze
   │
   ├───────────────► Silver / Gold
   │
   └───────────────► Exception Table
```

------------------------------------------------------------------------

# 18. Cleaning Impact Analysis

<img src="07_readme_images/cleaning_impact_analysis.png" />

---

### Important interpretation

These figures represent **records affected by individual remediation activities**. They should **not** be mechanically summed because the same record can potentially be affected by multiple rules during the workflow. 

The authoritative net result is: **108,171 records removed / quarantined** from the raw population of 5,314,955, leaving **5,206,784 clean analytical records.**

------------------------------------------------------------------------

# 19. Before vs After

```text
  Metric                          Raw       Clean
  ----------------------- ----------- -----------
  Records                   5,314,955   5,206,784
  Columns                          12          11
  Duplicate rows              100,984           0
  City values                     240         159
  Complaint-type values           194         189
```

------------------------------------------------------------------------

# 20. Data Quality Scorecard

<img src="07_readme_images/data_quality_scorecard.png" />

### Interpretation

**Completeness**

Remained essentially stable because missing values were preserved rather than blindly imputed.

**Uniqueness**

Improved from **98.10% → 100.00%** through duplicate elimination.

**Validity**

Improved from **99.83% → 100.00%** through rule based remediation.

**Timeliness**

Improved from **99.99% → 100.00%** through future date validation.

------------------------------------------------------------------------

# 21. Post Clean Rule Validation

Cleaning was not considered complete simply because transformation queries executed successfully. The rules were reexecuted against the cleaned dataset.

### Key validation results

<img src="07_readme_images/rule_validation_report.png" />

The supplied validation report therefore demonstrates successful post clean validation for the implemented rules shown in that report.

------------------------------------------------------------------------

# 22. Raw vs Cleaned Profiling

The project retains both profiling stages.

### Raw profiling

The raw dataset showed:

-   5,314,955 records
-   12 columns
-   1.90% exact duplicate rate when excluding `unique_key`
-   240 city values
-   194 complaint-type values
-   Multiple validation issues

### Clean profiling

The cleaned dataset contains:

-   5,206,784 records
-   11 production columns
-   0 exact duplicate rows
-   159 city values
-   189 complaint-type values
-   0 failures for the implemented post-clean validation checks

------------------------------------------------------------------------

# 23. SQL Engineering Techniques Demonstrated

### Database and Architecture

``` sql
CREATE DATABASE
CREATE SCHEMA
CREATE TABLE
SELECT INTO
```

### Data Ingestion

``` sql
BULK INSERT
```

### Data Profiling

``` sql
COUNT
COUNT(DISTINCT ...)
SUM
CASE
MIN
MAX
GROUP BY
```

### Duplicate Detection

``` sql
ROW_NUMBER() OVER (
    PARTITION BY ...
    ORDER BY ...
)
```

### Data Validation

``` sql
CAST
TRIM
LIKE
BETWEEN
IS NULL
IS NOT NULL
```

### Data Transformation

``` sql
CASE
UPDATE
DELETE
ALTER TABLE
ALTER COLUMN
DROP COLUMN
```

### Metadata & Profiling

``` sql
sys.columns
OBJECT_ID
sp_help
sp_spaceused
```

### Production Table Design

``` sql
PRIMARY KEY
NOT NULL
DECIMAL
DATETIME
INT
VARCHAR
```

------------------------------------------------------------------------

# 24. SQL Pipeline

The SQL scripts are organized sequentially so the repository can be understood as a complete workflow.

``` text
01  Create Project Database
        ↓
02  Create Medallion Architecture Schema
        ↓
03  Create Bronze Layer Raw Data Table
        ↓
04  Raw Data Profiling
        ↓
05  Create Silver Layer Data Table
        ↓
06  Clean Silver Layer Data
        ↓
07  Create Gold Layer Production Table
        ↓
08  Load Cleaned Silver Layer Data to Gold Layer
        ↓
09  Cleaned Data Profiling
```

### Script Map

```text
  -------------------------------------------------------------------------------------------
  Sl No.   Exact File Name                                            Purpose
  -------- ---------------------------------------------------------- -----------------------
  01       01_Create_Project_Database.sql                             Creates project
                                                                      database

  02       02_Create_Medallion_Architecture_schema.sql                Creates Bronze, Silver
                                                                      and Gold schemas

  03       03_Create_Bronze_Layer_Raw_Data_Table.sql                  Creates and loads raw
                                                                      table

  04       04_Raw_Data_Profiling.sql                                  Profiles raw dataset

  05       05_Create_Silver_Layer_Data_Table.sql                      Creates Silver layer
                                                                      and exception table

  06       06_Clean_Silver_Layer_Data.sql                             Executes remediation

  07       07_Create_Gold_Layer_Production_Table.sql                  Creates production
                                                                      analytical table

  08       08_Load_Cleaned_Silver_Layer_Data_to_Gold_Layer.sql        Loads validated data
                                                                      into Gold

  09       09_Cleaned_Data_Profiling.sql                              Profiles the final
                                                                      dataset
  -------------------------------------------------------------------------------------------
```

------------------------------------------------------------------------

# 25. Responsible AI Augmentation

AI was used as a **technical productivity tool**, and not as an autonomous data decision maker.

### AI assisted activities

-   Project planning
-   Workflow design
-   Bronze/Silver/Gold architecture design
-   SQL script generation
-   Bulk insert troubleshooting
-   Profiling workflow generation
-   NULL analysis query generation
-   Standardization mapping assistance
-   Rulebook drafting
-   Validation framework development
-   Cleaning impact analysis
-   Documentation

### Human controlled activities

The analyst retained ownership of:

-   Dataset selection
-   Profiling execution
-   Interpretation of profiling results
-   Remediation decisions
-   Cleaning decisions
-   Exception handling
-   Validation
-   Data quality scoring
-   Final conclusions

No raw operational records were submitted for automated AI analysis.

### Responsible AI workflow

``` text
AI Assistance
      ↓
Draft / Accelerate
      ↓
Human Review
      ↓
SQL Execution
      ↓
Validation
      ↓
Approved Output
```

The objective was to use AI to make development efforts more efficient without delegating data quality judgment to the model.

------------------------------------------------------------------------

# 26. Data Dictionary

The production data dictionary defines the transition from ingestion oriented types to analytical types.

<img src = "07_readme_images/data_dictionary.png" />

`due_date` is subsequently excluded from the production analytical layer because of insufficient population and limited analytical value.

------------------------------------------------------------------------

# 27. Standardization Mapping Tables

The project uses explicit mapping artifacts rather than hiding standardization logic inside large SQL expressions.

### City mapping

**Source artifact:** `04_Mapping_Table\01_Mapping_Table_Column_city.pdf`

The mapping consolidates variations such as:

``` text
NYC
NY
New York
Ny
ny

→ New York City
```

### Borough mapping

**Source artifact:** `04_Mapping_Table\02_Mapping_Table_Column_borough.pdf`

The approved standardized values are:

``` text
Bronx
Brooklyn
Manhattan
Queens
Staten Island
```

plus the sixth standardized borough value represented in the source mapping.

### Complaint-type mapping

**Source artifact:** `04_Mapping_Table\03_Mapping_Table_Column_complaint_type.pdf`

Examples include:

``` text
HEAT/HOT WATER
→ Heat/Hot Water

PLUMBING, Plumbing
→ Plumbing

SAFETY, Safety
→ Safety
```
------------------------------------------------------------------------

# 28. Cleaning Methodology

The cleaning workflow was derived from the profiling results and the Data Quality Rulebook.

### Core remediation sequence

``` text
Duplicate Removal
       ↓
Invalid Date Sequence Removal
       ↓
Future Date Validation
       ↓
Status Reconciliation
       ↓
Closed Status Validation
       ↓
City Standardization
       ↓
Borough Standardization
       ↓
Complaint Type Standardization
       ↓
ZIP Code Validation
       ↓
Datatype Conversion
       ↓
Duplicate Revalidation
       ↓
Schema Rationalization
       ↓
Post Transformation Validation
```

The workflow intentionally performs validation again after transformation rather than treating successful SQL execution as proof of data quality.

------------------------------------------------------------------------

# 29. Key Data Engineering Lessons

## 1. Profile Before Cleaning

Cleaning decisions should come from evidence. Profiling identifies where the dataset actually fails before transformation logic is written.

## 2. Convert Quality Expectations into Explicit Rules

A Data Quality Rulebook turns "**The data should be clean**" into testable conditions such as:

``` text
closed_date >= created_date
```

or:

``` text
latitude and longitude must exist together
```

This makes quality measurable and repeatable.

## 3. Separate Remediation from Validation

A successful `UPDATE` or `DELETE` does not prove that the data is correct. The rule must be executed again after remediation.

## 4. Preserve an Audit Trail

Removing a record without recording why it was removed creates a governance problem. The exception table provides a traceability mechanism.

## 5. Standardization Requires Reference Logic

Generic functions such as `UPPER()` and `LOWER()` do not necessarily resolve business level variations.

Reference mappings are required where different source values represent the same analytical category.

## 6. Missing Does Not Automatically Mean Wrong

The objective is not: "**Make every cell non NULL**"

The objective is: "**Make every value fit its defined business and analytical rules**

## 7. Schema Design Should Reflect Analytical Use

The production schema does not mirror the source schema. The `due_date` field was removed from the analytical layer because of its extremely limited population and limited analytical value.

------------------------------------------------------------------------

# 30. Final Project Outcome

The project transformed a large operational dataset into a structured analytical layer through:

``` text
Profiling
    ↓
Rule Definition
    ↓
Remediation
    ↓
Exception Logging
    ↓
Standardization
    ↓
Datatype Enforcement
    ↓
Validation
    ↓
Quality Scoring
```

### Final state

-   **5.3M+ raw service request records assessed**
-   **5,206,784 records retained in the analytical layer**
-   **108,171 records removed / quarantined**
-   **100,984 duplicate records identified and removed**
-   **26,711 status inconsistencies addressed**
-   **1,097 invalid date sequences removed**
-   **706 future date records removed**
-   **1,040 coordinate pair violations resolved**
-   **5 invalid ZIP codes removed**
-   **City values reduced from 240 → 159**
-   **Complaint type values reduced from 194 → 189**
-   **0 duplicate failures after cleaning**
-   **0 date sequence failures after cleaning**
-   **0 status consistency failures after cleaning**
-   **0 coordinate integrity failures after cleaning**
-   **0 invalid ZIP code failures after cleaning**
-   **100% uniqueness**
-   **100% validity**
-   **100% timeliness**

------------------------------------------------------------------------

# 31. Portfolio Evidence

## 31.1 Data Quality Scorecard

<img src = "07_readme_images/data_quality_scorecard.png" />

## 31.2 Cleaning Impact Analysis

<img src = "07_readme_images/cleaning_impact_analysis.png" />

## 31.3 Rule Validation Report

<img src = "07_readme_images/rule_validation_report.png" />

## 31.4 Raw Data Profile

<img src = "07_readme_images/data_profile_raw_1.png" />
<img src = "07_readme_images/data_profile_raw_2.png" />
<img src = "07_readme_images/data_profile_raw_3.png" />
<img src = "07_readme_images/data_profile_raw_4.png" />
<img src = "07_readme_images/data_profile_raw_5.png" />
<img src = "07_readme_images/data_profile_raw_6.png" />
<img src = "07_readme_images/data_profile_raw_7.png" />

## 31.5 Cleaned Data Profile

<img src = "07_readme_images/data_profile_cleaned_1.png" />
<img src = "07_readme_images/data_profile_cleaned_2.png" />
<img src = "07_readme_images/data_profile_cleaned_3.png" />
<img src = "07_readme_images/data_profile_cleaned_4.png" />
<img src = "07_readme_images/data_profile_cleaned_5.png" />
<img src = "07_readme_images/data_profile_cleaned_6.png" />
<img src = "07_readme_images/data_profile_cleaned_7.png" />

## 31.6 Cleaning Methodology

<img src = "07_readme_images/data_cleaning_methodology_1.png" />
<img src = "07_readme_images/data_cleaning_methodology_2.png" />
<img src = "07_readme_images/data_cleaning_methodology_3.png" />

## 31.7 Responsible AI Augmentation

<img src = "07_readme_images/ai_augmentation_1.png" />
<img src = "07_readme_images/ai_augmentation_2.png" />

------------------------------------------------------------------------

# 33. Documentation Inventory

The complete supporting documentation consists of the following exact files:

```text
  --------------------------------------------------------------------------------------------------
  Artifact                            Directory
  ----------------------------------- --------------------------------------------------------------
  Raw Data Profile                    02_Data_Profile\01_Data_Profile_Raw.pdf

  Cleaned Data Profile                02_Data_Profile\02_Data_Profile_Cleaned.pdf

  Data Quality Rulebook               03_Rule_Book\01_Data_Quality_Rulebook.pdf

  Data Dictionary                     03_Rule_Book\02_Data_Dictionary.pdf

  City Mapping                        04_Mapping_Table\01_Mapping_Table_Column_city.pdf

  Borough Mapping                     04_Mapping_Table\02_Mapping_Table_Column_borough.pdf

  Complaint Type Mapping              04_Mapping_Table\03_Mapping_Table_Column_complaint_type.pdf

  Rule Validation Report              06_Data_Quality_Reports\01_Rule_Validation_Report.pdf

  Cleaning Impact Analysis            06_Data_Quality_Reports\02_Cleaning_Impact_Analysis.pdf

  AI Augmentation Report              06_Data_Quality_Reports\03_AI_Augmentation_Report.pdf

  Cleaning Methodology Report         06_Data_Quality_Reports\04_Cleaning_Methodology_Report.pdf

  Data Quality Scorecard              06_Data_Quality_Reports\05_Data_Quality_Scorecard.pdf

  Executive Summary & Report          06_Data_Quality_Reports\06_Executive_Summary_and_Report.pdf
  --------------------------------------------------------------------------------------------------
```

------------------------------------------------------------------------

# 34. How to Reproduce the Project

## Prerequisites

-   Microsoft SQL Server
-   SQL Server Management Studio or compatible SQL client
-   NYC 311 source CSV
-   Sufficient storage for 5M+ records

## Execution Order

Run the SQL scripts sequentially:

``` text
01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09
```

## Pipeline

``` text
Create database
      ↓
Create schemas
      ↓
Load raw data
      ↓
Profile raw data
      ↓
Create Silver layer
      ↓
Apply remediation
      ↓
Log exceptions
      ↓
Create Gold table
      ↓
Load validated records
      ↓
Profile final dataset
      ↓
Validate quality
```

------------------------------------------------------------------------

# 35. Future Improvements

The current implementation is a manually executed SQL workflow.

A production enterprise implementation could extend it with:

1.   Automated rule execution pipelines
2.   Scheduled data quality monitoring
3.   Data observability metrics
4.   Automated exception reporting
5.   Geographic reference data validation
6.   Incremental quality monitoring
7.   Historical quality trend tracking
8.   CI/CD validation of SQL transformations
9.   Enterprise data governance integration
10.   Automated alerts when quality thresholds are breached

These improvements would evolve the project from a one time remediation workflow into a continuously monitored data quality workflow.

------------------------------------------------------------------------

# 36. What This Project Demonstrates

### SQL Development

-   Complex SQL Server transformations
-   CTEs and window functions
-   Views
-   Conditional logic
-   Metadata queries
-   Data type conversion
-   Bulk ingestion
-   DDL and DML

### Data Quality

-   Profiling
-   Rule definition
-   Data validation
-   Remediation
-   Standardization
-   Duplicate management
-   Exception management
-   Quality scoring

### Data Engineering

-   Medallion architecture
-   Bronze / Silver / Gold separation
-   Raw to production data flow
-   Analytical schema design
-   Production datatype enforcement

### Data Governance

-   Data quality rules
-   Severity classification
-   Exception logging
-   Traceability
-   Human oversight
-   Reproducibility

### Responsible AI

-   AI assisted SQL development
-   AI assisted troubleshooting
-   AI assisted documentation
-   Human validation and accountability
-   No autonomous analytical decision making

------------------------------------------------------------------------

# 37. Portfolio Takeaway

> **Data quality should be measurable, rule driven, repeatable, auditable and validated after remediation.**

The workflow moves from:

``` text
Raw Operational Data
        ↓
Profiled Data
        ↓
Rule-Defined Data Quality
        ↓
Remediated Data
        ↓
Validated Analytical Data
```

while preserving an exception trail for records affected by remediation.

That makes the methodology applicable beyond NYC 311 to domains such as:

-   Healthcare
-   Banking
-   Insurance
-   Retail
-   Logistics
-   Government
-   Customer operations
-   Financial reporting
-   Enterprise data platforms

------------------------------------------------------------------------

# Technology Stack

`Microsoft SQL Server` · `T-SQL` · `SQL Server Management Studio` · `Data Quality Engineering` · `Data Profiling` · `Medallion Architecture` · `Responsible AI`

------------------------------------------------------------------------
