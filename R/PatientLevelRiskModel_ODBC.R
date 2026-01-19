# Workflow:
# 1. Create [BRIT].[PatientLevelDataFinal] table in SQL
# 2. Run this script to generate patient-level risk predictions and upload
#    patient-level and summary tables to dbase
# 3. Check that
#    * [BRIT].[PatientLevelDataFinalGR] and
#    * [BRIT].[PerPracticeRiskSummaryGR]
#    now exist in dbase.
# 4. [BRIT].[PerPracticeRiskSummaryGR] should be okay to export and share with
#    research team without exposing any patient-level data.
#
# Notes:
# This script requires access to risk-model data contained in a file called
# 'analysisdata.json'.
# If you've got here by cloning the GitHub repo, the script will know where to
# find the file and everything below will work as expected.
# If you have downloaded this script alone, you will also have to download the
# 'analysisdata.json' file and edit the line indicated below to specify your
# local path to the data file.


if (!require("pacman")) install.packages("pacman"); library(pacman)
p_load(here,
       tidyverse,
       magrittr,
       glue,
       jsonlite,
       DBI,
       dbplyr,
       odbc)

# load model coefficients, etc. ---------------------------------------------------------------
pth <- here("models", "analysisdata.json") # <-- change this line if local file structure varies from GitHub repo
jj <- fromJSON(pth,
               flatten = TRUE) %>% 
  extract2("betasForDiagnosis") %>%
  as_tibble() %>% 
  mutate(infect = fct(name))

## extract betas -----------------------------------------------------------------------------
tblBetas <- jj %>% 
  select(infect, starts_with("hospitalisationBetasIncident")) %>% 
  pivot_longer(cols      = -infect,
               names_to  = "var",
               values_to = "coef") %>% 
  mutate(var = str_remove_all(var, "hospitalisationBetasIncidental\\.")) %>% 
  separate_wider_regex(var, c(cat = ".*?", "_", val = ".*")) %>% 
  mutate(val = str_remove_all(val, "^cat_|^status_"))

## extract lookups for baseline hazard -------------------------------------------------------
tblLookups <- jj %>% 
  select(infect, hospitalisationSumBetasIncidental) %>% 
  unnest(hospitalisationSumBetasIncidental) %>% 
  rowwise() %>% 
  mutate(avg = mean(c_across(bin_lower:bin_upper)),
         p = (1-mean_interpolate)^exp(-avg)) %>% 
  group_by(infect) %>%
  mutate(avgP = mean(p)) %>% 
  group_modify(~ .x %>% 
                 add_row(.x %>% 
                           slice_head(n=1) %>% 
                           mutate(bin_upper = bin_lower,
                                  bin_lower = -Inf),
                         .before = 0) %>% 
                 add_row(.x %>% 
                           slice_tail(n=1) %>% 
                           mutate(bin_lower = bin_upper,
                                  bin_upper = Inf))) %>% 
  ungroup()

# function to fit models given a table of inputs ----------------------------------------------
# one row per person
fnFitRiskModels2 <- function(tbl, blnExtrap = FALSE) {
  
  # join on single continuous variable (ABx prescriptions in prev. year)
  tbl %<>% 
    select(ID, GP_Practice_Code, event_date, infect, where(is.factor)) %>% 
    mutate(antibacterial = "brit") %>%
    pivot_longer(cols      = -c(ID, GP_Practice_Code, infect, event_date),
                 names_to  = "cat",
                 values_to = "fct") %>%
    left_join(tbl %>% 
                select(ID, event_date, infect, antibacterial) %>% 
                pivot_longer(cols      = -c(ID, infect, event_date),
                             names_to  = "cat",
                             values_to = "num"),
              by = join_by(ID, event_date, infect, cat)) %>% 
    arrange(ID) %>% 
    mutate(num = replace_na(num, 1)) 
  
  # join to betas
  tblFitted <- tbl %>% 
    left_join(tblBetas,
              by = join_by(infect, cat, fct == val)) %>% 
    mutate(LnHR = num * coef)
  
  # join to predicted probabilities for betas
  # optionally allowing extrapolation beyond the ranges covered in the lookups
  tblFitted %>% 
    group_by(ID, infect, event_date, GP_Practice_Code) %>% 
    summarise(sumLnHRs = sum(LnHR)) %>% 
    ungroup() %>% 
    left_join(tblLookups %>% 
                select(infect, bin_lower:mean_interpolate),
              by = join_by(infect, between(sumLnHRs, bin_lower, bin_upper))) %>% 
    left_join(tblLookups %>% 
                distinct(infect, avgP),
              by = join_by(infect)) %>% 
    mutate(pp = 1-avgP^exp(sumLnHRs),
           Prob_Hosp = case_when(
             bin_lower == -Inf & blnExtrap ~ pp,
             bin_upper == Inf  & blnExtrap ~ pp,
             TRUE                          ~ mean_interpolate
           ))
}

