# Variable Check Report

**Study:** Moral framing of animal-based consumption (main study, Q01–Q23)  
**Data file:** `dataset.xlsx` (Qualtrics export, test data collected 12–16 October 2026)  
**Reference documents:** `questionnaire.docx`, `pre-registration.docx`  
**Script:** `01_check_variables.R`  
**Report date:** 23 October 2026

> **Note on how these results were produced.** R was not available in the environment where this report was prepared. The checks were run with an equivalent Python implementation of the same logic on the same file. The R script has not yet been executed and should be run once to confirm these numbers.

## 1. Summary

| Question | Answer |
|---|---|
| Are all questionnaire variables recorded? | **Yes.** All 53 item variables (Q01–Q23) and the treatment variable `Group` are present. Each column's question text matches the expected item. |
| Are their ranges correct? | **Yes.** All values map onto the questionnaire scales. There are no unmapped labels and no out-of-range values. |
| Is something missing or unclear? | **Yes.** There are 6 problems to fix before fieldwork (most importantly, no country variable and screening that does not work) and 6 points that need clarification. See Sections 5 and 6. |

## 2. Data overview

The file contains **9 respondents** and **189 columns**. The first row holds variable names and the second row holds question text.

| Subset | n |
|---|---|
| Screened out (vegan; `Last Seen Flow Element ID` = FL_29) | 3 |
| Assigned to a treatment group (FL_16) | 6 |
| Control (`Group` = VU) | 5 |
| Harm-care (`Group` = CZG T1) | 1 |
| Purity (`Group` = CZG T2) | 0 |

Treatment coding, as confirmed by the team: **VU** = control, **CZG T1** = harm-care, **CZG T2** = purity.

## 3. Presence check

### 3.1 Questionnaire variables

| Questionnaire block | Variables in data | Items | Status |
|---|---|---|---|
| Q01 Diet screening | `Q0b` | 1 | Present |
| Q03 Manipulation | `Group` | 1 | Present (CZG T2 not yet observed) |
| Q04 Emotions | `emotions_1` – `emotions_6` | 6 | Present, text matches |
| Q05 Attention check | `attention check` | 1 | Present, text matches |
| Q06 Moralization | `moralization_1` – `moralization_4` | 4 | Present, text matches |
| Q07 Perceived harm | `Q07a_1`–`_4`, `Q07b_1`–`_4`, `Q07c_1`–`_4` | 12 | Present, text matches |
| Q08 Association check | `association check_1` – `_4` | 4 | Present, text matches |
| Q10–Q20 Choice task | `Q10` – `Q20` | 11 | Present; products match the questionnaire images |
| Q22 MFQ relevance | `Q22_1` – `Q22_7` | 7 | Present, text matches |
| Q23 MFQ agreement | `Q23_1` – `Q23_7` | 7 | Present, text matches |

The choice items correspond to the questionnaire images as follows: Q10 = milk vs. oat drink, Q11 = yogurt vs. soya yogurt, Q12 = cheese slices, Q13 = mayo, Q14 = butter, Q15 = ice cream, Q16 = sausages, Q17 = minced meat, Q18 = meatballs, Q19 = ham, Q20 = burger patties. A plant-based choice is coded as `<product> plant`.

### 3.2 Variables required by the preregistration but not in the data

| Needed for | Variable | Status |
|---|---|---|
| All models (fixed effect) | Country | **Missing.** `UserLanguage` is "EN" for every respondent. |
| Participant identifier | `id` | Column exists but is **empty** for all respondents. |
| Randomization checks (block order, item order, left/right position) | Display-order (`_DO`) columns | **Not exported.** |
| Exclusion of non-completers | Completion flag | `Finished` cannot be used for this (see Section 5). |

### 3.3 Columns in the data not described in the questionnaire (121, plus 13 Qualtrics metadata columns)

| Group | Columns | n |
|---|---|---|
| Socio-demographics | `Q29. reason_nobuy`, `Q29. reason_nobuy_11_TEXT`, `Q30.meat_culture_fit`, `Q31.difficult_nomeat`, `Q32.gender`, `Q33.year`, `Q34.area`, `Q35.family_1`, `Q35.family_2`, `Q36.edu`, `Q37.employment`, `Q38.income`, `Q39.food_expenditure`, `food_decision_maker`, `Q40.peer_effect`, `Q41.animal_lover`, `Q42.shopping_channel`, `Q43.meal_outside`, `Q44.environ_member`, `Q45.nutrition_aware`, `Q46.health_concern`, `Q47.physical_days` | 22 |
| Second study (shopping tasks) | `baseline_*` (20), `task1_*` (26), `task2_*` (26), `task3_*` (26). Per product (pork, beef, chicken, cheese, plantmeat, vegancheese): price, qty, total, and delta (tasks only), plus `_order` and `_cart_total` | 98 |
| Unclear | `VU treatment` (values 0/1/2) | 1 |
| Qualtrics metadata | `StartDate` … `Last Seen Question IDs` | 13 |

