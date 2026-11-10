# Healthcare Data Breach Analysis — Data Cleaning

DASC 1003 | Case Study 4: Recent Breaches in Technology

## Project Overview

This repository contains the data preparation portion of a five-person group investigation into healthcare cybersecurity breaches. The Change Healthcare cyberattack is the main case study. The repository includes the original source snapshot, a base R cleaning script, and three CSVs prepared for the team's analysis.

## Research Context

A filing can tell us when an organization reported a breach and how many people it reported as affected. A regulatory action documents a different process and can use the same fields differently. Checking which fields are missing and separating the two types of records makes it easier to compare filing dates, reporting organizations, and affected counts without inflating totals.

## My Contribution

I was responsible for **Section C — Prepare and Clean Data**. I used R to inspect the source export, check missing values and duplicates, remove two unnecessary columns, and prepare separate files for the team's filing analysis and Change Healthcare case study.

## Dataset Overview

| File | Purpose | Rows | Columns |
| --- | --- | ---: | ---: |
| [patient-protect-healthcare-breach-dataset.csv](data/raw/patient-protect-healthcare-breach-dataset.csv) | Original Patient Protect snapshot, with provider metadata | 4,206 | 12 |
| [patient_protect_clean_all.csv](data/processed/patient_protect_clean_all.csv) | All source records: 1,495 breach filings and 2,711 regulatory actions | 4,206 | 10 |
| [patient_protect_breach_filings.csv](data/processed/patient_protect_breach_filings.csv) | Breach filings for analysis | 1,495 | 10 |
| [change_healthcare_filing.csv](data/processed/change_healthcare_filing.csv) | The Change Healthcare breach filing | 1 | 10 |

Counts exclude headers and source metadata. The processed files are nested views of one source dataset; appending them would count records more than once.

## Data Cleaning Process

1. **Check missing values.** Read blank cells as `NA` and count them by column. Leave unknown or inapplicable values missing.
2. **Check duplicates.** Count and remove exact duplicate rows after trimming. Stop for review if any remaining records share an ID. This snapshot had no duplicate rows or repeated record IDs.
3. **Standardize text.** Trim whitespace at the start and end of organization names. Exclude records without an ID or usable name. No names needed trimming and no records were excluded.
4. **Remove unnecessary columns.** Drop the entirely empty `enforcement_action_date` column. Drop deprecated `event_id` after checking that it exactly matches `source_event_group_id`.
5. **Classify records.** Use `record_class` to select breach filings. Within that subset, use the verified source record ID to select the Change Healthcare filing.
6. **Export the datasets.** Save the full dataset and the two subsets, with missing values written as empty CSV fields. Print a summary of the cleaning steps and counts.

See the [cleaning notes](docs/case_study_cleaning_notes.md) for the before-and-after checks and selection details.

## Repository Structure

```text
Case-Study-Cleaning/
├── README.md
├── .gitignore
├── scripts/
│   └── clean_case_study.R
├── data/
│   ├── raw/
│   │   └── patient-protect-healthcare-breach-dataset.csv
│   └── processed/
│       ├── patient_protect_clean_all.csv
│       ├── patient_protect_breach_filings.csv
│       └── change_healthcare_filing.csv
└── docs/
    └── case_study_cleaning_notes.md
```

## How to Run

Install R and open RStudio. Clone or download this repository. In RStudio, choose **Session → Set Working Directory → Choose Directory** and select the `Case-Study-Cleaning` folder. Run this in the Console:

```r
source("scripts/clean_case_study.R")
```

From a terminal at the repository root, you can also run:

```sh
Rscript scripts/clean_case_study.R
```

The script uses only base R and reads the included file in `data/raw/`. Running it rewrites the three CSVs in `data/processed/`. The generated files have the same headers, row order, values, and missing cells as the checked-in CSVs; CSV quoting can differ.

## Data Quality and Limitations

- **The unit is a source record.** A regulatory action is separate from a breach filing, even when both refer to the same incident. Do not add affected counts across those classes.
- **Multiple filings can describe the same incident.** The 1,495 filing rows span 1,390 upstream grouping IDs. Neither count is a verified total of distinct breaches, and the grouping key cannot reproduce Patient Protect's dashboard figures.
- **Coverage and reported values can change.** Reporting delays leave recent periods incomplete. A submission date is not the attack date, and reported counts can be revised. Missing counts are unknown, not zero. Sources can differ in thresholds, coverage periods, and definitions; check those before comparing totals.

## Data Sources

Patient Protect, [Healthcare Breach Dataset](https://patient-protect.com/breach-dataset), snapshot retrieved November 3, 2026 (per the embedded metadata). Patient Protect compiles public records from the U.S. Department of Health and Human Services (HHS) Office for Civil Rights (OCR), including Breach Portal filings and enforcement records. Its [methodology](https://patient-protect.com/breachdash/methodology) explains the difference between this source export and its reconciled dashboard data.

Patient Protect distributes the source dataset under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), limited to the rights it holds. The raw file preserves the provider's metadata and attribution. The processed files are adaptations produced by the cleaning steps above.

## Academic Context

- **Course:** DASC 1003 — Introduction to Data Science
- **Assignment:** Case Study 4 — Recent Breaches in Technology
- **Contribution:** Section C — Data Preparation and Cleaning
