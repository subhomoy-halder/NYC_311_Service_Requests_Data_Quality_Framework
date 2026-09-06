# Enterprise Data Quality Assessment & Remediation for NYC 311 Service Requests

### SQL-Driven Data Cleaning & Quality Engineering Project with Responsible AI Augmentation

> **A production-style SQL Server data-quality pipeline that profiles,
> validates, remediates, standardizes, and audits 5.3M+ NYC 311
> service-request records before analytical consumption.**

------------------------------------------------------------------------

## Executive Summary

Operational datasets are rarely analysis-ready when they arrive.

This project demonstrates how a large operational dataset can be
transformed into a structured, validated analytical dataset using a
**rule-driven data quality framework** rather than ad-hoc cleaning.

Using the **NYC 311 Service Requests** dataset, I designed and
implemented an end-to-end data quality workflow in **Microsoft SQL
Server** covering:

-   Raw data ingestion
-   Bronze / Silver / Gold data architecture
-   Data profiling
-   NULL and completeness analysis
-   Duplicate detection
-   Cardinality analysis
-   Temporal validation
-   Geographic validation
-   Categorical consistency analysis
-   Formal Data Quality Rulebook
-   Rule-based remediation
-   Reference-data standardization
-   Exception management
-   Data-type enforcement
-   Post-clean validation
-   Data quality scorecard
-   Cleaning impact analysis
-   Responsible AI-assisted development

The result was a cleaned analytical dataset containing **5,206,784
records across 11 production columns**, compared with **5,314,955 raw
records across 12 columns**.

------------------------------------------------------------------------

# 1. Project at a Glance

  -----------------------------------------------------------------------
  Area                                Details
  ----------------------------------- -----------------------------------
  **Project Type**                    Data Quality Engineering / SQL Data
                                      Cleaning

  **Dataset**                         NYC 311 Service Requests

  **Source**                          NYC Open Data

  **Raw Records**                     5,314,955

  **Clean Records**                   5,206,784

  **Records Removed / Quarantined**   108,171

  **Raw Columns**                     12

  **Production Columns**              11

  **Database**                        Microsoft SQL Server

  **Architecture**                    Bronze → Silver → Gold

  **Primary Language**                T-SQL

  **Validation Framework**            Rule-based Data Quality Rulebook

  **Quality Dimensions**              Completeness, Uniqueness, Validity,
                                      Timeliness

  **AI Usage**                        Development assistance with
                                      analyst-controlled validation
  -----------------------------------------------------------------------

**Dataset coverage:** 2025-01-01 to 2026-06-01.

------------------------------------------------------------------------

# 2. Business Problem

NYC 311 is a large operational service-request system containing
information about citizen complaints, responsible agencies, request
status, timestamps, locations, and complaint classifications.

At this scale, data-quality problems can affect:

-   Operational reporting
-   Service-request volumes
-   Geographic analysis
-   Complaint categorization
-   Resolution-time analysis
-   Agency performance reporting
-   Downstream dashboards
-   Analytical models

The project therefore treats data quality as a **formal engineering
problem**, not simply as a preprocessing step.

### Core question

> **How can a large operational dataset be systematically assessed,
> remediated, validated, and made trustworthy for analytical consumption
> while preserving traceability of the changes made?**

------------------------------------------------------------------------

# 3. Project Objectives

The project was designed around seven objectives:

1.  Assess the quality of the raw dataset through systematic profiling.
2.  Identify quality problems across multiple dimensions.
3.  Translate identified issues into explicit business and technical
    rules.
4.  Remediate data using reproducible SQL logic.
5.  Preserve traceability of records removed or modified.
6.  Re-profile and revalidate the cleaned dataset.
7.  Demonstrate responsible use of AI as a development accelerator
    rather than as an autonomous decision-maker.

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

The database follows a **Medallion-style architecture**.

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
                    │ VARCHAR-based source data  │
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
                    │ Date validation             │
                    │ Status reconciliation      │
                    │ Geographic validation      │
                    │ Standardization             │
                    │ ZIP validation              │
                    │ Datatype enforcement       │
                    └─────────────┬──────────────┘
                                  │
                       ┌──────────┴──────────┐
                       ▼                     ▼
             ┌──────────────────┐  ┌──────────────────┐
             │ EXCEPTION TABLE  │  │ POST-CLEAN       │
             │                  │  │ VALIDATION       │
             │ unique_key       │  │                  │
             │ exception reason │  │ Rule re-testing  │
             │ timestamp        │  │ Profiling        │
             └──────────────────┘  └────────┬─────────┘
                                             │
                                             ▼
                              ┌────────────────────────┐
                              │          GOLD          │
                              │                        │
                              │ Production Analytical  │
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