# read patient-level data in via ODBC from SQL Server dbase ----------------------------------------
con <- DBI::dbConnect(odbc(),
                      Driver         = "ODBC Driver 17 for SQL Server",
                      Server         = "gm-ccbi-live-01.database.windows.net",
                      Database       = "HDM_Customer",
                      UID            = "gabriel.rogers2@grhapp.com",
                      Authentication = "ActiveDirectoryInteractive") # this will give you a pop-up where you supply your credentials
dbListTables(con) # check

tblPtLevelRaw <- con %>% 
  tbl("PatientLevelDataFinal") %>% 
  collect()

# wrangle data into correct format ------------------------------------------------------------
tblPtLevel <- tblPtLevelRaw %>% 
  mutate(ID         = Patient_ID,
         GP_Practice_Code,
         event_date,
         infect,
         age        = cut(x      = Age,
                          right  = FALSE,
                          breaks = c(15+0:6*10, Inf),
                          labels = str_replace(glue("{15+0:6*10}_{24+0:6*10}"), "84", "more")),
         cci        = cut(x      = CCI_Score,
                          right  = FALSE,
                          breaks = c(0:3, 5, Inf),
                          labels = c("very_low", "low", "medium", "high", "very_high")),
         # cci        = factor(cci),
         bmi        = cut(x      = BMI_Score,
                          right  = TRUE,
                          breaks = c(10, 18.5, 25, 30, Inf),
                          labels = c("underweight", "healthy_weight", "overweight", "obese")) %>% 
           fct_expand("unknown") %>% 
           replace_na("unknown"),
         ethnicity  = fct_collapse(Ethnicity,
                                   white     = "White",
                                   non_white = c("Asian or Asian British",
                                                 "Black, Black British, Caribbean or African",
                                                 "Other Ethnic Groups",
                                                 "Mixed or multiple ethnic groups"),
                                   unknown   = c("Refused and not stated group",
                                                 "unknown")),
         flu       = factor(Flu_status,
                            levels = c(1, 0),
                            labels = c("vaccine_yes", "vaccine_no")),
         imd       = factor(IMD_Score),
         region    = factor("north_west"),
         season    = factor(Season),
         sex       = factor(Sex),
         smoking   = factor(smoking_status,
                            levels = c("ex", "never", "current", "unknown"),
                            labels = c("ex_smoker", "never_smoked", "smoker", "unknown")),
         antibacterial = AB_Presc_count,
         AB_Flag,
         Age,
         .keep = "none")

## fit probs ---------------------------------------------------------------------------------
tblFitted <- tblPtLevel %>% 
  fnFitRiskModels2(blnExtrap = FALSE)

tblPtLevelRaw %<>% 
  left_join(tblFitted %>% 
              select(ID, infect, event_date, Prob_Hosp),
            by = join_by(infect, event_date, Patient_ID == ID))

# upload table with probs to dbase ------------------------------------------------------------
tblPtLevelRaw %>% 
  copy_to(dest      = con,
          df        = .,
          name      = "PatientLevelDataFinalGR",
          temporary = FALSE,
          overwrite = TRUE)

## additional table with practice level mean risks -------------------------------------------
tblPracticeLevel <- tblPtLevelRaw %>% 
  group_by(infect, GP_Practice_Code, AB_Flag) %>% 
  summarise(n         = n(),
            Prob_Hosp = mean(Prob_Hosp, na.rm = TRUE)) %>% 
  arrange(infect, GP_Practice_Code, AB_Flag)

tblPracticeLevel %>% 
  copy_to(dest      = con,
          df        = .,
          name      = "PerPracticeRiskSummaryGR",
          temporary = FALSE,
          overwrite = TRUE)

# tidy up -------------------------------------------------------------------------------------
con %>% 
  DBI::dbDisconnect()
