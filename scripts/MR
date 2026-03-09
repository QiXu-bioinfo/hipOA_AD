rm(list=ls())
setwd("/storage/zhenghoufengLab/gaisirui/xuqi/pjHipOA_NDD_MR/output/step9mr")
library(TwoSampleMR)
library(MRInstruments)
library(MRPRESSO)

# 初始化 mrandpresso 为 NULL
mrandpresso <- NULL
for (m in 1:1){
  for (n in 1:15){
    mergepipeicombined <- read.table(
      paste("/storage/zhenghoufengLab/gaisirui/xuqi/pjHipOA_NDD_MR/output/step8remergepipei/mergepipeicombined",m,"_",n, ".tsv", sep=""),
      sep="\t", header=TRUE
    )
    
    if (nrow(mergepipeicombined) == 0) {
      print(paste("_", n, sep=""))
      next
    }
    
    MHC_exp <- read_exposure_data(
      filename = paste("/storage/zhenghoufengLab/gaisirui/xuqi/pjHipOA_NDD_MR/output/step8remergepipei/mergepipeicombined",m,"_",n,".tsv", sep=""),
      sep = "\t",
      snp_col = "rsid",
      beta_col = "beta.exposure",
      se_col = "se.exposure",
      effect_allele_col = "effect_allele.exposure",
      other_allele_col = "other_allele.exposure",
      eaf_col = "eaf.exposure",
      pval_col = "pval"
    )
    exposure_names <- c(
      "1hipoa", "2hipkneeoa", "3alloa"
    )
    MHC_exp$exposure <- exposure_names[m]
    
    outcome <- read_outcome_data(
      snps = MHC_exp$SNP,
      filename = paste("/storage/zhenghoufengLab/gaisirui/xuqi/pjHipOA_NDD_MR/output/step8remergepipei/mergepipeicombined",m,"_",n,".tsv", sep=""),
      sep = "\t",
      snp_col = "rsid",
      beta_col = "BETA",
      se_col = "SE",
      effect_allele_col = "EA",
      other_allele_col = "NEA",
      eaf_col = "EAF",
      pval_col = "PVALUE"
    )
    
    # 设置 outcome 名称
    outcome_names <- c(
      "01AD_NG2022", "02AD_finngene", "03AD_NG2020", "04ALS", "05PD_nalls",
      "06PD_nalls_withproxyPD", "07PD_finngene", "08PD_Nature2021", "09PD_NG2024",
      "10MS", "11MS_1", "12MS_2", "13MS_finngen", "14sCJD", "15LBD"
    )
    outcome$outcome <- outcome_names[n]
    
    harmonised <- harmonise_data(exposure_dat = MHC_exp, outcome_dat = outcome)
    res <- mr(harmonised)
    harmonised_keepTRUE <- harmonised[harmonised$mr_keep == "TRUE", ]
    
    # 初始化 mrandpresso_original
    mrandpresso_original <- res
    
    # 如果 mrandpresso_original 是空数据框（0 行），则跳过
    if (nrow(mrandpresso_original) == 0) {
      print(paste("No valid SNPs for outcome", outcome_names[n]))
      next
    }
    
    if (nrow(harmonised_keepTRUE) > 3) {
      presso <- mr_presso(
        BetaOutcome = "beta.outcome",
        BetaExposure = "beta.exposure", 
        SdOutcome = "se.outcome",
        SdExposure = "se.exposure", 
        OUTLIERtest = TRUE, 
        DISTORTIONtest = TRUE, 
        data = harmonised_keepTRUE, 
        NbDistribution = 1000, 
        SignifThreshold = 0.05
      )
      
      # 添加 MR-PRESSO 结果
      mrandpresso_original <- rbind(mrandpresso_original, res[1, ])  # 复制一行用于 MR-PRESSO
      mrandpresso_original[nrow(mrandpresso_original), "method"] <- ifelse(
        presso$`MR-PRESSO results`$`Global Test`$Pvalue < 0.05,
        "MR PRESSO(corrected)",
        "MR PRESSO(raw)"
      )
      
      # 提取 MR-PRESSO 结果
      MRPRESSO_result <- if (presso$`MR-PRESSO results`$`Global Test`$Pvalue < 0.05) {
        presso$`Main MR results`[2, ]
      } else {
        presso$`Main MR results`[1, ]
      }
      
      # 更新 MR-PRESSO 行
      mrandpresso_original[nrow(mrandpresso_original), c("b", "se", "pval")] <- 
        MRPRESSO_result[c("Causal Estimate", "Sd", "P-value")]
      
      # 添加 Global Test P-value 列
      mrandpresso_original$Global_Test_Pvalue <- NA
      mrandpresso_original[nrow(mrandpresso_original), "Global_Test_Pvalue"] <- 
        presso$`MR-PRESSO results`$`Global Test`$Pvalue
    } else {
      # 如果 <= 3 SNPs，仍然添加 Global_Test_Pvalue 列（设为 NA）
      mrandpresso_original$Global_Test_Pvalue <- NA
    }
    
    # 首次迭代时直接赋值，后续通过 rbind 合并
    if (is.null(mrandpresso)) {
      mrandpresso <- mrandpresso_original
    } else {
      mrandpresso <- rbind(mrandpresso, mrandpresso_original)
  }
  }
}
write.csv(mrandpresso,paste("/storage/zhenghoufengLab/gaisirui/xuqi/pjHipOA_NDD_MR/output/step9mr/mrandpresso_1-3oa_1-15NDD",".csv",sep=""),quote=F,row.names=FALSE)  

het <- mr_heterogeneity(harmonised)  # 计算 Cochran‘s Q
rucker <- mr_rucker(harmonised)[[1]]   # 以后直接 rucker$Q 就能用了
het_ivw  <- subset(mr_heterogeneity(harmonised), 
                   method == "Inverse variance weighted")
rucker_p <- mr_rucker(harmonised)$Q_pval

cat("IVW 结果中存在异质性：Q' P =", rucker_p, "\n")