## 4. Range check

The range check covers respondents assigned to a treatment group (n = 6). The export stores text labels, such as "Very much", "7 (Strongly agree)", and the long MFQ labels. These were recoded to the numbers given in the questionnaire.

**Recoding rules**

- **Emotions:** Not at all = 0, Slightly = 1, Moderately = 2, Quite a bit = 3, Very much = 4.
- **Attention check:** codes 1–4, following the order of options in the questionnaire. The correct answer is 3 for control, 2 for harm, and 1 for purity.
- **Moralization, perceived harm, association check:** the leading integer of the label (1–7).
- **Choice:** `<product> plant` = 1 (plant-based), `<product>` = 0 (animal-based).
- **Q22:** Completely irrelevant = 0 … Extremely relevant = 5.
- **Q23:** Strongly disagree = 0 … Strongly agree = 5.

| Variable | Construct | Expected | Valid | Missing | Unmapped | Out of range | Observed min–max |
|---|---|---|---|---|---|---|---|
| `emotions_1` | Disgust | 0–4 | 6 | 0 | 0 | 0 | 0–4 |
| `emotions_2` | Disgust | 0–4 | 6 | 0 | 0 | 0 | 0–4 |
| `emotions_3` | Disgust | 0–4 | 6 | 0 | 0 | 0 | 0–4 |
| `emotions_4` | Compassion | 0–4 | 6 | 0 | 0 | 0 | 0–4 |
| `emotions_5` | Compassion | 0–4 | 6 | 0 | 0 | 0 | 0–4 |
| `emotions_6` | Compassion | 0–4 | 6 | 0 | 0 | 0 | 0–4 |
| `attention check` | Attention check | 1–4 | 6 | 0 | 0 | 0 | 2–3 |
| `moralization_1` | Moralization | 1–7 | 6 | 0 | 0 | 0 | 4–7 |
| `moralization_2` | Moralization | 1–7 | 6 | 0 | 0 | 0 | 1–7 |
| `moralization_3` | Moralization | 1–7 | 6 | 0 | 0 | 0 | 1–7 |
| `moralization_4` | Moralization | 1–7 | 6 | 0 | 0 | 0 | 3–7 |
| `Q07a_1` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 1–5 |
| `Q07a_2` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 1–5 |
| `Q07a_3` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 2–7 |
| `Q07a_4` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 3–7 |
| `Q07b_1` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 1–6 |
| `Q07b_2` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 1–6 |
| `Q07b_3` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 5–7 |
| `Q07b_4` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 5–7 |
| `Q07c_1` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 1–6 |
| `Q07c_2` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 1–6 |
| `Q07c_3` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 4–7 |
| `Q07c_4` | Perceived harm | 1–7 | 5 | 1 | 0 | 0 | 4–7 |
| `association check_1` | Harm assoc. | 1–7 | 6 | 0 | 0 | 0 | 4–7 |
| `association check_2` | Harm assoc. | 1–7 | 6 | 0 | 0 | 0 | 4–7 |
| `association check_3` | Purity assoc. | 1–7 | 6 | 0 | 0 | 0 | 4–7 |
| `association check_4` | Purity assoc. | 1–7 | 6 | 0 | 0 | 0 | 2–7 |
| `Q10` | Choice (drink) | 0–1 | 6 | 0 | 0 | 0 | 0–1 |
| `Q11` | Choice (yogurt) | 0–1 | 6 | 0 | 0 | 0 | 0–0 |
| `Q12` | Choice (cheese) | 0–1 | 6 | 0 | 0 | 0 | 0–1 |
| `Q13` | Choice (mayo) | 0–1 | 6 | 0 | 0 | 0 | 0–1 |
| `Q14` | Choice (butter) | 0–1 | 6 | 0 | 0 | 0 | 0–1 |
| `Q15` | Choice (icecream) | 0–1 | 6 | 0 | 0 | 0 | 0–1 |
| `Q16` | Choice (sausages) | 0–1 | 6 | 0 | 0 | 0 | 0–1 |
| `Q17` | Choice (mince) | 0–1 | 6 | 0 | 0 | 0 | 0–1 |
| `Q18` | Choice (meatballs) | 0–1 | 6 | 0 | 0 | 0 | 0–1 |
| `Q19` | Choice (ham) | 0–1 | 6 | 0 | 0 | 0 | 0–1 |
| `Q20` | Choice (patties) | 0–1 | 6 | 0 | 0 | 0 | 0–1 |
| `Q22_1` | MFQ care | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
| `Q22_2` | MFQ care | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
| `Q22_3` | MFQ care | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
| `Q22_4` | MFQ purity | 0–5 | 6 | 0 | 0 | 0 | 0–4 |
| `Q22_5` | MFQ purity | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
| `Q22_6` | MFQ purity | 0–5 | 6 | 0 | 0 | 0 | 0–4 |
| `Q22_7` | Filler | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
| `Q23_1` | MFQ care | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
| `Q23_2` | MFQ care | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
| `Q23_3` | MFQ care | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
| `Q23_4` | MFQ purity | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
| `Q23_5` | MFQ purity | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
| `Q23_6` | MFQ purity | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
| `Q23_7` | Filler | 0–5 | 6 | 0 | 0 | 0 | 0–5 |
**Result: all 53 items fall within the questionnaire range.** No labels failed to map. The 12 missing values in Q07 all come from a single respondent (problem 3 below). One item, `Q11`, shows no variance (problem 4 below).

