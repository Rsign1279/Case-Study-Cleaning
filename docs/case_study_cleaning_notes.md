# Case Study 4 — Cleaning Notes

## Source and scope

The input is a Patient Protect [Healthcare Breach Dataset](https://patient-protect.com/breach-dataset) CSV. The original download was named `patient-protect-healthcare-breach-dataset (2) (1).csv`; the copy in [data/raw](../data/raw/patient-protect-healthcare-breach-dataset.csv) has a shorter filename and identical contents. Its 15 leading metadata lines identify the snapshot as retrieved on November 3, 2026 at 18:30:49 UTC and credit the HHS Office for Civil Rights (OCR) Breach Portal and OCR enforcement records.

Patient Protect licenses the open export under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) for the rights it holds. The source file keeps that notice. See the [provider's methodology](https://patient-protect.com/breachdash/methodology) for the scope of the public export and how it differs from the dashboard.

## Before and after

| Measure | Raw | Cleaned full | Breach filings | Change Healthcare filing |
| --- | ---: | ---: | ---: | ---: |
| Rows | 4,206 | 4,206 | 1,495 | 1 |
| Columns | 12 | 10 | 10 | 10 |
| Exact duplicate rows | 0 | 0 | 0 | 0 |
| Repeated `record_id` values | 0 | 0 | 0 | 0 |
| Missing `state` | 34 | 34 | 4 | 0 |
| Missing `individuals_affected` | 356 | 356 | 0 | 0 |
| Missing `breach_submission_date` | 2,711 | 2,711 | 0 | 0 |
| Missing `summary` | 1,405 | 1,405 | 1,405 | 1 |
| Missing `enforcement_action_date` | 4,206 | Removed | Removed | Removed |

All other retained columns had zero missing values. The counts in this table were calculated from the CSVs. Blank fields are read as `NA`; the exports represent those values with empty cells. No dates, counts, or descriptions were filled in. All 2,711 missing filing dates belong to regulatory-action rows. That field describes filings and cannot stand in for an enforcement date.

## Checks and changes

- **Organization names and IDs:** The script trims leading and trailing whitespace from `entity_name` and checks for a missing or blank ID or name. No names changed and no rows failed the check.
- **Duplicates:** There were no exact duplicates, either before or after trimming. The script removes exact duplicates if present and stops if different rows still share a `record_id`. Repeated `source_event_group_id` values were kept because they link separate source records. The filing subset contains 1,390 unique grouping IDs across 1,495 rows.
- **Columns removed:** `enforcement_action_date` was entirely empty. `event_id` was deprecated and matched `source_event_group_id` on all 4,206 rows. The retained grouping key preserves that information. `severity_score` is also marked deprecated in the metadata; it was populated and is retained as supplied. It was not used in cleaning or selection.
- **Record classes:** The full output keeps 1,495 `breach_filing` rows from `hhs_breach` and 2,711 `regulatory_action` rows from `ocr_enforcement`. The filing subset excludes all regulatory actions. It keeps all ten cleaned columns, with row order unchanged.

## Change Healthcare selection

The case file contains the `breach_filing` with Patient Protect `record_id` `6096174d-1676-4947-9ed6-87c9ff789635` and `source_event_group_id` `f083b383-39f4-45fd-9c6a-216ba1fd5f8a`. The source row names Change Healthcare, Inc. and reports a July 19, 2024 submission date and 192,700,000 affected individuals. The [HHS OCR case FAQ](https://www.hhs.gov/hipaa/for-professionals/special-topics/change-healthcare-cybersecurity-incident-frequently-asked-questions/index.html) corroborates the filing date and approximate updated count.

The full file also contains a separate row that Patient Protect classifies as a regulatory action involving Change Healthcare, Optum, and UnitedHealth Group. It remains in the full file as supplied. It is excluded from the case file, and its affected count should not be added to the filing's count. The provider's regulatory summaries were not independently verified.

## Validation and limitations

The script was run with R 4.6.1 against the included raw snapshot. Reading back all three generated files confirmed identical headers, values, missing cells, and row order compared with the supplied CSVs. The repository keeps the supplied CSVs as provided; base R can quote CSV text differently. The missing input error was also checked.

The published files contain source record IDs, organization and location fields, dates, aggregate counts, and public source summaries. The schema and text fields were screened for patient-level identifiers and credentials; none were identified. The project does not use leaked data.

A filing row represents a report, and several rows can refer to one underlying breach. The upstream grouping ID does not recreate Patient Protect's canonical event model or identify unique affected people. Reported dates and totals can be incomplete or revised, so keep the snapshot date with any analysis. The live feed can change; the bundled snapshot is the input for reproducing these results. A Numbers import or other copy of the same export should not be appended to it.
