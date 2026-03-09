# Bone-Brain Axis: Hip Osteoarthritis and Alzheimer's Disease

[![medRxiv](https://img.shields.io/badge/medRxiv-Preprint-blue)](https://doi.org/10.64898/2026.03.04.26347509)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository contains the custom R scripts and analytical pipelines for the following study:

> **Genetic liability to hip osteoarthritis confers neurovascular protection against Alzheimer’s disease despite depression-mediated phenotypic comorbidity** > Qi Xu, Pianpian Zhao, Jianguo Tao, Houfeng Zheng  
> *medRxiv* (2026). DOI: [10.64898/2026.03.04.26347509](https://doi.org/10.64898/2026.03.04.26347509)

## 📌 Abstract
The relationship between hip osteoarthritis (hip OA) and Alzheimer's disease (AD) presents a critical paradox: widespread phenotypic comorbidity contradicts evolutionary theories of biological antagonism. By integrating longitudinal phenotypic data from the UK Biobank, multi-omic modeling (MiXeR, conjFDR), Mendelian randomization (MR), and single-nucleus transcriptomics (ROSMAP), this study demonstrates that observational comorbidity is largely mediated by depression, while underlying genetic liability to hip OA actually confers localized neurovascular protection against AD.

## 📂 Repository Structure

The analytical code is organized into four main directories corresponding to the methodological workflow of the manuscript:

* **`01_Observational_Analysis/`**
  * Scripts for cohort selection, covariate extraction, and longitudinal survival modeling (Cox proportional hazards and Fine-Gray competing risk models) using UK Biobank data.
* **`02_Genomic_Architecture/`**
  * Scripts for executing univariate and bivariate MiXeR models to evaluate polygenic overlap, and code for conjunctional false discovery rate (conjFDR) analysis.
* **`03_Mendelian_Randomization/`**
  * Global two-sample MR pipelines (IVW, MR-PRESSO, sensitivity analyses).
  * Cell-type-stratified Mendelian randomization (csMR) integrating single-cell eQTL data.
* **`04_snRNA_seq_Validation/`**
  * Processing, normalization, clustering, and disease-state differential expression visualization of ROSMAP single-nucleus RNA-seq data using Seurat.

## 💻 System Requirements & Dependencies

All analyses were performed in **R version 4.2.1**. The major packages required to reproduce the analyses include:
* **Survival & Epidemiology:** `survival`, `cmprsk`
* **Genetics & MR:** `TwoSampleMR`, `MendelianRandomization`, `MR-PRESSO`
* **Single-Cell Transcriptomics:** `Seurat` (v4.0+)
* **Data Manipulation & Visualization:** `tidyverse`, `ggplot2`

## 📊 Data Availability
This repository contains only analytical code. The raw and summary-level datasets required to run these scripts are publicly available:
* **Hip OA GWAS:** GWAS Catalog (GCST007091)
* **AD GWAS:** GWAS Catalog (GCST90027158)
* **sceQTL Data:** Zenodo (DOI: 10.5281/zenodo.5543734)
* **snRNA-seq Data:** ROSMAP cohort via the AD Knowledge Portal (Synapse)
* **Phenotypic Data:** UK Biobank (Accession ID 41376; requires application)

## 📝 Citation
If you use the code or findings from this repository, please cite our preprint:

```bibtex
@article{Xu2026BoneBrain,
  title={Genetic liability to hip osteoarthritis confers neurovascular protection against Alzheimer’s disease despite depression-mediated phenotypic comorbidity},
  author={Xu, Qi and Zhao, Pianpian and Tao, Jianguo and Zheng, Houfeng},
  journal={medRxiv},
  year={2026},
  publisher={Cold Spring Harbor Laboratory Press},
  doi={10.64898/2026.03.04.26347509},
  url={[https://doi.org/10.64898/2026.03.04.26347509](https://doi.org/10.64898/2026.03.04.26347509)}
}
