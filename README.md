moral_experiment

This directory contains the working files for the pilot data quality audit and reporting workflow for the moral framing study.

pilot_check_summary.csv — range-check summary table for key questionnaire items
pilot_data.xlsx - data from the pilot study
pilot_report.Rmd - R Markdown file with the report (needs to be rendered before reading)
pilot_report.md (Markdown file; can be read directly from Github)

Notes

- The current workflow downloads the pilot Excel file from GitHub directly and filters responses by StartDate.
- The report checks item presence, raw-to-questionnaire recoding, invalid/out-of-range values, missingness, and basic logical checks.
