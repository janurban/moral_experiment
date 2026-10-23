Pilot Variable Check Report
================
23 October 2026

**Data:** `pilot_data.xlsx` from GitHub (janurban/moral_experiment), a
Qualtrics export with numeric codes. **Reference documents:**
`questionnaire.docx`, `pre-registration.docx`, student pilot feedback.
**Treatment coding (column `Group`):** VU = control (sleep text), CZG T1
= harm-care, CZG T2 = purity.

Every number in this report is computed when the file is rendered. To
render it, run `rmarkdown::render("pilot_report.Rmd")` for the GitHub
version, or `rmarkdown::render("pilot_report.Rmd", "pdf_document")` for
a PDF.

## 0. Data download and date filter

The data are downloaded directly from GitHub. Only responses that
**started after 15 October 2026** are kept, that is, with a `StartDate`
on or after 16 October 2026 at 00:00 in the Qualtrics export time zone.

``` r
# Download pilot data from GitHub
data_url  <- "https://github.com/janurban/moral_experiment/raw/refs/heads/main/pilot_data.xlsx"
data_file <- file.path(tempdir(), "pilot_data.xlsx")
download.file(data_url, destfile = data_file, mode = "wb", quiet = TRUE)

# Read: dates as dates, everything else as text.
# Row 1 of the sheet = variable names, row 2 = question text, data from row 3.
hdr    <- names(read_excel(data_file, n_max = 0))
types  <- ifelse(hdr %in% c("StartDate", "EndDate", "RecordedDate"), "date", "text")
raw    <- suppressWarnings(read_excel(data_file, col_types = types))
labels <- setNames(as.character(unlist(raw[1, ])), hdr)
full   <- as.data.frame(raw[-1, ], stringsAsFactors = FALSE)

# Keep responses started after 15 October 2026
cutoff  <- as.POSIXct("2026-10-16 00:00:00", tz = "UTC")
keep    <- !is.na(full$StartDate) & full$StartDate >= cutoff
dat     <- full[keep, ]
dropped <- full[!keep, ]
```

| Step                                                         | n      |
|:-------------------------------------------------------------|:-------|
| Rows in `pilot_data.xlsx`                                    | 79     |
| Removed by the date filter (StartDate 12 Oct to 15 Oct 2026) | 7      |
| **Kept**                                                     | **72** |

## 1. Summary

| Question                                  | Answer                                                                                                                                                                                                                             |
|:------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Are all questionnaire variables recorded? | **Yes.** All 52 item variables plus `Q0b` and `Group` are present, and every column’s question text matches the expected item.                                                                                                     |
| Are their ranges correct?                 | **Yes, after recoding.** 0 invalid codes and 0 out-of-range values. However, the raw Qualtrics codes are not on the questionnaire scales: Q07b uses codes 1, 2, 3, 8, 9, 10, 11 and Q07c uses 1, 2, 3, 4, 8, 9, 10. See problem 1. |
| Is something missing or unclear?          | **Yes.** See Sections 5 and 6.                                                                                                                                                                                                     |

## 2. Sample after the date filter

| Subset                                      | n      |
|:--------------------------------------------|:-------|
| Kept after the date filter                  | 72     |
| Screened out (no `Group`; `Q0b` code 0.0)   | 11     |
| Assigned to a treatment group               | 61     |
| Dropped out after assignment (Finished = 0) | 1      |
| **Completers (assigned and finished)**      | **60** |
| Control (`Group` = VU)                      | 42     |
| Harm-care (`Group` = CZG T1)                | 9      |
| Purity (`Group` = CZG T2)                   | 9      |

The target allocation is 4 : 1 : 1. The range check and all later
sections use the 60 completers.

## 3. Presence check

### 3.1 Questionnaire variables

| Block                 | Items | Present | Question text matches |
|:----------------------|------:|:--------|:----------------------|
| Q01 Diet screening    |     1 | TRUE    | \-                    |
| Q03 Manipulation      |     1 | TRUE    | \-                    |
| Q04 Emotions          |     6 | TRUE    | TRUE                  |
| Q05 Attention check   |     1 | TRUE    | TRUE                  |
| Q06 Moralization      |     4 | TRUE    | TRUE                  |
| Q07 Perceived harm    |    12 | TRUE    | TRUE                  |
| Q08 Association check |     4 | TRUE    | TRUE                  |
| Q10-Q20 Choice task   |    11 | TRUE    | TRUE                  |
| Q22 MFQ relevance     |     7 | TRUE    | TRUE                  |
| Q23 MFQ agreement     |     7 | TRUE    | TRUE                  |

