# =============================================================================
# Moral framing of animal-based consumption
# 01_check_variables.R
#
# Purpose: check that every variable described in the questionnaire (Q01-Q23)
#          is present in the Qualtrics export, that its values fall inside the
#          response scale given in the questionnaire, and flag anything that is
#          missing, unexpected or unclear.
#
# Input : dataset.xlsx (Qualtrics export, row 1 = variable names,
#                       row 2 = question text, data from row 3)
# Output: printed report + check_variables_summary.csv + check_values_long.csv
#
# Treatment coding (column "Group", confirmed by the team):
#   VU     = control (sleep text)
#   CZG T1 = harm-care text
#   CZG T2 = purity text
# =============================================================================

# ---- 0. Setup ---------------------------------------------------------------
# install.packages("readxl")   # only package needed; everything else is base R
library(readxl)

data_file <- "dataset.xlsx"     # adjust path if needed
out_dir   <- "."                # where the csv outputs go

# ---- 1. Read data -----------------------------------------------------------
# Read everything as text so that no value is silently coerced by readxl.
raw <- read_excel(data_file, col_names = TRUE, col_types = "text")

# Row 1 of the data frame is the Qualtrics question-text row: keep it as labels
labels <- unlist(raw[1, ], use.names = TRUE)
dat    <- as.data.frame(raw[-1, ], stringsAsFactors = FALSE)
names(labels) <- names(dat)

cat("Rows (respondents) in file:", nrow(dat), "\n")
cat("Columns in file:           ", ncol(dat), "\n\n")

# ---- 2. Helper functions ----------------------------------------------------
trim <- function(x) gsub("^\\s+|\\s+$", "", gsub("[\r\n]+", " ", x))

# Recode text labels to numbers. `map` is a named numeric vector
# (names = labels). With prefix = TRUE a value matches if it STARTS with the
# label (needed for the long MFQ labels). Unmatched non-missing values -> NA
# and are reported as out of range.
recode_labels <- function(x, map, prefix = FALSE) {
  x   <- trim(x)
  out <- rep(NA_real_, length(x))
  for (lab in names(map)) {
    hit <- if (prefix) startsWith(tolower(x), tolower(lab)) else tolower(x) == tolower(lab)
    out[!is.na(hit) & hit] <- map[[lab]]
  }
  out
}

# Scales where Qualtrics exports "1 (Not at all)", "2", ..., "7 (Very much)":
# take the leading integer.
leading_int <- function(x) {
  x <- trim(x)
  v <- suppressWarnings(as.numeric(sub("^(-?\\d+).*$", "\\1", x)))
  v[!grepl("^-?\\d+", x)] <- NA
  v
}

# ---- 3. Codebook: what the questionnaire says -------------------------------
# One row per item. `scale` names the recoding rule, `min`/`max` the allowed
# range from the questionnaire, `text` a fragment that must appear in the
# Qualtrics question text (checks that item order/mapping is right).

emo_map  <- c("Not at all" = 0, "Slightly" = 1, "Moderately" = 2,
              "Quite a bit" = 3, "Very much" = 4)
att_map  <- c("Animal-based products and their connection to pollution, hygiene, and cleanliness." = 1,
              "Animal-based products and the conditions in which animals are kept, including animal suffering and welfare." = 2,
              "Sleep and its functions for the human body and brain." = 3,
              "Regular exercise and physical fitness." = 4)
mfq1_map <- c("Completely irrelevant" = 0, "Rather irrelevant" = 1,
              "Slightly relevant" = 2, "Quite relevant" = 3,
              "Very relevant" = 4, "Extremely relevant" = 5)
mfq2_map <- c("Strongly disagree" = 0, "Moderately disagree" = 1,
              "Slightly disagree" = 2, "Slightly agree" = 3,
              "Moderately agree" = 4, "Strongly agree" = 5)

products <- c(Q10 = "drink", Q11 = "yogurt", Q12 = "cheese", Q13 = "mayo",
              Q14 = "butter", Q15 = "icecream", Q16 = "sausages",
              Q17 = "mince", Q18 = "meatballs", Q19 = "ham", Q20 = "patties")