```{=html}
<!-- IMAGE PLACEHOLDER
Suggested filename: architecture.png

Insert an exported/high-resolution image of the architecture above here:
![Project Architecture](docs/images/architecture.png)
-->
```

------------------------------------------------------------------------

# 5. Bronze Layer --- Raw Data Ingestion

The Bronze layer preserves the source data in an ingestion-oriented
structure.

All source columns initially enter as `VARCHAR`, allowing the raw
ingestion layer to accept the source file before analytical datatype
enforcement.

### Raw table

``` text
bronze.NYC_Service_Requests_raw
```

### Raw schema

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

The raw data was loaded using SQL Server `BULK INSERT`.

### Ingestion considerations

The ingestion process required handling:

-   CSV parsing
-   Header exclusion
-   Field termination
-   Row termination
-   Raw datatype sizing
-   Large-volume loading

AI assisted with troubleshooting issues including row terminators,
insufficient `VARCHAR` lengths, and bulk-load failures. Implementation
and validation remained analyst-controlled.

------------------------------------------------------------------------

# 6. Initial Data Profiling

Profiling was performed **before transformation** so remediation
decisions were based on observed data-quality problems rather than
assumptions.

The profiling framework assessed:

### Completeness

-   NULL counts
-   Missing-value percentages
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
-   Coordinate-pair completeness

### Consistency

-   City variations
-   Borough variations
-   Complaint-type variations
-   Status values
-   Agency values

### Timeliness

-   Future dates
-   Service-request lifecycle sequence validity

------------------------------------------------------------------------

# 7. Raw Dataset Findings

The raw dataset contained:

-   **5,314,955 records**
-   **12 columns**
-   **100,984 exact duplicate rows** when `unique_key` was excluded from
    the duplicate comparison
-   **1.90% duplicate rate** under that comparison
-   **183,739 NULL `closed_date` values**
-   **45,981 NULL `incident_zip` values**
-   **239,099 NULL `city` values**
-   **96,369 NULL `latitude` values**
-   **96,369 NULL `longitude` values**
-   **5,293,055 NULL `due_date` values**
-   **240 city values**
-   **194 complaint-type values**
-   **383 ZIP-code values**
-   **7 status values**
-   **16 agency values**

The important finding is that the raw dataset contained more than
formatting inconsistencies. It contained structural problems involving
duplication, temporal integrity, workflow-status consistency, geographic
completeness, and reference-value standardization.

------------------------------------------------------------------------

# 8. Data Quality Rulebook

Instead of writing isolated cleaning queries, the project formalized
expected data behavior into a **Data Quality Rulebook**.

Rules were classified as:

-   **Critical** --- integrity, identification, and core
    business-process issues
-   **High** --- analytical, geographic, and operational issues
-   **Medium** --- consistency and standardization issues
-   **Low** --- presentation/reporting issues

## Rule Catalogue

  Rule     Description                                 Severity
  -------- ------------------------------------------- ----------
  DQ-001   Unique service-request identifier           Critical
  DQ-002   Created date mandatory                      Critical
  DQ-003   Valid datetime format                       Critical
  DQ-004   Closed date ≥ created date                  Critical
  DQ-005   Due date ≥ created date                     High
  DQ-006   No future dates                             High
  DQ-007   Closed requests require closed date         Critical
  DQ-008   Open requests should not have closed date   High
  DQ-009   Latitude validity                           High
  DQ-010   Longitude validity                          High
  DQ-011   Coordinate-pair completeness                High
  DQ-012   Borough standardization                     Medium
  DQ-013   City standardization                        Medium
  DQ-014   Complaint-type standardization              Medium
  DQ-015   Blank-string validation                     Medium
  DQ-016   Leading/trailing whitespace                 Low
  DQ-017   Complaint type mandatory                    High
  DQ-018   Agency mandatory                            High
  DQ-019   ZIP-code format validation                  Medium
  DQ-020   Geographic consistency                      High

### Rulebook design correction

