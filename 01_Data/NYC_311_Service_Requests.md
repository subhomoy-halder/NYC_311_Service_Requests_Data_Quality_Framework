## Dataset Access

Due to the size of the dataset (5.3M+ records), the raw and cleaned data files are hosted externally.

### Raw Dataset

The original ingested dataset used for profiling and data quality assessment can be accessed here:

🔗 **Raw Dataset:**
[Download Raw Dataset](https://drive.google.com/file/d/1elio8SMuCYqQKLe7RJKCgawY7buB7j8_/view?usp=sharing)

---

### Cleaned Dataset

The cleaned dataset produced after rule-based remediation, standardization, validation, and exception handling can be accessed here:

🔗 **Cleaned Dataset:**
[Download Cleaned Dataset](https://drive.google.com/file/d/1XZjyA7a0HLXz1VWhmB_6jQ8Jo_NNfDH2/view?usp=sharing)

---

### Notes

* Raw data represents the Bronze layer after ingestion.
* Cleaned data represents the Silver layer after data quality remediation.
* Records removed during cleaning were logged to an exception table to preserve lineage and auditability.
* Refer to the Final Report for a detailed explanation of the cleaning methodology, validation framework, and quality improvements.

## Datasets

| Dataset                        | Description                                                       | 
| ------------------------------ | ----------------------------------------------------------------- | 
| Raw Dataset (Bronze Layer)     | Original ingested NYC 311 service request data                    | 
| Cleaned Dataset (Gold Layer)   | Rule validated and standardized dataset used for analysis         | 

### Dataset Summary

| Metric                        | Value     |
| ----------------------------- | --------- |
| Raw Records                   | 5,314,955 |
| Clean Records                 | 5,206,784 |
| Records Removed / Quarantined | 108,171   |

All datasets are provided for reproducibility and validation of the project results.
