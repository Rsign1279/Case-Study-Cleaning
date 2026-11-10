# DASC 1003 Case Study 4 — Data Cleaning (base R)
# Run from the repository root. This script uses the included November 2026 snapshot.
input_file <- file.path("data", "raw", "patient-protect-healthcare-breach-dataset.csv")
output_dir <- file.path("data", "processed")

if (!file.exists(input_file)) {
  stop("Missing input: ", input_file, ". Run from the repository root with the raw CSV in place.",
       call. = FALSE)
}

# Skip the snapshot's leading provider metadata. Leave any '#' inside data intact.
metadata <- readLines(input_file, n = 15, warn = FALSE, encoding = "UTF-8")
if (length(metadata) != 15 || !all(startsWith(metadata, "#"))) {
  stop("Expected 15 lines of provider metadata before the CSV header.", call. = FALSE)
}
df <- read.csv(input_file, skip = 15, na.strings = c("", "NA"),
               stringsAsFactors = FALSE, fileEncoding = "UTF-8")
required_columns <- c("record_id", "source_event_group_id", "record_class",
                      "source_type", "entity_name")
if (!all(required_columns %in% names(df))) {
  stop("The raw CSV is missing one or more required columns.", call. = FALSE)
}

cat("Loaded:", nrow(df), "rows and", ncol(df), "columns\n")
cat("Missing values by column before cleaning:\n")
print(colSums(is.na(df)))

# Trim only the edges of organization names; preserve spelling and punctuation.
df$entity_name <- trimws(df$entity_name)
duplicate_rows <- sum(duplicated(df))
df <- unique(df)

# A source record needs an ID and an organization name.
usable <- !is.na(df$record_id) & nzchar(trimws(df$record_id)) &
          !is.na(df$entity_name) & nzchar(df$entity_name)
excluded_rows <- sum(!usable)
df <- df[usable, , drop = FALSE]
if (anyDuplicated(df$record_id)) {
  stop("Repeated record IDs with different values need manual review.", call. = FALSE)
}

# Keep partial columns and leave their unknown values as NA.
empty_columns <- names(df)[colSums(!is.na(df)) == 0]
df <- df[, !(names(df) %in% empty_columns), drop = FALSE]
removed_columns <- empty_columns
# Remove the deprecated ID only if the surviving grouping key contains the same values.
if (all(c("event_id", "source_event_group_id") %in% names(df)) &&
    identical(df$event_id, df$source_event_group_id)) {
  df$event_id <- NULL
  removed_columns <- c(removed_columns, "event_id")
}

# Separate the two source record classes without collapsing shared group IDs.
if (any(!df$record_class %in% c("breach_filing", "regulatory_action"))) {
  stop("Missing or unexpected record class. Review the raw CSV.", call. = FALSE)
}
breaches <- df[df$record_class == "breach_filing", , drop = FALSE]

# Patient Protect record ID for the Change Healthcare, Inc. HHS OCR filing.
change_id <- "6096174d-1676-4947-9ed6-87c9ff789635"
change_case <- breaches[breaches$record_id == change_id, , drop = FALSE]
if (nrow(change_case) != 1 || !isTRUE(change_case$source_type == "hhs_breach")) {
  stop("Expected one Change Healthcare HHS OCR filing with the verified record ID.",
       call. = FALSE)
}

# Empty CSV cells represent NA. No row numbers are added to the data.
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(df, file.path(output_dir, "patient_protect_clean_all.csv"),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(breaches, file.path(output_dir, "patient_protect_breach_filings.csv"),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(change_case, file.path(output_dir, "change_healthcare_filing.csv"),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")

cat("Removed:", duplicate_rows, "duplicate rows and", excluded_rows,
    "rows without a record ID or organization name\n")
cat("Columns removed:", paste(removed_columns, collapse = ", "), "\n")
cat("Cleaned:", nrow(df), "rows and", ncol(df), "columns\n")
print(table(df$record_class))
cat("Change Healthcare breach filing rows:", nrow(change_case), "\n")