The project artifacts define **20 rules**, including DQ-020 Geographic
Consistency. The supplied Rule Validation Report displays validation
results through **DQ-019**.

Therefore, this README does **not** claim that DQ-020 was successfully
executed in the supplied validation output.

For portfolio presentation, DQ-020 should either be:

1.  added to the final validation report with its actual result, or
2.  explicitly labelled as a defined rule pending implementation.

This distinction is intentional: the README should not overstate the
evidence.

------------------------------------------------------------------------

# 9. Data Cleaning & Remediation

The Silver layer contains the primary remediation workflow.

------------------------------------------------------------------------

## 9.1 Duplicate Removal

Duplicate detection excludes `unique_key` from the business-attribute
comparison.

Where duplicate records existed, the most recent record was retained.

### Result

**100,984 duplicate records were removed.**

------------------------------------------------------------------------

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

Future-dated records were identified against the project's reference
date.

### Results

  Validation                       Before   After
  ------------------------------ -------- -------
  `created_date > closed_date`      1,097       0
  Future-date violations              706       0

------------------------------------------------------------------------

# 11. Status Reconciliation

The dataset contained inconsistencies between workflow status and
closure timestamps.

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

**6,039 closed-status violations were removed.**

### Combined status inconsistency result

**26,711 status inconsistencies**

→ **0 remaining validation failures**

------------------------------------------------------------------------

# 12. Geographic Data Validation

Geographic quality was treated as more than simply checking whether
coordinates were populated.

### Latitude

``` text
-90 <= latitude <= 90
```

### Longitude

``` text
-180 <= longitude <= 180
```

### Coordinate-pair completeness

Latitude and longitude should either:

``` text
both be NULL
```

or:

``` text
both be populated
```

The raw data contained:

-   **823 latitude-only records**
-   **217 longitude-only records**

for a total of:

**1,040 coordinate-pair violations.**

After remediation:

**0 coordinate-pair violations remained.**

------------------------------------------------------------------------

# 13. Categorical Standardization

Reference mapping tables were used to standardize categorical
attributes.

This prevents analytical fragmentation caused by variations in
capitalization, spelling, punctuation, or naming.

------------------------------------------------------------------------

## Borough Standardization

Examples:

``` text
MANHATTAN      → Manhattan
QUEENS         → Queens
BRONX          → Bronx
BROOKLYN       → Brooklyn
STATEN ISLAND  → Staten Island
```

The final standardized borough set contains six approved values.

------------------------------------------------------------------------

## City Standardization

The raw dataset contained:

**240 distinct city values**

which were standardized to:

**159 values**

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

Other spelling and casing variations were consolidated using the mapping
table.

------------------------------------------------------------------------

## Complaint-Type Standardization

Complaint categories were standardized while preserving business
meaning.

Examples:

``` text
HEAT/HOT WATER        → Heat/Hot Water
PLUMBING, Plumbing    → Plumbing
SAFETY, Safety        → Safety
PAINT/PLASTER         → Paint/Plaster
DOOR/WINDOW           → Door/Window
```

Distinct complaint-type values were reduced:

**194 → 189**

------------------------------------------------------------------------

# 14. ZIP Code Validation

Non-NULL ZIP codes were required to contain five numeric digits.

Invalid non-NULL ZIP values were removed.

### Result

**5 invalid ZIP-code records removed**

and:

**0 invalid non-NULL ZIP-code failures remained after validation.**

NULL ZIP values were preserved rather than automatically imputed.

------------------------------------------------------------------------

# 15. Data Type Enforcement

The ingestion layer deliberately used VARCHAR-based storage.

After validation and cleaning, fields were converted into analytical
datatypes.

### Production datatype examples

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

------------------------------------------------------------------------

# 16. Due-Date Column Rationalization

The raw dataset contained a `due_date` column, but:

**5,293,055 of 5,314,955 records were NULL.**

Because the field had extremely limited population and limited
analytical value, it was removed from the production analytical layer.

This reduced the final schema from:

**12 → 11 columns**

This is an example of schema rationalization based on data-quality
evidence rather than blindly preserving every source column.

------------------------------------------------------------------------

# 17. Exception Management

A central design principle of the project was:

> **Do not silently delete bad records.**

Records affected by remediation were logged in an exception table.