cb <- rbind(
  data.frame(q = "Q01", var = "Q0b", scale = "diet", min = NA, max = NA,
             text = "eating habits", construct = "diet screening"),
  data.frame(q = "Q03", var = "Group", scale = "group", min = NA, max = NA,
             text = "Group", construct = "treatment"),
  data.frame(q = "Q04", var = paste0("emotions_", 1:6), scale = "emo", min = 0, max = 4,
             text = c("Disgusted", "Revolted", "Nauseated", "Compassionate", "Sympathetic", "Moved"),
             construct = rep(c("disgust", "compassion"), each = 3)),
  data.frame(q = "Q05", var = "attention check", scale = "att", min = 1, max = 4,
             text = "describes best the text", construct = "attention check"),
  data.frame(q = "Q06", var = paste0("moralization_", 1:4), scale = "int", min = 1, max = 7,
             text = c("core moral beliefs", "right", "moral issue", "just know"),
             construct = "moralization"),
  data.frame(q = "Q07", var = c(paste0("Q07a_", 1:4), paste0("Q07b_", 1:4), paste0("Q07c_", 1:4)),
             scale = "int", min = 1, max = 7,
             text = c("physical harm ... - to me", "physical harm ... - to other people",
                      "physical harm ... - to the environment", "physical harm ... - to animals",
                      "pain and suffering ... - to me", "pain and suffering ... - to other people",
                      "pain and suffering ... - to the environment", "pain and suffering ... - to animals",
                      "mistreats ... - me", "mistreats ... - other people",
                      "mistreats ... - the environment", "mistreats ... - animals"),
             construct = "perceived harm"),
  data.frame(q = "Q08", var = paste0("association check_", 1:4), scale = "int", min = 1, max = 7,
             text = c("pain or distress", "living conditions", "hygienic", "unpleasant smells"),
             construct = rep(c("harm association", "purity association"), each = 2)),
  data.frame(q = names(products), var = names(products), scale = "choice", min = 0, max = 1,
             text = "most likely purchase", construct = "product choice"),
  data.frame(q = "Q22", var = paste0("Q22_", 1:7), scale = "mfq1", min = 0, max = 5,
             text = c("suffered emotionally", "weak or vulnerable", "was cruel",
                      "purity and decency", "something disgusting", "God would approve",
                      "good at math"),
             construct = c(rep("mft_care", 3), rep("mft_purity", 3), "filler")),
  data.frame(q = "Q23", var = paste0("Q23_", 1:7), scale = "mfq2", min = 0, max = 5,
             text = c("Compassion for those", "defenseless animal", "kill a human being",
                      "disgusting, even if no one", "unnatural", "Chastity",
                      "better to do good"),
             construct = c(rep("mft_care", 3), rep("mft_purity", 3), "filler"))
)
rownames(cb) <- NULL

# ---- 4. Presence check ------------------------------------------------------
cb$present <- cb$var %in% names(dat)
cb$text_ok <- mapply(function(v, t) {
  if (!v %in% names(dat)) return(NA)
  if (v == "Group") return(TRUE)
  grepl(t, labels[[v]], fixed = TRUE)
}, cb$var, cb$text)

cat("=== 4. PRESENCE OF QUESTIONNAIRE VARIABLES ===\n")
cat("Expected item variables:", nrow(cb), " | present:", sum(cb$present),
    " | missing:", sum(!cb$present), "\n")
if (any(!cb$present)) print(cb[!cb$present, c("q", "var")])
if (any(cb$text_ok %in% FALSE)) {
  cat("Question text does NOT match expected item (check item order!):\n")
  print(cb[cb$text_ok %in% FALSE, c("var", "text")])
} else cat("All item columns match the expected question text.\n")

# Variables the preregistration needs that are not questionnaire items
needed_extra <- c(country = "Country (fixed effect in every model)",
                  id = "participant id")
cat("\nVariables needed by the analysis plan:\n")
cat("  Country column present?   ", any(tolower(names(dat)) %in% c("country", "q_country")), "\n")
cat("  UserLanguage values:       ", paste(unique(dat$UserLanguage), collapse = ", "), "\n")
cat("  'id' column non-empty:     ", sum(!is.na(dat$id)), "of", nrow(dat), "\n")
cat("  Display-order (_DO) columns present:", any(grepl("_DO", names(dat))), "\n")

meta_vars <- c("StartDate", "EndDate", "Status", "Progress", "Duration (in seconds)",
               "Finished", "RecordedDate", "ResponseId", "DistributionChannel",
               "UserLanguage", "Q_DuplicateRespondent", "Last Seen Flow Element ID",
               "Last Seen Question IDs", "id")
