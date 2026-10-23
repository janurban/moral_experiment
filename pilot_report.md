# Pilot Variable Check Report

**Study:** Moral framing of animal-based consumption (main study, Q01–Q23)  
**Data:** `pilot_data.xlsx`, downloaded from GitHub (janurban/moral_experiment). This is a Qualtrics export with numeric codes.

## 0. Data download and date filter

The script downloads the data directly from GitHub and keeps only responses that **started after 15 October 2026**, meaning a `StartDate` on or after 16 October 2026 at 00:00 in the Qualtrics export time zone.

```r
library(readxl)

# Download pilot data from GitHub
data_url  <- "https://github.com/janurban/moral_experiment/raw/refs/heads/main/pilot_data.xlsx"
data_file <- file.path(tempdir(), "pilot_data.xlsx")
download.file(data_url, destfile = data_file, mode = "wb")

# Read: dates as dates, everything else as text; row 1 of the sheet holds question text
hdr   <- names(read_excel(data_file, n_max = 0))
types <- ifelse(hdr %in% c("StartDate", "EndDate", "RecordedDate"), "date", "text")
raw   <- suppressWarnings(read_excel(data_file, col_types = types))
dat   <- as.data.frame(raw[-1, ])

# Keep responses started after 15 October 2026
cutoff <- as.POSIXct("2026-10-16 00:00:00", tz = "UTC")
dat    <- dat[!is.na(dat$StartDate) & dat$StartDate >= cutoff, ]
```

| Step | n |
|---|---|
| Rows in `pilot_data.xlsx` | 79 |
| Removed by the date filter (StartDate 12–15 Oct 2026) | 7 |
| **Kept** | **72** |

## 1. Summary

| Question | Answer |
|---|---|
| Are all questionnaire variables recorded? | **Yes.** All 53 item variables (Q01–Q23) and `Group` are present, and every column's question text matches the expected item. |
| Are their ranges correct? | **Yes, after recoding, but the raw codes are not on the questionnaire scales.** Every observed code maps to a valid questionnaire value, with 0 invalid codes and 0 out-of-range values. However, the Qualtrics recode values for Q07b and Q07c are non-sequential (codes 8–11), and emotions and the MFQ are coded starting at 1 instead of 0. See problem 1. |
| Is something missing or unclear? | **Yes.** There are 8 problems to fix before fieldwork (Section 5) and 6 points to clarify (Section 6). |

## 2. Sample after the date filter

| Subset | n |
|---|---|
| Kept after the date filter | 72 |
| Screened out (`Q0b` = 0, vegan; `Last Seen Flow Element ID` = FL_29) | 11 |
| Assigned to a treatment group | 61 |
| Dropped out after assignment (Progress 15%, Finished = 0, FL_57) | 1 |
| **Completers (assigned and finished)** | **60** |
| Control (`Group` = VU) | 42 |
| Harm-care (`Group` = CZG T1) | 9 |
| Purity (`Group` = CZG T2) | 9 |

The allocation of 42 : 9 : 9 is close to the 4 : 1 : 1 target, which would be 40 : 10 : 10. The range check and all later sections use the 60 completers.

## 3. Presence check

### 3.1 Questionnaire variables

All questionnaire variables are present, and each column's question text matches the expected item.

| Questionnaire block | Variables | Items | Status |
|---|---|---|---|
| Q01 Diet screening | `Q0b` | 1 | Present (numeric codes 0–4) |
| Q03 Manipulation | `Group` | 1 | Present; all three groups observed |
| Q04 Emotions | `emotions_1` – `_6` | 6 | Present |
| Q05 Attention check | `attention check` | 1 | Present |
| Q06 Moralization | `moralization_1` – `_4` | 4 | Present |
| Q07 Perceived harm | `Q07a_1`–`_4`, `Q07b_1`–`_4`, `Q07c_1`–`_4` | 12 | Present (problematic codes in b and c) |
| Q08 Association check | `association check_1` – `_4` | 4 | Present |
| Q10–Q20 Choice task | `Q10` – `Q20` | 11 | Present (1 = animal-based, 2 = plant-based) |
| Q22 MFQ relevance | `Q22_1` – `_7` | 7 | Present |
| Q23 MFQ agreement | `Q23_1` – `_7` | 7 | Present |

