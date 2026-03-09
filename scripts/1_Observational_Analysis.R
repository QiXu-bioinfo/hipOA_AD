##########################################################
# UK Biobank：Hip OA 与 AD 关联分析 (Final Manuscript Version)
# 逻辑流：
# 1. 基础模型 -> 2. 生活方式 -> 3. +APOE (验证核心) -> 4. +抑郁 (全调整)
# 5. 竞争风险模型 A (对应模型3) -> 6. 竞争风险模型 B (对应模型4)
##########################################################

# -------------------------------
# 0. 环境准备
# -------------------------------
rm(list = ls())
# 请修改为你的实际工作路径
setwd("/storage/zhenghoufengLab/gaisirui/xuqi/pjHipOA_AD_obs")

# 检查并加载包
required_packages <- c("data.table", "dplyr", "tidyr", "stringr", "survival", 
                       "survminer", "ggplot2", "broom", "cmprsk")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
# 尝试使用官方云镜像安装缺失包 (如果服务器断网，请使用源码安装方法)
if(length(new_packages)) install.packages(new_packages, repos = "https://cloud.r-project.org")

lapply(required_packages, require, character.only = TRUE)

# -------------------------------
# 1. 数据读取与清洗 (保持稳健逻辑)
# -------------------------------
dt1 <- fread("fid1.tab")   # baseline
dt2 <- fread("fid2.tab")   # ICD hospital
dt3 <- fread("fid5.tab")   # self-report
dt4 <- fread("fid6.tab")   # education/income
dt5 <- fread("fid7.tab")   # death
dt_main <- fread("fid4.tab") # population
dt10 <- fread("fid10.tab") # lifestyle
apoe_raw <- fread("APOE_genotypes.raw") 

# ID 统一函数
recode_eid <- function(data) {
  id_col <- names(data)[names(data) %in% c("eid","IID","FID","ID","id","f.eid","f_eid")]
  if (length(id_col) > 0 && id_col[1] != "eid") {
    data <- data %>% rename(eid = !!sym(id_col[1]))
  }
  data$eid <- as.numeric(data$eid)
  return(data)
}

list_dfs <- list(dt1, dt2, dt3, dt4, dt5, dt_main, dt10, apoe_raw)
list_dfs <- lapply(list_dfs, recode_eid)
dt1 <- list_dfs[[1]]; dt2 <- list_dfs[[2]]; dt3 <- list_dfs[[3]]; dt4 <- list_dfs[[4]]
dt5 <- list_dfs[[5]]; dt_main <- list_dfs[[6]]; dt10 <- list_dfs[[7]]; apoe_raw <- list_dfs[[8]]

# 字段查找函数
get_col_instance0 <- function(data, fid) {
  pattern <- paste0("^f\\.", fid, "\\.")
  cols <- names(data)[grepl(pattern, names(data))]
  if (length(cols) == 0) return(NA_character_)
  col0 <- cols[grepl("\\.0\\.0$", cols)]
  if (length(col0) > 0) return(col0[1])
  return(cols[1])
}

# -------------------------------
# 2. 样本筛选 (白人)
# -------------------------------
ethnicity_col <- get_col_instance0(dt3, "21000")
white_participants <- dt3 %>%
  select(eid, ethnicity = !!sym(ethnicity_col)) %>%
  filter(ethnicity %in% c(1, 1001, 1002, 1003)) %>%
  distinct(eid)

dt_main <- dt_main %>% inner_join(white_participants, by = "eid")

# -------------------------------
# 3. 变量定义
# -------------------------------
# --- Hip OA ---
illness_cols <- names(dt3)[grepl("^f\\.20002", names(dt3))]
df_arthritis <- dt3 %>%
  select(eid, illness_code = !!sym(illness_cols[1])) %>%
  filter(illness_code %in% c(1221, 1222, 1223)) %>%
  distinct(eid) %>% mutate(has_hip_oa_sr = TRUE)