extra <- setdiff(names(dat), c(cb$var, meta_vars))
cat("\nColumns in data NOT described in the questionnaire (", length(extra), "):\n", sep = "")
print(extra)

# ---- 5. Define analysis sample ----------------------------------------------
diet <- trim(dat$Q0b)
dat$screened_out <- grepl("^Vegan|^Vegetarian|pescatarian|I am a vegetarian", diet, ignore.case = TRUE)
dat$group <- factor(c("VU" = "control", "CZG T1" = "harm", "CZG T2" = "purity")[trim(dat$Group)],
                    levels = c("control", "harm", "purity"))

cat("\n=== 5. SAMPLE ===\n")
cat("Diet answers:\n"); print(table(diet, useNA = "ifany"))
cat("\nLast Seen Flow Element ID x Group:\n")
print(table(flow = dat$`Last Seen Flow Element ID`, Group = dat$Group, useNA = "ifany"))
cat("\nFinished:\n"); print(table(dat$Finished, useNA = "ifany"))
cat("\nGroup (raw) -> group (recoded):\n"); print(table(dat$Group, dat$group, useNA = "ifany"))
cat("\nRespondents who should have been screened out but have a Group:",
    sum(dat$screened_out & !is.na(dat$Group)), "\n")
cat("Q_DuplicateRespondent == true:", sum(tolower(dat$Q_DuplicateRespondent) %in% "true"), "\n")
dur <- as.numeric(dat$`Duration (in seconds)`)
cat("Duration (sec) among assigned respondents: ",
    paste(sort(dur[!is.na(dat$Group)]), collapse = ", "), "\n")

# Respondents who reached the experiment (= have a treatment group)
in_exp <- !is.na(dat$group) | !is.na(dat$Group)

# ---- 6. Range check ---------------------------------------------------------
recode_item <- function(v, scale) {
  x <- dat[[v]]
  switch(scale,
         emo    = recode_labels(x, emo_map),
         att    = recode_labels(x, att_map),
         int    = leading_int(x),
         mfq1   = recode_labels(x, mfq1_map, prefix = TRUE),
         mfq2   = recode_labels(x, mfq2_map, prefix = TRUE),
         choice = { p <- products[[v]]; xx <- trim(x)
                    ifelse(xx == paste(p, "plant"), 1, ifelse(xx == p, 0, NA)) },
         stop("unknown scale"))
}

res  <- list()
long <- list()
num  <- data.frame(ResponseId = dat$ResponseId)
for (i in seq_len(nrow(cb))) {
  v <- cb$var[i]; s <- cb$scale[i]
  if (!cb$present[i] || s %in% c("diet", "group")) next
  raw_x <- trim(dat[[v]][in_exp])
  val   <- recode_item(v, s)
  num[[v]] <- val
  val_e <- val[in_exp]
  not_recoded <- !is.na(raw_x) & is.na(val_e)         # value we could not map
  out_range   <- !is.na(val_e) & (val_e < cb$min[i] | val_e > cb$max[i])
  obs_levels  <- sort(unique(val_e[!is.na(val_e)]))
  res[[v]] <- data.frame(
    q = cb$q[i], var = v, construct = cb$construct[i],
    expected = paste0(cb$min[i], "-", cb$max[i]),
    n_in_exp = sum(in_exp), n_valid = sum(!is.na(val_e)),
    n_missing = sum(is.na(raw_x)),
    n_unmapped = sum(not_recoded), n_out_of_range = sum(out_range),
    obs_min = if (length(obs_levels)) min(obs_levels) else NA,
    obs_max = if (length(obs_levels)) max(obs_levels) else NA,
    n_distinct = length(obs_levels),
    unmapped_values = paste(unique(raw_x[not_recoded]), collapse = " | "))
  tb <- table(raw_x, useNA = "ifany")
  long[[v]] <- data.frame(var = v, raw_value = names(tb), n = as.integer(tb))
}
res  <- do.call(rbind, res);  rownames(res)  <- NULL
long <- do.call(rbind, long); rownames(long) <- NULL