### 3.2 Variables required by the preregistration

| Needed for                  | Variable                      | Status                                                                                   |
|:----------------------------|:------------------------------|:-----------------------------------------------------------------------------------------|
| All models (fixed effect)   | Country                       | **Missing.** `UserLanguage` = EN.                                                        |
| Participant identifier      | `id`                          | **Empty** for every respondent.                                                          |
| Randomization checks        | Display-order (`_DO`) columns | **Not exported.**                                                                        |
| Exclusion of non-completers | Completion flag               | `Finished` = 0 for 1 drop-out(s), but screened-out respondents also have Finished = 1.0. |

### 3.3 Columns in the data not described in the questionnaire

| Group                         | Columns                                                                                                                                                                                                                                                                                                                                                                                                                                     |   n |
|:------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----:|
| Socio-demographics            | `food_decision_maker`, `Q39.food_expenditure`, `Q42.shopping_channel`, `Q43.meal_outside`, `Q29. reason_nobuy`, `Q29. reason_nobuy_11_TEXT`, `Q120. reason_buy`, `Q31.difficult_nomeat`, `Q40.peer_effect`, `Q30.meat_culture_fit`, `Q45.nutrition_aware`, `Q46.health_concern`, `Q47.physical_days`, `Q32.gender`, `Q33.year`, `Q34.area`, `Q35.family_1`, `Q35.family_2`, `Q36.edu`, `Q37.employment`, `Q38.income`, `Q44.environ_member` |  22 |
| Second study (shopping tasks) | `baseline_*` (20), `task1_*` (26), `task2_*` (26), `task3_*` (26)                                                                                                                                                                                                                                                                                                                                                                           |  98 |
| Unclear                       | `VU treatment`                                                                                                                                                                                                                                                                                                                                                                                                                              |   1 |

**4 socio-demographic items come before the diet screening.** These are
`food_decision_maker`, `Q39.food_expenditure`, `Q42.shopping_channel`,
`Q43.meal_outside`. They sit before `Q0b` in the column order, and 5 of
the 11 screened-out respondents answered them. This matches student
reports that the food-spending questions “repeated twice, at the start
and then again later”. Each item has only one column, so a second
showing is either not recorded or overwrites the first answer. This
needs checking in the survey flow.

## 4. Range check (completers, n = 60)

The export contains **numeric codes, not labels**, and these are recoded
to the questionnaire values. The mapping was verified against a
Qualtrics label export of the same survey for 9 respondents present in
both files. Codes that did not occur among those 9 are marked as
*inferred* and should be confirmed in Qualtrics (*Recode values*).

| Items                                 | Raw code to questionnaire value                                                                   |
|---------------------------------------|---------------------------------------------------------------------------------------------------|
| Emotions                              | 1-5 to 0-4 (1 Not at all, 2 Slightly, 3 Moderately, 5 Very much verified; 4 Quite a bit inferred) |
| Attention check                       | 1-4 unchanged (2 animal suffering, 3 sleep verified; 1 pollution/hygiene, 4 exercise inferred)    |
| Moralization, Q07a, association check | 1-7 unchanged                                                                                     |
| Q07b                                  | 1 to 1, 2 to 2, **8 to 3, 9 to 4 (inferred), 10 to 5, 11 to 6, 3 to 7**                           |
| Q07c                                  | 1 to 1, 2 to 2 (inferred), **8 to 3 (inferred), 9 to 4, 10 to 5, 3 to 6, 4 to 7**                 |
| Choice Q10-Q20                        | 1 to 0 (animal-based), 2 to 1 (plant-based), verified                                             |
| Q22, Q23 (MFQ)                        | 1-6 to 0-5                                                                                        |