The exception record contains information such as:

  Field          Purpose
  -------------- ---------------------------------------
  `unique_key`   Identifies the affected record
  `exception`    Reason for remediation
  `time_stamp`   Records when the exception was logged

Examples include:

``` text
duplicate
created_date > closed_date
created_date > due_date
closed_date > 2026-06-03
Update status to Closed
Invalid Non NULL zip code
drop due_date
```

This provides traceability between the raw Bronze layer and records
removed from the analytical layer.

``` text
Bronze
   │
   ├───────────────► Silver / Gold
   │
   └───────────────► Exception Table
```

------------------------------------------------------------------------

# 18. Cleaning Impact Analysis

  Cleaning Action                        Records Affected
  ------------------------------------ ------------------
  Duplicate removal                               100,984
  Invalid date sequence removal                     1,097
  Future-date removal                                 706
  Status corrections                               20,672
  Closed-status violations removed                  6,039
  Coordinate-pair violations removed                1,040
  Invalid ZIP codes removed                             5
  Data-type conversion                     Entire dataset
  City standardization                   240 → 159 values
  Complaint-type standardization         194 → 189 values

### Important interpretation

These figures represent **records affected by individual remediation
activities**.

They should **not** be mechanically summed because the same record can
potentially be affected by multiple rules during the workflow.

The authoritative net result is:

**108,171 records removed / quarantined**

from the raw population of 5,314,955, leaving:

**5,206,784 clean analytical records.**

```{=html}
<!-- IMAGE PLACEHOLDER
Source artifact:
02_Cleaning_Impact_Analysis(1).pdf

Suggested repository image:
docs/images/cleaning_impact_analysis.png

Insert here:
![Cleaning Impact Analysis](docs/images/cleaning_impact_analysis.png)
-->
```

------------------------------------------------------------------------

# 19. Before vs After

  Metric                          Raw       Clean
  ----------------------- ----------- -----------
  Records                   5,314,955   5,206,784
  Columns                          12          11
  Duplicate rows              100,984           0
  City values                     240         159
  Complaint-type values           194         189

------------------------------------------------------------------------

# 20. Data Quality Scorecard

  Dimension        Raw Dataset   Clean Dataset
  -------------- ------------- ---------------
  Completeness          98.86%          98.88%
  Uniqueness            98.10%     **100.00%**
  Validity              99.83%     **100.00%**
  Timeliness            99.99%     **100.00%**

### Interpretation

**Completeness**

Remained essentially stable because missing values were preserved rather
than blindly imputed.

**Uniqueness**

Improved from **98.10% → 100.00%** through duplicate elimination.

**Validity**

Improved from **99.83% → 100.00%** through rule-based remediation.

**Timeliness**

Improved from **99.99% → 100.00%** through future-date validation.

```{=html}
<!-- IMAGE PLACEHOLDER
Source artifact:
05_Data_Quality_Scorecard(1).pdf

Suggested repository image:
docs/images/data_quality_scorecard.png

Insert here:
![Data Quality Scorecard](docs/images/data_quality_scorecard.png)
-->
```

------------------------------------------------------------------------

# 21. Post-Clean Rule Validation

Cleaning was not considered complete simply because transformation
queries executed successfully.

The rules were re-executed against the cleaned dataset.

### Key validation results

  Rule Area                           Before   After
  ----------------------- ------------------ -------
  Duplicate validation      100,984 failures   **0**
  Invalid date sequence       1,097 failures   **0**
  Status consistency         26,711 failures   **0**
  Coordinate integrity        1,040 failures   **0**
  ZIP validation                  5 failures   **0**

The supplied validation report therefore demonstrates successful
post-clean validation for the implemented rules shown in that report.

```{=html}
<!-- IMAGE PLACEHOLDER
Source artifact:
01_Rule_Validation_Report(1).pdf

Suggested repository image:
docs/images/rule_validation_report.png

Insert here:
![Rule Validation Report](docs/images/rule_validation_report.png)
-->
```

------------------------------------------------------------------------

# 22. Raw vs Cleaned Profiling

The project deliberately retains both profiling stages.

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

```{=html}
<!-- IMAGE PLACEHOLDER
Source artifact:
01_Data_Profile_Raw(1).pdf

Suggested repository image:
docs/images/raw_data_profile.png

Insert here:
![Raw Data Profile](docs/images/raw_data_profile.png)
-->
```
```{=html}
<!-- IMAGE PLACEHOLDER
Source artifact:
02_Data_Profile_Cleaned(1).pdf

Suggested repository image:
docs/images/cleaned_data_profile.png

Insert here:
![Cleaned Data Profile](docs/images/cleaned_data_profile.png)
-->
```