cat("\n=== 6. RANGE CHECK (respondents who reached the experiment) ===\n")
print(res[, c("var", "expected", "n_valid", "n_missing", "n_unmapped",
              "n_out_of_range", "obs_min", "obs_max", "n_distinct")], row.names = FALSE)
if (any(res$n_unmapped > 0)) {
  cat("\nValues that could not be mapped onto the questionnaire scale:\n")
  print(res[res$n_unmapped > 0, c("var", "unmapped_values")], row.names = FALSE)
}

# Choice items: any item with no variance is suspicious (possible recode error)
ch <- res[res$construct == "product choice", ]
if (any(ch$n_distinct < 2))
  cat("\nWARNING: choice items with only one observed option:",
      paste(ch$var[ch$n_distinct < 2], collapse = ", "),
      "-> check Qualtrics recode values (is the plant option coded '<product> plant'?)\n")

# Scale labels that never occur in the data (fine in small data, but check)
cat("\nObserved raw labels per item are written to check_values_long.csv\n")

# ---- 7. Logical checks ------------------------------------------------------
cat("\n=== 7. LOGICAL CHECKS ===\n")
# Attention check: correct answer depends on condition
correct <- c(control = 3, harm = 2, purity = 1)
num$group  <- dat$group
num$att_ok <- num$`attention check` == correct[as.character(num$group)]
cat("Attention check passed, by group:\n")
print(table(group = num$group, passed = num$att_ok, useNA = "ifany"))

# Allocation ratio
cat("\nGroup sizes (target 4:1:1):\n"); print(table(dat$group, useNA = "ifany"))
cat("\nGroup x 'VU treatment' (column not in questionnaire - meaning?):\n")
print(table(Group = dat$Group, VU_treatment = dat$`VU treatment`, useNA = "ifany"))

# Completeness of the main block among respondents in the experiment
main_vars <- cb$var[cb$present & !cb$scale %in% c("diet", "group")]
n_miss <- rowSums(is.na(num[in_exp, main_vars]))
cat("\nMissing main items per assigned respondent:", paste(n_miss, collapse = ", "), "\n")

# Straight-lining in batteries (informative only)
sl <- function(vs) apply(num[in_exp, vs], 1, function(r) length(unique(r[!is.na(r)])) == 1)
cat("Straight-lining emotions (6 items):       ", sum(sl(paste0("emotions_", 1:6))), "\n")
cat("Straight-lining perceived harm (12 items):", sum(sl(cb$var[cb$construct == "perceived harm"])), "\n")

# ---- 8. Composite scores (preregistered transformations) --------------------
it <- function(con) cb$var[cb$construct == con]
num$moralization   <- rowMeans(num[, it("moralization")])
num$perceived_harm <- rowMeans(num[, it("perceived harm")])
num$disgust        <- rowMeans(num[, it("disgust")])
num$compassion     <- rowMeans(num[, it("compassion")])
num$harm_assoc     <- rowMeans(num[, it("harm association")])
num$purity_assoc   <- rowMeans(num[, it("purity association")])
num$plant_choice_prop <- rowMeans(num[, names(products)])
num$mft_care       <- rowMeans(num[, it("mft_care")])
num$mft_purity     <- rowMeans(num[, it("mft_purity")])
num$mft_care_z     <- as.numeric(scale(num$mft_care))
num$mft_purity_z   <- as.numeric(scale(num$mft_purity))

comp <- c("moralization", "perceived_harm", "disgust", "compassion", "harm_assoc",
          "purity_assoc", "plant_choice_prop", "mft_care", "mft_purity")
cat("\n=== 8. COMPOSITE SCORES (assigned respondents) ===\n")
print(round(t(sapply(num[in_exp, comp], function(x)
  c(n = sum(!is.na(x)), min = min(x, na.rm = TRUE), mean = mean(x, na.rm = TRUE),
    max = max(x, na.rm = TRUE)))), 2))
cat("Items per composite: care =", length(it("mft_care")),
    "| purity =", length(it("mft_purity")), "(prereg: 6 each)\n")

# ---- 9. Save ----------------------------------------------------------------
write.csv(res,  file.path(out_dir, "check_variables_summary.csv"), row.names = FALSE)
write.csv(long, file.path(out_dir, "check_values_long.csv"),       row.names = FALSE)
saveRDS(num,    file.path(out_dir, "recoded_main_study.rds"))
cat("\nDone. Outputs written to", normalizePath(out_dir), "\n")