| Variable              | Construct          | Raw codes                     | Expected | Valid | Missing | Invalid code | Out of range |
|:----------------------|:-------------------|:------------------------------|:---------|------:|--------:|-------------:|-------------:|
| `emotions_1`          | Disgust            | 1.0,2.0,3.0,4.0,5.0           | 0-4      |    60 |       0 |            0 |            0 |
| `emotions_2`          | Disgust            | 1.0,2.0,3.0,4.0,5.0           | 0-4      |    60 |       0 |            0 |            0 |
| `emotions_3`          | Disgust            | 1.0,2.0,3.0,4.0,5.0           | 0-4      |    60 |       0 |            0 |            0 |
| `emotions_4`          | Compassion         | 1.0,2.0,3.0,4.0,5.0           | 0-4      |    60 |       0 |            0 |            0 |
| `emotions_5`          | Compassion         | 1.0,2.0,3.0,4.0,5.0           | 0-4      |    60 |       0 |            0 |            0 |
| `emotions_6`          | Compassion         | 1.0,2.0,3.0,4.0,5.0           | 0-4      |    60 |       0 |            0 |            0 |
| `attention check`     | Attention check    | 1.0,2.0,3.0,4.0               | 1-4      |    60 |       0 |            0 |            0 |
| `moralization_1`      | Moralization       | 1.0,2.0,3.0,4.0,5.0,6.0,7.0   | 1-7      |    60 |       0 |            0 |            0 |
| `moralization_2`      | Moralization       | 1.0,2.0,3.0,4.0,5.0,6.0,7.0   | 1-7      |    60 |       0 |            0 |            0 |
| `moralization_3`      | Moralization       | 1.0,2.0,3.0,4.0,5.0,6.0,7.0   | 1-7      |    60 |       0 |            0 |            0 |
| `moralization_4`      | Moralization       | 1.0,2.0,3.0,4.0,5.0,6.0,7.0   | 1-7      |    60 |       0 |            0 |            0 |
| `Q07a_1`              | Perceived harm     | 1.0,2.0,3.0,4.0,5.0,6.0       | 1-7      |    60 |       0 |            0 |            0 |
| `Q07a_2`              | Perceived harm     | 1.0,2.0,3.0,4.0,5.0,6.0       | 1-7      |    60 |       0 |            0 |            0 |
| `Q07a_3`              | Perceived harm     | 1.0,2.0,3.0,4.0,5.0,6.0,7.0   | 1-7      |    60 |       0 |            0 |            0 |
| `Q07a_4`              | Perceived harm     | 2.0,3.0,4.0,5.0,6.0,7.0       | 1-7      |    60 |       0 |            0 |            0 |
| `Q07b_1`              | Perceived harm     | 1.0,2.0,8.0,9.0,10.0,11.0     | 1-7      |    60 |       0 |            0 |            0 |
| `Q07b_2`              | Perceived harm     | 1.0,2.0,8.0,9.0,10.0,11.0     | 1-7      |    60 |       0 |            0 |            0 |
| `Q07b_3`              | Perceived harm     | 1.0,2.0,3.0,8.0,9.0,10.0,11.0 | 1-7      |    60 |       0 |            0 |            0 |
| `Q07b_4`              | Perceived harm     | 1.0,2.0,3.0,8.0,9.0,10.0,11.0 | 1-7      |    60 |       0 |            0 |            0 |
| `Q07c_1`              | Perceived harm     | 1.0,2.0,3.0,8.0,9.0,10.0      | 1-7      |    60 |       0 |            0 |            0 |
| `Q07c_2`              | Perceived harm     | 1.0,2.0,3.0,8.0,9.0,10.0      | 1-7      |    60 |       0 |            0 |            0 |
| `Q07c_3`              | Perceived harm     | 1.0,2.0,3.0,4.0,8.0,9.0,10.0  | 1-7      |    60 |       0 |            0 |            0 |
| `Q07c_4`              | Perceived harm     | 1.0,2.0,3.0,4.0,8.0,9.0,10.0  | 1-7      |    60 |       0 |            0 |            0 |
| `association check_1` | Harm association   | 1.0,2.0,4.0,5.0,6.0,7.0       | 1-7      |    60 |       0 |            0 |            0 |
| `association check_2` | Harm association   | 1.0,2.0,3.0,4.0,5.0,6.0,7.0   | 1-7      |    60 |       0 |            0 |            0 |
| `association check_3` | Purity association | 2.0,3.0,4.0,5.0,6.0,7.0       | 1-7      |    60 |       0 |            0 |            0 |
| `association check_4` | Purity association | 1.0,2.0,3.0,4.0,5.0,6.0,7.0   | 1-7      |    60 |       0 |            0 |            0 |
| `Q10`                 | Choice (drink)     | 1.0,2.0                       | 0-1      |    60 |       0 |            0 |            0 |
| `Q11`                 | Choice (yogurt)    | 1.0,2.0                       | 0-1      |    60 |       0 |            0 |            0 |
| `Q12`                 | Choice (cheese)    | 1.0,2.0                       | 0-1      |    60 |       0 |            0 |            0 |
| `Q13`                 | Choice (mayo)      | 1.0,2.0                       | 0-1      |    60 |       0 |            0 |            0 |
| `Q14`                 | Choice (butter)    | 1.0,2.0                       | 0-1      |    60 |       0 |            0 |            0 |
| `Q15`                 | Choice (icecream)  | 1.0,2.0                       | 0-1      |    60 |       0 |            0 |            0 |
| `Q16`                 | Choice (sausages)  | 1.0,2.0                       | 0-1      |    60 |       0 |            0 |            0 |
| `Q17`                 | Choice (mince)     | 1.0,2.0                       | 0-1      |    60 |       0 |            0 |            0 |
| `Q18`                 | Choice (meatballs) | 1.0,2.0                       | 0-1      |    60 |       0 |            0 |            0 |
| `Q19`                 | Choice (ham)       | 1.0,2.0                       | 0-1      |    60 |       0 |            0 |            0 |
| `Q20`                 | Choice (patties)   | 1.0,2.0                       | 0-1      |    60 |       0 |            0 |            0 |
| `Q22_1`               | MFQ care           | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |
| `Q22_2`               | MFQ care           | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |
| `Q22_3`               | MFQ care           | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |
| `Q22_4`               | MFQ purity         | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |
| `Q22_5`               | MFQ purity         | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |
| `Q22_6`               | MFQ purity         | 1.0,2.0,3.0,4.0,5.0           | 0-5      |    60 |       0 |            0 |            0 |
| `Q22_7`               | Filler             | 1.0,2.0,3.0,4.0,6.0           | 0-5      |    60 |       0 |            0 |            0 |
| `Q23_1`               | MFQ care           | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |
| `Q23_2`               | MFQ care           | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |
| `Q23_3`               | MFQ care           | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |
| `Q23_4`               | MFQ purity         | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |
| `Q23_5`               | MFQ purity         | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |
| `Q23_6`               | MFQ purity         | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |
| `Q23_7`               | Filler             | 1.0,2.0,3.0,4.0,5.0,6.0       | 0-5      |    60 |       0 |            0 |            0 |

