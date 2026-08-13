# Data Quality Assessment and Remediation for NYC 311 Service Requests

## Overview

This project demonstrates a complete enterprise style data quality workflow using the NYC 311 Service Requests dataset.

The objective was to assess, quantify, remediate, and validate data quality issues before analytical consumption using a structured Data Quality Framework built in SQL Server.

The project covers:

* Data Profiling
* Data Quality Assessment
* Rulebook Development
* Data Cleaning
* Exception Management
* Validation
* Data Quality Scorecarding
* Responsible AI Augmentation

---

## Business Problem

Operational datasets frequently contain quality issues that can negatively impact reporting and decision making.

Common issues include:

* Duplicate records
* Invalid timestamps
* Status inconsistencies
* Geographic inaccuracies
* Invalid reference data
* Inconsistent categorical values

This project applies a rule based remediation framework to improve data quality and demonstrate enterprise data governance concepts.

---

## Dataset

**Source:** NYC 311 Service Requests

**Dataset Size**

| Metric                        | Value     |
| ----------------------------- | --------- |
| Raw Records                   | 5,314,955 |
| Clean Records                 | 5,206,784 |
| Records Removed / Quarantined | 108,171   |
| Initial Columns               | 12        |
| Final Columns                 | 11        |

---

## Technology Stack

* SQL Server
* T-SQL
* AI-Assisted Development Workflow

---

## Project Architecture

```text
NYC 311 Dataset
        │
        ▼
Bronze Layer (Raw Ingestion)
        │
        ▼
Data Profiling
        │
        ▼
Data Quality Rulebook
        │
        ▼
Data Cleaning & Standardization
        │
        ▼
Exception Management
        │
        ▼
Silver Layer (Clean Data)
        │
        ▼
Rule Validation
        │
        ▼
Data Quality Scorecard
```

---

## Data Profiling

The dataset was profiled before any transformation activity.

Profiling dimensions included:

### Completeness

* NULL analysis
* Missing value distribution

### Uniqueness

* Duplicate detection
* Duplicate rate analysis

### Validity

* Date validation
* ZIP code validation
* Geographic validation

### Consistency

* City standardization assessment
* Borough standardization assessment
* Complaint type standardization assessment

### Timeliness

* Future-date validation
* Lifecycle validation

---

## Data Quality Rulebook

A formal Data Quality Rulebook was developed containing rules related to:

* Uniqueness
* Completeness
* Validity
* Consistency
* Timeliness
* Geographic Integrity

Examples:

* Unique Service Request Identifier
* Closed Date Validation
* Status Consistency
* Coordinate Pair Completeness
* ZIP Code Validation
* City Standardization
* Borough Standardization
* Complaint Type Standardization

---

## Cleaning Methodology

The cleaning workflow was derived directly from the profiling findings and rulebook.

### Cleaning Activities

1. Removed duplicate records
2. Removed invalid date sequences
3. Removed future-dated records
4. Corrected status inconsistencies
5. Standardized city values
6. Standardized borough values
7. Standardized complaint type values
8. Removed invalid ZIP codes
9. Converted VARCHAR ingestion columns to production datatypes
10. Revalidated all rules after cleaning

---

## Cleaning Impact

| Cleaning Activity                       | Records Affected |
| --------------------------------------- | ---------------- |
| Duplicate Removal                       | 100,984          |
| Invalid Date Sequence Removal           | 1,097            |
| Future Date Removal                     | 706              |
| Status Corrections                      | 20,672           |
| Closed Status Violations Removed        | 6,039            |
| Coordinate Integrity Violations Removed | 1,040            |
| Invalid ZIP Codes Removed               | 5                |

---

## Validation Results

### Before vs After

| Quality Dimension | Raw Dataset | Clean Dataset |
| ----------------- | ----------- | ------------- |
| Completeness      | 98.86%     | 98.88%         |
| Uniqueness        | 98.10%     | 100.00%        |
| Validity          | 99.83%     | 100.00%        |
| Timeliness        | 99.98%     | 100.00%        |