------------------------------------------------------------------------

# 23. SQL Engineering Techniques Demonstrated

### Database & Architecture

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

The SQL scripts are organized sequentially so the repository can be
understood as a complete workflow.

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

  ----------------------------------------------------------------------------------------------------------
  \#                      Exact File Name                                            Purpose
  ----------------------- ---------------------------------------------------------- -----------------------
  01                      `01_Create_Project_Database(1).sql`                        Creates project
                                                                                     database

  02                      `02_Create_Medallion_Architecture_schema(1).sql`           Creates Bronze, Silver
                                                                                     and Gold schemas

  03                      `03_Create_Bronze_Layer_Raw_Data_Table(1).sql`             Creates and loads raw
                                                                                     table

  04                      `04_Raw_Data_Profiling(1).sql`                             Profiles raw dataset

  05                      `05_Create_Silver_Layer_Data_Table(1).sql`                 Creates Silver layer
                                                                                     and exception table

  06                      `06_Clean_Silver_Layer_Data(2).sql`                        Executes remediation

  07                      `07_Create_Gold_Layer_Production_Table(1).sql`             Creates production
                                                                                     analytical table

  08                      `08_Load_Cleaned_Silver_Layer_Data_to_Gold_Layer(1).sql`   Loads validated data
                                                                                     into Gold

  09                      `09_Cleaned_Data_Profiling(1).sql`                         Profiles the final
                                                                                     dataset
  ----------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------

# 25. Responsible AI Augmentation

AI was used as a **technical productivity tool**, not as an autonomous
data-quality decision-maker.

### AI-assisted activities

-   Project planning
-   Workflow design
-   Bronze/Silver/Gold architecture design
-   SQL script generation
-   Bulk-insert troubleshooting
-   Profiling workflow generation
-   NULL-analysis query generation
-   Standardization mapping assistance
-   Rulebook drafting
-   Validation framework development
-   Cleaning-impact analysis
-   Documentation

### Human-controlled activities

The analyst retained ownership of:

-   Dataset selection
-   Profiling execution
-   Interpretation of profiling results
-   Remediation decisions
-   Cleaning decisions
-   Exception handling
-   Validation
-   Data-quality scoring
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

The objective was to use AI to reduce development effort without
delegating data-quality judgment to the model.

```{=html}
<!-- IMAGE PLACEHOLDER
Source artifact:
03_AI_Augmentation_Report(1).pdf

Suggested repository image:
docs/images/responsible_ai.png

Insert here:
![Responsible AI Workflow](docs/images/responsible_ai.png)
-->
```

------------------------------------------------------------------------

# 26. Data Dictionary

The production data dictionary defines the transition from
ingestion-oriented types to analytical types.

  ------------------------------------------------------------------------
  Column             Raw Type          Cleaned Type      Description
  ------------------ ----------------- ----------------- -----------------
  `unique_key`       VARCHAR(30)       INT               Unique identifier
                                                         for each service
                                                         request

  `created_date`     VARCHAR(30)       DATETIME          Date service
                                                         request is
                                                         created

  `closed_date`      VARCHAR(30)       DATETIME          Date service
                                                         request is closed

  `agency`           VARCHAR(30)       VARCHAR(10)       Service-request
                                                         corresponding
                                                         agency

  `complaint_type`   VARCHAR(100)      VARCHAR(40)       Type of incident

  `incident_zip`     VARCHAR(10)       INT               ZIP code of
                                                         incident

  `city`             VARCHAR(30)       VARCHAR(30)       City of incident

  `status`           VARCHAR(30)       VARCHAR(12)       Current status of
                                                         service request

  `due_date`         VARCHAR(30)       DATETIME          Resolution due
                                                         date in source
                                                         layer

  `borough`          VARCHAR(30)       VARCHAR(14)       Borough where
                                                         incident happened

  `latitude`         VARCHAR(30)       DECIMAL(15,11)    Latitude

  `longitude`        VARCHAR(30)       DECIMAL(15,11)    Longitude
  ------------------------------------------------------------------------

`due_date` is subsequently excluded from the production analytical layer
because of insufficient population and limited analytical value.