**Result:** 0 invalid codes, 0 out-of-range values and 0 missing values
among completers.

### 4.1 Logical checks

| Check                                            | Result                                                                                  |
|:-------------------------------------------------|:----------------------------------------------------------------------------------------|
| Attention check passed                           | **49 of 60 (82%).** control 34 of 42; harm 8 of 9; purity 7 of 9.                       |
| Attention check answers by group (codes 1/2/3/4) | control 2/4/34/2; harm 0/8/1/0; purity 7/2/0/0                                          |
| `VU treatment` codes by `Group`                  | Columns 0 / 1 / 2 / NA: CZG T1 0 / 0 / 0 / 9; CZG T2 0 / 0 / 0 / 9; VU 15 / 14 / 13 / 0 |
| Diet of completers (`Q0b` code: n)               | 1.0: 39; 2.0: 11; 3.0: 5; 4.0: 5                                                        |
| Duplicate flag                                   | 10 of 60 completers have `Q_DuplicateRespondent` = true.                                |
| Duration                                         | Median 1100 s (about 18 min), range 117-5512 s. **6 completers took under 300 s.**      |
| Straight-lining                                  | Same answer on all items: emotions 19, perceived harm 2, MFQ (14 items) 4.              |
| Plant-based choice share per item                | 0.15 (Q12) to 0.58 (Q16).                                                               |

`Q0b` codes: 0 = vegan, 1 = neither vegetarian nor vegan, 2 =
vegetarian, 3 = vegetarian with a non-vegetarian household, 4 = label
unknown. Many respondents straight-lining on the emotion items is
plausible for the control text, where “not at all” is the natural
answer.

### 4.2 Composite scores (descriptive only)

The composites are computed as preregistered. The pilot sample consists
of students and includes vegetarians, and n is small, so the table only
shows that the scores can be computed and behave sensibly. It is not a
test of the hypotheses.