### Rule Validation

* 100% duplicate elimination
* 100% date rule compliance
* 100% status rule compliance
* 100% coordinate integrity compliance
* 100% ZIP code validation compliance

---

## Responsible AI Augmentation

AI was used as a productivity enhancement tool throughout the project.

### AI Assisted Activities

* Project planning
* Workflow design
* SQL generation
* SQL troubleshooting
* Data profiling framework design
* Rulebook drafting
* Standardization logic generation
* Validation report generation
* Documentation drafting

### Human Owned Activities

* Dataset selection
* Profiling execution
* Data quality assessment
* Cleaning decisions
* Validation
* Quality scoring
* Final conclusions

No raw operational records were used for automated analysis.

---

## Repository Structure

```text
NYC_311_Service_Requests_Data_Quality_Framework
├── 01_Data/
│   ├── 01_NYC_Service_Requests_Raw.csv
│   └── 02_NYC_Service_Requests_Cleaned.csv
│
├── 02_Data_Profile/
│   ├── 01_Data_Profile_Raw.pdf
│   └── 02_Data_Profile_Cleaned.pdf
│
├── 03_Rule_Book/
│   ├── 01_Data_Quality_Rulebook.pdf
│   └── 02_Data_Dictionary.pdf
|
├── 04_Mapping_Table/
│   ├── 01_Mapping_Table_Column_city.pdf
│   ├── 02_Mapping_Table_Column_borough.pdf
│   └── 03_Mapping_Table_Column_complaint_type.pdf
|
├── 05_SQL_Scripts/
│   ├── 01_Create_Project_Database.sql
│   ├── 02_Create_Medallion_Architecture_Schema.sql
│   ├── 03_Create_Bronze_Layer_Raw_Data_Table.sql
│   ├── 04_Raw_Data_Profiling.sql
│   ├── 05_Create_Silver_Layer_Data_Table.sql
│   ├── 06_Clean_Silver_Layer_Data.sql
│   ├── 07_Create_Gold_Layer_Production Table.sql
│   ├── 08_Load_Cleaned_Silver_Layer_Data_to_Gold_Layer.sql
│   └── 09_Cleaned_Data_Profiling.sql
│
├── 06_Data_Quality_Reports/
│   ├── 01_Rule_Validation_Report.pdf
│   ├── 02_Cleaning_Impact_Analysis.pdf
│   ├── 03_AI_Augmentation_Report.pdf
│   ├── 04_Cleaning_Methodology_Report.pdf
│   ├── 05_Data_Quality_Scorecard.pdf
│   └── 06_Executive_Summary_and_Report.pdf
|
└──  README.md
```

---

## Key Learnings

* Data profiling is the foundation of effective cleaning.
* Rule-based validation improves transparency and repeatability.
* Exception management preserves lineage and auditability.
* Standardization improves analytical consistency.
* AI can accelerate development while maintaining human oversight.

---