```{=html}
<!-- IMAGE PLACEHOLDER
Source artifact:
02_Data_Dictionary(1).pdf

Suggested repository image:
docs/images/data_dictionary.png

Insert here:
![Data Dictionary](docs/images/data_dictionary.png)
-->
```

------------------------------------------------------------------------

# 27. Standardization Mapping Tables

The project uses explicit mapping artifacts rather than hiding
standardization logic inside large SQL expressions.

### City mapping

**Source artifact:** `01_Mapping_Table_Column_city(1).pdf`

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

**Source artifact:** `02_Mapping_Table_Column_borough(1).pdf`

The approved standardized values are:

``` text
Bronx
Brooklyn
Manhattan
Queens
Staten Island
```

plus the sixth standardized borough value represented in the source
mapping.

### Complaint-type mapping

**Source artifact:** `03_Mapping_Table_Column_complaint_type(1).pdf`

Examples include:

``` text
HEAT/HOT WATER
→ Heat/Hot Water

PLUMBING, Plumbing
→ Plumbing

SAFETY, Safety
→ Safety
```

```{=html}
<!-- IMAGE PLACEHOLDER
Source artifact:
01_Mapping_Table_Column_city(1).pdf

Suggested repository image:
docs/images/city_mapping.png

Insert here:
![City Standardization Mapping](docs/images/city_mapping.png)
-->
```
```{=html}
<!-- IMAGE PLACEHOLDER
Source artifact:
02_Mapping_Table_Column_borough(1).pdf

Suggested repository image:
docs/images/borough_mapping.png

Insert here:
![Borough Standardization Mapping](docs/images/borough_mapping.png)
-->
```
```{=html}
<!-- IMAGE PLACEHOLDER
Source artifact:
03_Mapping_Table_Column_complaint_type(1).pdf

Suggested repository image:
docs/images/complaint_type_mapping.png

Insert here:
![Complaint Type Standardization Mapping](docs/images/complaint_type_mapping.png)
-->
```

------------------------------------------------------------------------

# 28. Cleaning Methodology

The cleaning workflow was derived from the profiling results and the
Data Quality Rulebook.

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
Post-Transformation Validation
```

The workflow intentionally performs validation again after
transformation rather than treating successful SQL execution as proof of
data quality.

```{=html}
<!-- IMAGE PLACEHOLDER
Source artifact:
04_Cleaning_Methodology_Report(1).pdf

Suggested repository image:
docs/images/cleaning_methodology.png

Insert here:
![Cleaning Methodology](docs/images/cleaning_methodology.png)
-->
```

------------------------------------------------------------------------

# 29. Key Data Engineering Lessons

## 1. Profile Before You Clean

Cleaning decisions should come from evidence.

Profiling identifies where the dataset actually fails before
transformation logic is written.

------------------------------------------------------------------------

## 2. Convert Quality Expectations into Explicit Rules

A Data Quality Rulebook turns:

> "The data should be clean."

into testable conditions such as:

``` text
closed_date >= created_date
```

or:

``` text
latitude and longitude must exist together
```

This makes quality measurable and repeatable.

------------------------------------------------------------------------

## 3. Separate Remediation from Validation

A successful `UPDATE` or `DELETE` does not prove that the data is
correct.

The rule must be executed again after remediation.

------------------------------------------------------------------------

## 4. Preserve an Audit Trail

Removing a record without recording why it was removed creates a
governance problem.

The exception table provides a traceability mechanism.

------------------------------------------------------------------------

## 5. Standardization Requires Reference Logic

Generic functions such as `UPPER()` and `LOWER()` do not necessarily
resolve business-level variations.

Reference mappings are required where different source values represent
the same analytical category.

------------------------------------------------------------------------

## 6. Missing Does Not Automatically Mean Wrong

The objective is not:

> "Make every cell non-NULL."

The objective is:

> "Make every value fit its defined business and analytical rules."

------------------------------------------------------------------------

## 7. Schema Design Should Reflect Analytical Use

The production schema does not blindly mirror the source schema.

The `due_date` field was removed from the analytical layer because of
its extremely limited population and limited analytical value.

------------------------------------------------------------------------

# 30. Final Project Outcome

The project transformed a large operational dataset into a structured
analytical layer through:

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

-   **5.3M+ raw service-request records assessed**
-   **5,206,784 records retained in the analytical layer**
-   **108,171 records removed / quarantined**
-   **100,984 duplicate records identified and removed**
-   **26,711 status inconsistencies addressed**
-   **1,097 invalid date sequences removed**
-   **706 future-date records removed**
-   **1,040 coordinate-pair violations resolved**
-   **5 invalid ZIP codes removed**
-   **City values reduced from 240 → 159**
-   **Complaint-type values reduced from 194 → 189**
-   **0 duplicate failures after cleaning**
-   **0 date-sequence failures after cleaning**
-   **0 status-consistency failures after cleaning**
-   **0 coordinate-integrity failures after cleaning**
-   **0 invalid ZIP-code failures after cleaning**
-   **100% uniqueness**
-   **100% validity**
-   **100% timeliness**

------------------------------------------------------------------------

# 31. Portfolio Evidence

The following visual evidence should be surfaced directly on the
repository landing page so an interviewer does not need to navigate
through the repository to understand the project.

## 31.1 Data Quality Scorecard

```{=html}
<!-- IMAGE PLACEHOLDER
Exact source filename:
05_Data_Quality_Scorecard(1).pdf