### 3.2 Variables required by the preregistration but not in the data

| Needed for | Variable | Status |
|---|---|---|
| All models | Country | **Missing.** `UserLanguage` is "EN" for every respondent. |
| Participant identifier | `id` | **Empty** for every respondent. |
| Randomization checks | Display-order (`_DO`) columns | **Not exported.** |
| Exclusion of non-completers | Completion flag | `Finished` marks the one drop-out (0), but screened-out respondents also have Finished = 1. |

### 3.3 Columns in the data not described in the questionnaire

The file has 189 columns. Besides the 13 Qualtrics metadata columns and the questionnaire variables, it contains 121 columns that the questionnaire does not describe:

| Group | Columns | n |
|---|---|---|
| Socio-demographics | `food_decision_maker`, `Q39.food_expenditure`, `Q42.shopping_channel`, `Q43.meal_outside`, `Q29. reason_nobuy`, `Q29. reason_nobuy_11_TEXT`, `Q120. reason_buy`, `Q31.difficult_nomeat`, `Q40.peer_effect`, `Q30.meat_culture_fit`, `Q45.nutrition_aware`, `Q46.health_concern`, `Q47.physical_days`, `Q32.gender`, `Q33.year`, `Q34.area`, `Q35.family_1`, `Q35.family_2`, `Q36.edu`, `Q37.employment`, `Q38.income`, `Q44.environ_member` | 22 |
| Second study (shopping tasks) | `baseline_*` (20), `task1_*` (26), `task2_*` (26), `task3_*` (26) | 98 |
| Unclear | `VU treatment` | 1 |

**Four socio-demographic items come before the diet screening.** `food_decision_maker`, `Q39.food_expenditure`, `Q42.shopping_channel` and `Q43.meal_outside` sit before `Q0b` in the column order, and screened-out respondents answered them. This matches the student reports that the food-spending questions "repeated twice, at the start and then again later". Each item has only one column, so if an item is shown twice, the second showing is either not recorded or overwrites the first answer. This needs checking in the survey flow.

## 4. Range check (completers, n = 60)

This export contains **numeric codes, not labels**. The script converts each code to its questionnaire value.

The code-to-value mapping was **verified** against a Qualtrics label export (`dataset.xlsx`) for the 9 respondents present in both files. Codes that did not occur among those 9 are marked as inferred in the rules below and should be confirmed in Qualtrics.

**Recoding rules (raw code → questionnaire value)**

- **Emotions:** 1–5 → 0–4. Code 1 = Not at all, 2 = Slightly, 3 = Moderately and 5 = Very much were verified; 4 = Quite a bit is inferred.
- **Attention check:** 1–4 unchanged. Code 2 = animal suffering and 3 = sleep were verified; 1 = pollution/hygiene and 4 = exercise are inferred.
- **Moralization, Q07a, association check:** 1–7 unchanged.
- **Q07b:** 1→1, 2→2, **8→3, 9→4, 10→5, 11→6, 3→7**. The code 9→4 is inferred.
- **Q07c:** 1→1, 2→2, **8→3, 9→4, 10→5, 3→6, 4→7**. The codes 2→2 and 8→3 are inferred.
- **Choice Q10–Q20:** 1 → 0 (animal-based), 2 → 1 (plant-based). Verified.
- **Q22 and Q23 (MFQ):** 1–6 → 0–5.

