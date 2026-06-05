# Enterprise Data Quality Assessment & Remediation for NYC 311 Service Requests

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
* GitHub
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
NYC311-DataQualityFramework/

├── Data/
│   ├── Raw/
│   ├── Cleaned/
│
├── SQL/
│   ├── Profiling/
│   ├── Cleaning/
│   ├── Validation/
│
├── PowerBI/
│
├── Documentation/
│   ├── Data_Profile_Raw.pdf
│   ├── Data_Profile_Clean.pdf
│   ├── Rulebook.pdf
│   ├── Final_Report.pdf
│
├── README.md
│
└── Screenshots/
```

---

## Key Learnings

* Data profiling is the foundation of effective cleaning.
* Rule-based validation improves transparency and repeatability.
* Exception management preserves lineage and auditability.
* Standardization improves analytical consistency.
* AI can accelerate development while maintaining human oversight.

---