icd_cols_dt2 <- names(dt2)[grepl("^f\\.41270", names(dt2))]
df_icd_long <- dt2 %>%
  select(eid, all_of(icd_cols_dt2)) %>%
  pivot_longer(cols = all_of(icd_cols_dt2), values_to = "icd10") %>%
  filter(str_detect(trimws(icd10), "^M16")) %>%
  distinct(eid) %>% mutate(has_hip_oa_hosp = TRUE)

df_hip_oa <- dt_main %>% select(eid) %>%
  left_join(df_arthritis, by="eid") %>%
  left_join(df_icd_long, by="eid") %>%
  mutate(has_hip_oa = ifelse(!is.na(has_hip_oa_sr) | !is.na(has_hip_oa_hosp), 1, 0))

# --- AD & Death & Time ---
dementia_cols <- names(dt3)[grepl("^f\\.42018", names(dt3))]
df_dementia <- dt3 %>%
  select(eid, dementia_date = !!sym(dementia_cols[1])) %>%
  mutate(dementia_date = as.Date(dementia_date))

death_cols <- names(dt5)[grepl("^f\\.40000", names(dt5))]
df_death <- dt5 %>%
  select(eid, all_of(death_cols)) %>%
  pivot_longer(cols = all_of(death_cols), values_to = "death_date") %>%
  filter(!is.na(death_date)) %>%
  group_by(eid) %>% summarise(death_date = min(as.Date(death_date)))

baseline_date_col <- get_col_instance0(dt1, "53")
df_baseline <- dt1 %>% select(eid, assessment_date = !!sym(baseline_date_col)) %>%
  mutate(assessment_date = as.Date(assessment_date))

data_cutoff <- as.Date("2023-08-21")

df_time <- dt_main %>% select(eid) %>%
  left_join(df_baseline, by="eid") %>%
  left_join(df_dementia, by="eid") %>%
  left_join(df_death, by="eid") %>%
  mutate(
    first_event_date = pmin(dementia_date, death_date, data_cutoff, na.rm = TRUE),
    follow_up_time = as.numeric(first_event_date - assessment_date) / 365.25,
    # Cox 状态 (1=AD, 0=Censored/Death)
    status_cox = ifelse(!is.na(dementia_date) & dementia_date <= first_event_date, 1, 0),
    # Fine-Gray 状态 (1=AD, 2=Death, 0=Censored)
    status_cr = case_when(
      !is.na(dementia_date) & dementia_date <= first_event_date ~ 1,
      !is.na(death_date) & death_date <= first_event_date ~ 2, 
      TRUE ~ 0
    )
  )

# --- Covariates ---
covariates <- dt3 %>%
  select(eid, bmi = !!sym(get_col_instance0(dt3, "21001"))) %>%
  left_join(dt4 %>% select(eid, 
                           education = !!sym(get_col_instance0(dt4, "6138")),
                           income = !!sym(get_col_instance0(dt4, "738")),
                           sex = !!sym(get_col_instance0(dt4, "31"))), by="eid")

# Depression (ICD F32/F33)
icd_cols2 <- names(dt2)[grepl("^f\\.41270", names(dt2))]
df_dep <- dt2 %>%
  select(eid, all_of(icd_cols2)) %>%
  pivot_longer(cols = all_of(icd_cols2), values_to = "icd10") %>%
  filter(str_detect(trimws(icd10), "^(F32|F33)")) %>%
  distinct(eid) %>% mutate(has_depression = 1)

# Lifestyle
cov_lifestyle <- dt10 %>%
  select(eid,
         smoking = !!sym(get_col_instance0(dt10, "20116")),
         alcohol = !!sym(get_col_instance0(dt10, "1558")),
         activity = !!sym(get_col_instance0(dt10, "22040")))