Recommended exported image filename:
data_quality_scorecard.png
-->
```
## 31.2 Cleaning Impact Analysis

```{=html}
<!-- IMAGE PLACEHOLDER
Exact source filename:
02_Cleaning_Impact_Analysis(1).pdf

Recommended exported image filename:
cleaning_impact_analysis.png
-->
```
## 31.3 Rule Validation Report

```{=html}
<!-- IMAGE PLACEHOLDER
Exact source filename:
01_Rule_Validation_Report(1).pdf

Recommended exported image filename:
rule_validation_report.png
-->
```
## 31.4 Raw Data Profile

```{=html}
<!-- IMAGE PLACEHOLDER
Exact source filename:
01_Data_Profile_Raw(1).pdf

Recommended exported image filename:
raw_data_profile.png
-->
```
## 31.5 Cleaned Data Profile

```{=html}
<!-- IMAGE PLACEHOLDER
Exact source filename:
02_Data_Profile_Cleaned(1).pdf

Recommended exported image filename:
cleaned_data_profile.png
-->
```
## 31.6 Cleaning Methodology

```{=html}
<!-- IMAGE PLACEHOLDER
Exact source filename:
04_Cleaning_Methodology_Report(1).pdf

Recommended exported image filename:
cleaning_methodology.png
-->
```
## 31.7 Responsible AI Augmentation

```{=html}
<!-- IMAGE PLACEHOLDER
Exact source filename:
03_AI_Augmentation_Report(1).pdf

Recommended exported image filename:
responsible_ai.png
-->
```

------------------------------------------------------------------------

# 32. Repository Structure

Use the following structure so the landing page remains self-contained
while the underlying repository remains organized:

``` text
NYC-311-Data-Quality-Engineering/
│
├── README.md
│
├── sql/
│   ├── 01_Create_Project_Database(1).sql
│   ├── 02_Create_Medallion_Architecture_schema(1).sql
│   ├── 03_Create_Bronze_Layer_Raw_Data_Table(1).sql
│   ├── 04_Raw_Data_Profiling(1).sql
│   ├── 05_Create_Silver_Layer_Data_Table(1).sql
│   ├── 06_Clean_Silver_Layer_Data(2).sql
│   ├── 07_Create_Gold_Layer_Production_Table(1).sql
│   ├── 08_Load_Cleaned_Silver_Layer_Data_to_Gold_Layer(1).sql
│   └── 09_Cleaned_Data_Profiling(1).sql
│
├── documentation/
│   ├── 01_Data_Profile_Raw(1).pdf
│   ├── 02_Data_Profile_Cleaned(1).pdf
│   ├── 01_Data_Quality_Rulebook(2).pdf
│   ├── 02_Data_Dictionary(1).pdf
│   ├── 01_Mapping_Table_Column_city(1).pdf
│   ├── 02_Mapping_Table_Column_borough(1).pdf
│   ├── 03_Mapping_Table_Column_complaint_type(1).pdf
│   ├── 01_Rule_Validation_Report(1).pdf
│   ├── 02_Cleaning_Impact_Analysis(1).pdf
│   ├── 03_AI_Augmentation_Report(1).pdf
│   ├── 04_Cleaning_Methodology_Report(1).pdf
│   ├── 05_Data_Quality_Scorecard(1).pdf
│   └── 06_Executive_Summary_and_Report(1).pdf
│
├── docs/
│   └── images/
│       ├── architecture.png
│       ├── raw_data_profile.png
│       ├── cleaned_data_profile.png
│       ├── cleaning_impact_analysis.png
│       ├── rule_validation_report.png
│       ├── data_quality_scorecard.png
│       ├── cleaning_methodology.png
│       ├── responsible_ai.png
│       ├── data_dictionary.png
│       ├── city_mapping.png
│       ├── borough_mapping.png
│       └── complaint_type_mapping.png
│
└── data/
    └── README.md