| Score               | Range | Control (n = 42) | Harm (n = 9) | Purity (n = 9) |
|:--------------------|:------|:-----------------|:-------------|:---------------|
| `moralization`      | 1-7   | 3.64 (1.75)      | 3.08 (1.10)  | 3.22 (1.73)    |
| `perceived_harm`    | 1-7   | 3.90 (1.07)      | 3.81 (1.12)  | 4.20 (0.90)    |
| `disgust`           | 0-4   | 0.55 (1.03)      | 1.22 (0.96)  | 1.22 (0.87)    |
| `compassion`        | 0-4   | 1.18 (1.12)      | 2.15 (1.13)  | 1.85 (0.87)    |
| `harm_assoc`        | 1-7   | 5.57 (1.49)      | 5.50 (1.09)  | 6.22 (0.97)    |
| `purity_assoc`      | 1-7   | 5.02 (1.20)      | 4.61 (1.45)  | 5.44 (0.46)    |
| `plant_choice_prop` | 0-1   | 0.40 (0.29)      | 0.45 (0.28)  | 0.38 (0.36)    |
| `mft_care`          | 0-5   | 3.37 (1.03)      | 3.59 (1.02)  | 3.81 (0.75)    |
| `mft_purity`        | 0-5   | 1.87 (0.83)      | 2.54 (0.94)  | 2.56 (0.82)    |

Mean (SD) by group

## 5. Problems to fix before fieldwork

1.  **Q07b and Q07c have non-sequential recode values.** Q07b is coded
    1, 2, 3, 8, 9, 10, 11 and Q07c 1, 2, 3, 4, 8, 9, 10, so “Strongly
    agree” is stored as 3. Analysing the raw codes would be badly wrong.
    In Qualtrics, set *Recode values* for these two matrices to 1-7.
    While there, align the emotions to 0-4 and the MFQ to 0-5, so the
    export matches the questionnaire and the preregistration. Until
    then, use the mapping in Section 4 and confirm the inferred codes.
2.  **There is no country variable.** Every preregistered model needs
    Country.
3.  **The diet screening removes only vegans.** 60 of 60 completers do
    not report a diet that includes meat (`Q0b` codes 2, 3 and 4). The
    preregistration screens out vegetarians, vegans and pescatarians.
    Code 4 has no known label, so add the answer options to the
    questionnaire. Student feedback adds that vegans who were screened
    out without explanation restarted with a false diet answer. The
    screen-out page needs a short message.
4.  **4 socio-demographic items are shown before the screening and
    possibly twice** (Section 3.3). Check the survey flow.
5.  **`Finished` alone cannot identify completers.** Use a non-missing
    `Group` together with Finished = 1, or add an end-of-survey
    embedded-data flag.
6.  **The `id` column is empty.**
7.  **The end redirect returns a 401 error.** This comes from the
    student feedback: students saw `{"success":false,"code":401,...}`
    after submitting. Fix it together with the panel provider’s end
    link.
8.  **Some socio-demographic items need validation, although they are
    outside the main study.**
    - `Q30` and `Q31` allow multiple answers to single-choice questions
      (5 and 2 completers respectively).
    - `Q35.family_1` uses the codes 1, 13, 25, 37, 49, 61, 73, 121.
    - `Q39` food expenditure has no bounds: 2 values are above 10,000,
      with a maximum of 1e+30. Add a numeric range validation and state
      the currency.

## 6. Points that need clarification

9.  **What is `VU treatment` (0/1/2)?** It is filled only for the VU
    group, which fits a second-study condition randomized among control
    participants. Please confirm.
10. **What do `Q0b` code 4 and `Q32.gender` code 2 mean?** Neither label
    is available in the export.
11. **Randomization orders are not exported.** Enable “Export viewing
    order data for randomized surveys” in Qualtrics.
12. **The Q04 wording differs.** Qualtrics reads “When thinking about
    the text…”, while the questionnaire and preregistration read “While
    reading the text…”.
13. **The MFQ scoring key is an assumption.** The report uses Q22_1-3
    and Q23_1-3 for care, Q22_4-6 and Q23_4-6 for purity, and Q22_7 and
    Q23_7 as fillers.
14. **How should speeders, duplicates and attention-check failures be
    handled?** The preregistration excludes only non-completers and uses
    attention-check failures in a sensitivity analysis. Decide whether
    to preregister handling for completion times under 300 s and for the
    `Q_DuplicateRespondent` flag.

## 7. Outputs

Rendering this file also writes these files to the working directory:

| File                           | Content                                                       |
|--------------------------------|---------------------------------------------------------------|
| `pilot_check_summary.csv`      | The range-check table (Section 4)                             |
| `pilot_check_values_long.csv`  | Frequency of every raw code per item                          |
| `pilot_recoded_main_study.rds` | Recoded items and preregistered composites for the completers |