# APOE
rs1 <- names(apoe_raw)[grepl("rs429358", names(apoe_raw))][1]
rs2 <- names(apoe_raw)[grepl("rs7412", names(apoe_raw))][1]
apoe_geno <- apoe_raw %>%
  mutate(eid = as.numeric(IID),
         e4_count = (2 - as.numeric(.data[[rs1]])) + as.numeric(.data[[rs2]])) %>%
  mutate(
    apoe_e4_count = ifelse(e4_count > 2, NA, e4_count),
    apoe_e4_carrier = ifelse(apoe_e4_count >= 1, 1, 0)
  ) %>% select(eid, apoe_e4_carrier)

# -------------------------------
# 4. 数据合并与最终清洗
# -------------------------------
df_final <- dt_main %>%
  select(eid, age = !!sym(get_col_instance0(dt_main, "21003"))) %>%
  left_join(df_hip_oa, by="eid") %>%
  left_join(df_time, by="eid") %>%
  left_join(covariates, by="eid") %>%
  left_join(cov_lifestyle, by="eid") %>%
  left_join(df_dep, by="eid") %>%
  left_join(apoe_geno, by="eid") %>%
  mutate(
    has_hip_oa = factor(has_hip_oa, levels=c(0,1), labels=c("No", "Yes")),
    sex = factor(sex, levels=c(0,1), labels=c("Female", "Male")),
    has_depression = ifelse(is.na(has_depression), 0, 1),
    age_sq = age^2 
  )

# Lag Analysis (2 years) & Drop NA
# 关键：为了让模型间可比，删除任何一个模型中用到的变量有缺失的样本
df_analysis <- df_final %>%
  filter(!is.na(follow_up_time), follow_up_time > 2) %>% 
  drop_na(age, sex, bmi, education, income, smoking, alcohol, activity, apoe_e4_carrier, has_depression)

cat("最终纳入分析人数 (N): ", nrow(df_analysis), "\n")
cat("AD事件数: ", sum(df_analysis$status_cox == 1), "\n")

# -------------------------------
# 5. 统计建模 (分层逻辑)
# -------------------------------

cat("\nRunning Cox Models...\n")

# --- Model 1: Basic ---
fit_m1 <- coxph(Surv(follow_up_time, status_cox) ~ has_hip_oa + age + I(age^2) + sex, 
                data = df_analysis)

# --- Model 2: Lifestyle ---
fit_m2 <- coxph(Surv(follow_up_time, status_cox) ~ has_hip_oa + age + I(age^2) + sex + 
                  bmi + education + income + smoking + alcohol + activity, 
                data = df_analysis)

# --- Model 3: Validation (+ APOE, No Depression) ---
# 这是你想要整合进去的关键验证模型
fit_m3_apoe <- coxph(Surv(follow_up_time, status_cox) ~ has_hip_oa + age + I(age^2) + sex + 
                       bmi + education + income + smoking + alcohol + activity + 
                       apoe_e4_carrier, # With APOE
                     data = df_analysis)

# --- Model 4: Full (+ APOE + Depression) ---
# 这是原来的 "Full Model"
fit_m4_full <- coxph(Surv(follow_up_time, status_cox) ~ has_hip_oa + age + I(age^2) + sex + 
                       bmi + education + income + smoking + alcohol + activity + 
                       apoe_e4_carrier + has_depression, # With Depression
                     data = df_analysis)

# -------------------------------
# 6. 竞争风险模型 (Fine-Gray, 两个版本)
# -------------------------------
cat("\nRunning Fine-Gray Models...\n")

# Fine-Gray A: 对应 Model 3 (含 APOE, 无 Depression)
# 目的：验证在竞争风险下，排除抑郁干扰，APOE 是否会解释掉关联
cov_mat_apoe <- model.matrix(~ has_hip_oa + age + sex + bmi + education + income + 
                               smoking + alcohol + activity + apoe_e4_carrier, 
                             data = df_analysis)[,-1]

fg_model_apoe <- crr(ftime = df_analysis$follow_up_time, 
                     fstatus = df_analysis$status_cr, 
                     cov1 = cov_mat_apoe, failcode = 1, cencode = 0)