```

------------------------------------------------------------------------

# 33. Documentation Inventory

The complete supporting documentation consists of the following exact
files:

  -------------------------------------------------------------------------------------
  Artifact                            Exact Filename
  ----------------------------------- -------------------------------------------------
  Raw Data Profile                    `01_Data_Profile_Raw(1).pdf`

  Cleaned Data Profile                `02_Data_Profile_Cleaned(1).pdf`

  Data Quality Rulebook               `01_Data_Quality_Rulebook(2).pdf`

  Data Dictionary                     `02_Data_Dictionary(1).pdf`

  City Mapping                        `01_Mapping_Table_Column_city(1).pdf`

  Borough Mapping                     `02_Mapping_Table_Column_borough(1).pdf`

  Complaint Type Mapping              `03_Mapping_Table_Column_complaint_type(1).pdf`

  Rule Validation Report              `01_Rule_Validation_Report(1).pdf`

  Cleaning Impact Analysis            `02_Cleaning_Impact_Analysis(1).pdf`

  AI Augmentation Report              `03_AI_Augmentation_Report(1).pdf`

  Cleaning Methodology Report         `04_Cleaning_Methodology_Report(1).pdf`

  Data Quality Scorecard              `05_Data_Quality_Scorecard(1).pdf`

  Executive Summary & Report          `06_Executive_Summary_and_Report(1).pdf`
  -------------------------------------------------------------------------------------

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

-   Automated rule-execution pipelines
-   Scheduled data-quality monitoring
-   Data observability metrics
-   Automated exception reporting
-   Geographic reference-data validation
-   Incremental quality monitoring
-   Historical quality trend tracking
-   CI/CD validation of SQL transformations
-   Enterprise data-governance integration
-   Automated alerts when quality thresholds are breached

These improvements would evolve the project from a **one-time
remediation workflow** into a continuously monitored data-quality
platform.

------------------------------------------------------------------------

# 36. What This Project Demonstrates

### SQL Development

-   Complex SQL Server transformations
-   CTEs and window functions
-   Views
-   Conditional logic
-   Metadata queries
-   Data-type conversion
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
-   Raw-to-production data flow
-   Analytical schema design
-   Production datatype enforcement

### Data Governance

-   Data-quality rules
-   Severity classification
-   Exception logging
-   Traceability
-   Human oversight
-   Reproducibility

### Responsible AI

-   AI-assisted SQL development
-   AI-assisted troubleshooting
-   AI-assisted documentation
-   Human validation and accountability
-   No autonomous analytical decision-making

------------------------------------------------------------------------

# 37. Portfolio Takeaway

This project is not primarily about removing duplicates or fixing
capitalization.

It demonstrates a broader data-engineering principle:

> **Data quality should be measurable, rule-driven, repeatable,
> auditable, and validated after remediation.**

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

`Microsoft SQL Server` · `T-SQL` · `SQL Server Management Studio` ·
`Data Quality Engineering` · `Data Profiling` · `Medallion Architecture`
· `Responsible AI`

------------------------------------------------------------------------

# Project Status

**Completed --- End-to-End Data Quality Assessment, Remediation &
Validation**

``` text
Raw Dataset        ████████████████████
Profiling          ████████████████████
Rulebook           ████████████████████
Remediation        ████████████████████
Exception Handling ████████████████████
Validation         ████████████████████
Quality Scorecard  ████████████████████
Documentation      ████████████████████
```

------------------------------------------------------------------------

## Author

**Subhomoy H**

SQL · Data Analytics · Data Quality · Data Engineering

> Building analytical systems where data quality is treated as an
> engineering discipline, not an afterthought.