### 4.1 Logical checks

| Check | Result |
|---|---|
| Attention check passed | Control 4 of 5; harm 1 of 1. One control respondent (R_23vTaCj2daevBHV, 123 s) chose the animal-suffering option. |
| Allocation ratio (target 4 : 1 : 1) | 5 : 1 : 0. This is not interpretable at n = 6. |
| Straight-lining | 3 respondents gave the same answer to all 6 emotion items. 2 respondents gave the same answer to every MFQ item. |
| Composite scores | All of them (moralization, perceived harm, disgust, compassion, harm and purity association, plant-choice proportion, MFT care, MFT purity) can be computed. The MFQ yields 6 care items and 6 purity items, as preregistered. |

## 5. Problems to fix before fieldwork

1. **There is no country variable.** Every preregistered model includes Country. A country column needs to be added to the export, for example as embedded data per panel or language version.
2. **The diet screening does not work.** Three self-described vegetarians ("Vegetarian – …" and "I am a vegetarian, but someone else in my household is not") were assigned to a group and completed the study. The preregistration says vegetarians, vegans and pescatarians are screened out. In addition, the answer options are not in the questionnaire (it has only a placeholder), there is no pescatarian option, and the option "Neither Vegeterian nor Vegan" contains a typo.
3. **Forced response is missing on Q07.** Respondent R_8z1rY4gjEBjnRyV has no answers on any of the 12 perceived-harm items. The questionnaire and preregistration state that every answer is required.
4. **Q11 may be miscoded.** All 6 respondents have "yogurt" and none has "yogurt plant", while every other choice item varies. Check in Qualtrics that the soya yogurt option has the recode value `yogurt plant`.
5. **`Finished` cannot identify completers.** Screened-out respondents also have Finished = True and Progress = 100. The preregistered exclusion rule ("did not complete") needs another indicator, for example `Last Seen Flow Element ID`, a non-missing `Group`, or an end-of-survey embedded-data flag.
6. **The `id` column is empty** for all respondents.

## 6. Points that need clarification

7. **`VU treatment` (0/1/2).** This column is not in the questionnaire. It is filled only for the VU group and does not match the Q03 treatment. It is presumably the second study's condition. Please confirm.
8. **Randomization orders are not exported.** The preregistration describes randomized block order (Q04–Q08), item order, Q22/Q23 order, and left/right position of products. To check these, enable "Export viewing order data for randomized surveys" in Qualtrics.
9. **The Q04 wording differs.** Qualtrics reads "When thinking about the text, to what extent did you feel the following emotions?" The questionnaire and preregistration read "While reading the text, to what extent did you feel the following?"
10. **The MFQ scoring key is an assumption.** The script uses Q22_1–3 and Q23_1–3 as care items, Q22_4–6 and Q23_4–6 as purity items, and Q22_7 (math) and Q23_7 (better to do good) as fillers. Please confirm.
11. **There are data-quality signals, likely because this is test data.** Five of the 9 rows are flagged `Q_DuplicateRespondent`. Completion times among assigned respondents range from 123 s to 5,326 s.
12. **Some socio-demographic items need attention, although they are outside the scope of this check.** Q38 asks for net annual income, but its text says "each month". Q39 food spending is free text with no currency or bounds. One birth year is 1926. One household has 10 adults and 10 children. Q29 contains typos ("infomation", "reluction"). Q45 labels contain trailing line breaks.

## 7. Outputs of the R script

| File | Content |
|---|---|
| Console report | Sections 3–8 as above |
| `check_variables_summary.csv` | One row per item: expected range, n valid, n missing, n unmapped, n out of range, observed min/max |
| `check_values_long.csv` | Frequency of every raw label per item |
| `recoded_main_study.rds` | Numerically recoded items plus preregistered composite scores |