# Fine-Gray B: 对应 Model 4 (全调整, 含 Depression)
# 目的：验证加入抑郁后，即使在竞争风险模型中，关联是否也会消失
cov_mat_full <- model.matrix(~ has_hip_oa + age + sex + bmi + education + income + 
                               smoking + alcohol + activity + apoe_e4_carrier + has_depression, 
                             data = df_analysis)[,-1]

fg_model_full <- crr(ftime = df_analysis$follow_up_time, 
                     fstatus = df_analysis$status_cr, 
                     cov1 = cov_mat_full, failcode = 1, cencode = 0)

# -------------------------------
# 7. 结果汇总与可视化
# -------------------------------

# 提取 Cox 结果的函数
extract_cox_hr <- function(model, label) {
  res <- tidy(model, exponentiate = TRUE, conf.int = TRUE)
  res %>% filter(term == "has_hip_oaYes") %>%
    mutate(model = label) %>%
    select(model, estimate, conf.low, conf.high, p.value)
}

# 提取 Fine-Gray 结果的函数
extract_fg_hr <- function(fg_mod, label) {
  summ <- summary(fg_mod)
  # 假设 has_hip_oaYes 是第一行 (因为它是 factor 且在公式第一个)
  # 如果不确定，可以通过 rownames(summ$coef) 检查
  idx <- grep("has_hip_oaYes", rownames(summ$coef))
  
  data.frame(
    model = label,
    estimate = summ$conf.int[idx, 1],
    conf.low = summ$conf.int[idx, 3],
    conf.high = summ$conf.int[idx, 4],
    p.value = summ$coef[idx, 5]
  )
}

# 汇总所有结果
res_m1 <- extract_cox_hr(fit_m1, "1. Cox: Age + Sex")
res_m2 <- extract_cox_hr(fit_m2, "2. Cox: + Lifestyle")
res_m3 <- extract_cox_hr(fit_m3_apoe, "3. Cox: + APOE (Validation)")
res_m4 <- extract_cox_hr(fit_m4_full, "4. Cox: Full (+ Depression)")

res_fg1 <- extract_fg_hr(fg_model_apoe, "5. FG: + APOE (No Dep)")
res_fg2 <- extract_fg_hr(fg_model_full, "6. FG: Full (+ Dep)")

all_res <- bind_rows(res_m1, res_m2, res_m3, res_m4, res_fg1, res_fg2)

# 保存表格
write.csv(all_res, "final_results_all_models.csv", row.names = FALSE)
print(all_res)

# 绘制优化后的森林图
# 设置 Factor 顺序，使图表从上到下符合逻辑顺序
all_res$model <- factor(all_res$model, levels = rev(c(
  "1. Cox: Age + Sex", 
  "2. Cox: + Lifestyle", 
  "3. Cox: + APOE (Validation)", 
  "4. Cox: Full (+ Depression)",
  "5. FG: + APOE (No Dep)", 
  "6. FG: Full (+ Dep)"
)))

p_forest <- ggplot(all_res, aes(x = estimate, y = model, xmin = conf.low, xmax = conf.high)) +
  geom_point(aes(color = model), size = 3.5) +
  geom_errorbarh(aes(color = model), height = 0.2, linewidth = 1) + # 使用 linewidth 避免警告
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey50") +
  scale_color_brewer(palette = "Dark2") +
  labs(title = "Association between Hip OA and Incident AD",
       subtitle = "Hierarchical Cox Models & Competing Risk Analysis",
       x = "Hazard Ratio / SHR (95% CI)", y = "") +
  theme_minimal() +
  theme(legend.position = "none", 
        axis.text.y = element_text(size = 11, face = "bold"),
        axis.title.x = element_text(size = 12))

ggsave("final_forest_plot.png", p_forest, width = 10, height = 6)

cat("\nAnalysis Pipeline Completed Successfully.\n")