```text
SELECT TOP 10 * FROM bronze.NYC_Service_Requests_raw;   -- Sample of Raw data
```
| unique_key | created_date | closed_date | agency | complaint_type | incident_zip | city | status | due_date | borough | latitude | longitude |
|------------|-------------|-------------|--------|----------------|-------------|------|--------|----------|----------|-----------|------------|
| 69189778 | 06-01-2026 02:57 | NULL | DOT | Street Condition | NULL | NULL | Open | NULL | Unspecified | NULL | NULL |
| 69189780 | 06-01-2026 02:25 | NULL | DOT | Street Condition | 11416 | QUEENS | Open | NULL | QUEENS | NULL | NULL |
| 69192559 | 06-01-2026 02:21 | NULL | DOT | Street Condition | 11422 | QUEENS | Open | NULL | QUEENS | 40.65470936 | -73.74330808 |
| 69185044 | 06-01-2026 02:21 | 06-01-2026 02:21 | DOT | Street Condition | 11422 | QUEENS | Closed | NULL | QUEENS | 40.65470936 | -73.74330808 |
| 69194179 | 06-01-2026 01:51 | NULL | NYPD | Noise - Residential | NULL | NULL | In Progress | NULL | Unspecified | 40.85452034 | -73.89414328 |
| 69187231 | 06-01-2026 01:51 | NULL | NYPD | Noise - Street/Sidewalk | 10457 | NULL | In Progress | NULL | BRONX | 40.83826484 | -73.90522783 |
| 69191414 | 06-01-2026 01:51 | NULL | NYPD | Noise - Street/Sidewalk | 10458 | BRONX | In Progress | NULL | BRONX | 40.86089245 | -73.89595880 |
| 69192772 | 06-01-2026 01:51 | NULL | NYPD | Noise - Residential | 10458 | BRONX | In Progress | NULL | BRONX | 40.86423853 | -73.89327458 |
| 69188466 | 06-01-2026 01:50 | NULL | NYPD | Blocked Driveway | 11373 | ELMHURST | In Progress | NULL | QUEENS | 40.74473932 | -73.87237213 |
| 69185619 | 06-01-2026 01:50 | NULL | NYPD | Abandoned Vehicle | 11239 | BROOKLYN | In Progress | NULL | BROOKLYN | 40.65651338 | -73.86918550 |

---

```text
SELECT TOP 10 * FROM gold.NYC_Service_Requests;   -- Sample of Cleaned Data
```
| unique_key | created_date | closed_date | agency | complaint_type | incident_zip | city | status | borough | latitude | longitude |
|------------|-------------|-------------|--------|----------------|-------------|------|--------|----------|-----------|------------|
| 42282670 | 31-10-2025 09:28 | 31-10-2025 09:28 | DOB | Construction Safety Enforcement | 10014 | New York City | Closed | Manhattan | 40.73252159 | -74.00649839 |
| 42282671 | 31-10-2025 09:20 | 31-10-2025 09:20 | DOB | Construction Safety Enforcement | 10014 | New York City | Closed | Manhattan | 40.73216494 | -74.00207110 |
| 42282673 | 31-10-2025 14:28 | 31-10-2025 14:28 | DOB | Construction Safety Enforcement | 11238 | Brooklyn | Closed | Brooklyn | 40.68617685 | -73.95753922 |
| 42282675 | 31-10-2025 14:55 | 31-10-2025 14:55 | DOB | Construction Safety Enforcement | 11101 | Long Island City | Closed | Queens | 40.74322808 | -73.95394459 |
| 42282683 | 31-10-2025 12:00 | 31-10-2025 12:00 | DOB | Construction Safety Enforcement | 11238 | Brooklyn | Closed | Brooklyn | 40.67708752 | -73.97066799 |
| 42282684 | 31-10-2025 10:29 | 31-10-2025 10:29 | DOB | Construction Safety Enforcement | 11211 | Brooklyn | Closed | Brooklyn | 40.70579246 | -73.96179353 |
| 42282685 | 31-10-2025 08:25 | 31-10-2025 08:25 | DOB | Construction Safety Enforcement | 11208 | Brooklyn | Closed | Brooklyn | 40.67390480 | -73.88234224 |
| 42282686 | 31-10-2025 15:08 | 31-10-2025 15:08 | DOB | Construction Safety Enforcement | 11105 | Astoria | Closed | Queens | 40.78663278 | -73.91436530 |
| 42282689 | 31-10-2025 13:22 | 31-10-2025 13:22 | DOB | Construction Safety Enforcement | 10027 | New York City | Closed | Manhattan | 40.81058117 | -73.95391605 |
| 42282690 | 31-10-2025 17:59 | 31-10-2025 17:59 | DOB | Construction Safety Enforcement | 11232 | Brooklyn | Closed | Brooklyn | 40.64620696 | -73.99705590 |
---