| Variable | Construct | Raw codes observed | Expected (recoded) | Valid | Missing | Invalid code | Out of range | Observed min–max |
|---|---|---|---|---|---|---|---|---|
| `emotions_1` | Disgust | 1,2,3,4,5 | 0–4 | 60 | 0 | 0 | 0 | 0–4 |
| `emotions_2` | Disgust | 1,2,3,4,5 | 0–4 | 60 | 0 | 0 | 0 | 0–4 |
| `emotions_3` | Disgust | 1,2,3,4,5 | 0–4 | 60 | 0 | 0 | 0 | 0–4 |
| `emotions_4` | Compassion | 1,2,3,4,5 | 0–4 | 60 | 0 | 0 | 0 | 0–4 |
| `emotions_5` | Compassion | 1,2,3,4,5 | 0–4 | 60 | 0 | 0 | 0 | 0–4 |
| `emotions_6` | Compassion | 1,2,3,4,5 | 0–4 | 60 | 0 | 0 | 0 | 0–4 |
| `attention check` | Attention check | 1,2,3,4 | 1–4 | 60 | 0 | 0 | 0 | 1–4 |
| `moralization_1` | Moralization | 1,2,3,4,5,6,7 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `moralization_2` | Moralization | 1,2,3,4,5,6,7 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `moralization_3` | Moralization | 1,2,3,4,5,6,7 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `moralization_4` | Moralization | 1,2,3,4,5,6,7 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `Q07a_1` | Perceived harm | 1,2,3,4,5,6 | 1–7 | 60 | 0 | 0 | 0 | 1–6 |
| `Q07a_2` | Perceived harm | 1,2,3,4,5,6 | 1–7 | 60 | 0 | 0 | 0 | 1–6 |
| `Q07a_3` | Perceived harm | 1,2,3,4,5,6,7 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `Q07a_4` | Perceived harm | 2,3,4,5,6,7 | 1–7 | 60 | 0 | 0 | 0 | 2–7 |
| `Q07b_1` | Perceived harm | 1,2,8,9,10,11 | 1–7 | 60 | 0 | 0 | 0 | 1–6 |
| `Q07b_2` | Perceived harm | 1,2,8,9,10,11 | 1–7 | 60 | 0 | 0 | 0 | 1–6 |
| `Q07b_3` | Perceived harm | 1,2,3,8,9,10,11 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `Q07b_4` | Perceived harm | 1,2,3,8,9,10,11 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `Q07c_1` | Perceived harm | 1,2,3,8,9,10 | 1–7 | 60 | 0 | 0 | 0 | 1–6 |
| `Q07c_2` | Perceived harm | 1,2,3,8,9,10 | 1–7 | 60 | 0 | 0 | 0 | 1–6 |
| `Q07c_3` | Perceived harm | 1,2,3,4,8,9,10 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `Q07c_4` | Perceived harm | 1,2,3,4,8,9,10 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `association check_1` | Harm assoc. | 1,2,4,5,6,7 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `association check_2` | Harm assoc. | 1,2,3,4,5,6,7 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `association check_3` | Purity assoc. | 2,3,4,5,6,7 | 1–7 | 60 | 0 | 0 | 0 | 2–7 |
| `association check_4` | Purity assoc. | 1,2,3,4,5,6,7 | 1–7 | 60 | 0 | 0 | 0 | 1–7 |
| `Q10` | Choice (drink) | 1,2 | 0–1 | 60 | 0 | 0 | 0 | 0–1 |
| `Q11` | Choice (yogurt) | 1,2 | 0–1 | 60 | 0 | 0 | 0 | 0–1 |
| `Q12` | Choice (cheese) | 1,2 | 0–1 | 60 | 0 | 0 | 0 | 0–1 |
| `Q13` | Choice (mayo) | 1,2 | 0–1 | 60 | 0 | 0 | 0 | 0–1 |
| `Q14` | Choice (butter) | 1,2 | 0–1 | 60 | 0 | 0 | 0 | 0–1 |
| `Q15` | Choice (icecream) | 1,2 | 0–1 | 60 | 0 | 0 | 0 | 0–1 |
| `Q16` | Choice (sausages) | 1,2 | 0–1 | 60 | 0 | 0 | 0 | 0–1 |
| `Q17` | Choice (mince) | 1,2 | 0–1 | 60 | 0 | 0 | 0 | 0–1 |
| `Q18` | Choice (meatballs) | 1,2 | 0–1 | 60 | 0 | 0 | 0 | 0–1 |
| `Q19` | Choice (ham) | 1,2 | 0–1 | 60 | 0 | 0 | 0 | 0–1 |
| `Q20` | Choice (patties) | 1,2 | 0–1 | 60 | 0 | 0 | 0 | 0–1 |
| `Q22_1` | MFQ care | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q22_2` | MFQ care | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q22_3` | MFQ care | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q22_4` | MFQ purity | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q22_5` | MFQ purity | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q22_6` | MFQ purity | 1,2,3,4,5 | 0–5 | 60 | 0 | 0 | 0 | 0–4 |
| `Q22_7` | Filler | 1,2,3,4,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q23_1` | MFQ care | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q23_2` | MFQ care | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q23_3` | MFQ care | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q23_4` | MFQ purity | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q23_5` | MFQ purity | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q23_6` | MFQ purity | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
| `Q23_7` | Filler | 1,2,3,4,5,6 | 0–5 | 60 | 0 | 0 | 0 | 0–5 |
**Result:** every observed code maps to a valid questionnaire value. There are no invalid codes, no out-of-range values, and no missing values among completers.

### 4.1 Logical checks

| Check | Result |
|---|---|
| Attention check passed | **49 of 60 (82%).** Control 34 of 42 (81%): 4 chose the harm text, 2 the purity text and 2 exercise. Harm 8 of 9. Purity 7 of 9. |
| Allocation | 42 : 9 : 9 (target 4 : 1 : 1) |
| `VU treatment` | Filled only for the VU group: 15 / 14 / 13 for codes 0 / 1 / 2. It is empty for both treatment groups. |
| Diet of completers (`Q0b`) | 39 have code 1 ("Neither vegetarian nor vegan"), 11 code 2 (vegetarian), 5 code 3 (vegetarian, household not), and 5 code 4 (label unknown). |
| Duplicate flag | 10 of 60 completers have `Q_DuplicateRespondent` = true. |
| Duration | Median 1,100 s (about 18 min), range 117–5,512 s. **6 completers took under 300 s** (117–184 s) for both studies combined. |
| Straight-lining | 19 respondents gave the same answer to all 6 emotion items. This is plausible for the control text ("not at all"). 2 did so on all 12 perceived-harm items and 4 on all 14 MFQ items. |
| Choice task | The share of plant-based choices per item ranges from 0.15 (Q12 cheese) to 0.58 (Q16 sausages). |

### 4.2 Composite scores (descriptive only)

The composites are computed as preregistered and are shown as mean (SD). The pilot sample consists of students and includes vegetarians, and n is very small, so this table only shows that the scores can be computed and behave sensibly. It is not a test of the hypotheses.

| Score | Range | Control (n = 42) | Harm (n = 9) | Purity (n = 9) |
|---|---|---|---|---|
| `moralization` | 1–7 | 3.64 (1.75) | 3.08 (1.10) | 3.22 (1.73) |
| `perceived_harm` | 1–7 | 3.90 (1.07) | 3.81 (1.12) | 4.20 (0.90) |
| `disgust` | 0–4 | 0.55 (1.03) | 1.22 (0.96) | 1.22 (0.87) |
| `compassion` | 0–4 | 1.18 (1.12) | 2.15 (1.13) | 1.85 (0.87) |
| `harm_assoc` | 1–7 | 5.57 (1.49) | 5.50 (1.09) | 6.22 (0.97) |
| `purity_assoc` | 1–7 | 5.02 (1.20) | 4.61 (1.45) | 5.44 (0.46) |
| `plant_choice_prop` | 0–1 | 0.40 (0.29) | 0.45 (0.28) | 0.38 (0.36) |
| `mft_care` | 0–5 | 3.37 (1.03) | 3.59 (1.02) | 3.81 (0.75) |
| `mft_purity` | 0–5 | 1.87 (0.83) | 2.54 (0.94) | 2.56 (0.82) |
The direction of the manipulation checks looks reasonable. Compassion is highest in the harm group, disgust is higher in both message groups than in control, and harm and purity associations are highest in the purity group.

## 5. Problems to fix before fieldwork

1. **Q07b and Q07c have broken recode values.** The codes jump from 2 to 8 and back to 3, so a naive analysis of the raw codes would be badly wrong (for example, "Strongly agree" is coded 3 in Q07b). In Qualtrics, go to *Recode values* for these two matrices and set them to 1–7. While there, align emotions to 0–4 and the MFQ to 0–5, so the export matches the questionnaire and the preregistration. Until then, use the mapping in the script and confirm the inferred codes.
2. **There is no country variable.** Every preregistered model needs Country.
3. **The diet screening only removes vegans.** Vegetarian codes 2 and 3, and code 4, proceed to the experiment, and 21 of 60 completers are not people who eat meat. The preregistration screens out vegetarians, vegans and pescatarians. Code 4 has no known label (it may be pescatarian), so please add the answer options to the questionnaire. Student feedback adds that vegans restarted with a false diet answer after being screened out without explanation. The screen-out page needs a short message.
4. **Four socio-demographic items are shown before the screening and possibly twice.** These are `food_decision_maker`, `Q39`, `Q42` and `Q43` (Section 3.3). Check the survey flow.
5. **`Finished` alone cannot identify completers.** Use a non-missing `Group` together with Finished = 1, or add an end-of-survey embedded-data flag.
6. **The `id` column is empty.**
7. **The end redirect returns a 401 error.** This comes from the student feedback, not the data. About 10 students saw `{"success":false,"code":401,...}` after submitting, which needs fixing together with the panel provider's end link.
8. **Some socio-demographic items need validation, although they are outside the main study.** `Q30` and `Q31` allow multiple answers to single-choice questions (values like "1,7,2"). `Q35.family_1` uses odd codes (1, 13, 25, 37 … 121). `Q39` food expenditure has no bounds, and the data contain 600,000,000 and 1×10³⁰. Use a numeric range validation and state the currency.

## 6. Points that need clarification

9. **What is `VU treatment` (0/1/2)?** It is filled only and evenly within the control group, which fits a second-study condition randomized among control participants. Please confirm. If so, note that the second study's design then depends on the first study's group.
10. **What does `Q0b` code 4 mean, and what does `Q32.gender` code 2 mean?** Neither label is available in any export.
11. **Randomization orders are not exported.** Enable "Export viewing order data for randomized surveys" in Qualtrics.
12. **The Q04 wording differs.** Qualtrics reads "When thinking about the text…", while the questionnaire and preregistration read "While reading the text…".
13. **The MFQ scoring key is an assumption.** The script uses Q22_1–3 and Q23_1–3 for care, Q22_4–6 and Q23_4–6 for purity, and Q22_7 and Q23_7 as fillers.
14. **How should speeders, duplicates and attention-check failures be handled?** The preregistration only excludes non-completers, and handles attention-check failures in a sensitivity analysis. Decide whether to preregister handling for completion times under 300 s and for the `Q_DuplicateRespondent` flag.

## 7. Outputs of the R script

| File | Content |
|---|---|
| Console report | Download, date filter, presence, sample, range and logical checks, composites by group |
| `pilot_check_summary.csv` | One row per item: raw codes observed, expected range, n valid, missing, invalid, out of range, observed min/max |
| `pilot_check_values_long.csv` | Frequency of every raw code per item |
| `pilot_recoded_main_study.rds` | Recoded items and preregistered composites for the 60 completers |
