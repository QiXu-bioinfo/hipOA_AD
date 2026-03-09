srun -p intel-sc3,amd-ep2,amd-ep2-short -q normal -c 6 --mem=20G -J mixer_test3 --pty /bin/bash
cd /storage/zhenghoufengLab/gaisirui/xuqi/pjKneeHipOA_NDD_mixer

source ~/.bashrc
shopt -s expand_aliases
module load singularity/3.7.1
module load mixer/latest
conda activate mixer


###STEP1: Data preparation计算得到zscore
cd /storage/zhenghoufengLab/gaisirui/xuqi/pjKneeHipOA_NDD_mixer
python python_convert-master/sumstats.py csv --sumstats scz.swe.pgc1.results.v3.txt.gz --out PGC_SCZ_2014_EUR.csv --force --auto --head 5 --ncase-val 33640 --ncontrol-val 43456 
python python_convert-master/sumstats.py zscore --sumstats PGC_SCZ_2014_EUR2.csv | \
python python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 --max-or 1e37 | \
python python_convert-master/sumstats.py neff --drop --factor 4 --out PGC_SCZ_2014_EUR_qc_noMHC.csv --force 
gzip PGC_SCZ_2014_EUR_qc_noMHC.csv

python python_convert-master/sumstats.py csv --sumstats GWAS_EA_excl23andMe.txt.gz --out SSGAC_EDU_2018_no23andMe.csv --force --auto --head 5 --n-val 766345
python python_convert-master/sumstats.py zscore --sumstats SSGAC_EDU_2018_no23andMe.csv | \
python python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 --out SSGAC_EDU_2018_no23andMe_noMHC.csv --force
gzip SSGAC_EDU_2018_no23andMe_noMHC.csv 

python python_convert-master/sumstats.py csv --sumstats alloa_quan.ma --out alloa.csv --force --auto --head 5
python python_convert-master/sumstats.py zscore --sumstats alloa.csv | \
python python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 --out alloa_noMHC.csv --force
gzip alloa_noMHC.csv 

python python_convert-master/sumstats.py csv --sumstats alloa_quan.ma --out alloa.csv --force --auto --head 5
python python_convert-master/sumstats.py zscore --sumstats alloa.csv | \
python python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 --out alloa_noMHC.csv --force
gzip alloa_noMHC.csv 


###alloa_new
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats alloa_quan1.ma --out alloa.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats alloa.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out alloa_noMHC.csv --force
gzip alloa_noMHC.csv 


python python_convert-master/sumstats.py csv --sumstats kneeoa_quan.ma --out kneeoa.csv --force --auto --head 5
python python_convert-master/sumstats.py zscore --sumstats kneeoa.csv | \
python python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 --out kneeoa_noMHC.csv --force
gzip kneeoa_noMHC.csv 

###kneeoa_new
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats kneeoa_quan1.ma --out kneeoa.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats kneeoa.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out kneeoa_noMHC.csv --force
gzip kneeoa_noMHC.csv 


python python_convert-master/sumstats.py csv --sumstats hipoa_quan.ma --out hipoa.csv --force --auto --head 5
python python_convert-master/sumstats.py zscore --sumstats hipoa.csv | \
python python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 --out hipoa_noMHC.csv --force
gzip hipoa_noMHC.csv 

###hipoa_new
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats hipoa_quan1.ma --out hipoa.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats hipoa.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out hipoa_noMHC.csv --force
gzip hipoa_noMHC.csv 

python python_convert-master/sumstats.py csv --sumstats hipkneeoa_quan.ma --out hipkneeoa.csv --force --auto --head 5
python python_convert-master/sumstats.py zscore --sumstats hipkneeoa.csv | \
python python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 --out hipkneeoa_noMHC.csv --force
gzip hipkneeoa_noMHC.csv 

###hipkneeoa_new
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats hipkneeoa_quan1.ma --out hipkneeoa.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats hipkneeoa.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out hipkneeoa_noMHC.csv --force
gzip hipkneeoa_noMHC.csv 



/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 01AD_NG2022_quan.ma --out 01AD_NG2022.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 01AD_NG2022.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 01AD_NG2022_noMHC.csv --force
gzip 01AD_NG2022_noMHC.csv 



/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 02AD_finngene_quan.ma --out 02AD_finngene.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 02AD_finngene.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 02AD_finngene_noMHC.csv --force
gzip 02AD_finngene_noMHC.csv 



python python_convert-master/sumstats.py csv --sumstats /storage/zhenghoufengLab/gaisirui/xuqi/pjKneeOA_NDD_MR/outcome/03AD_NG2020.txt --out 03AD_NG2020.csv --force --auto --head 5
python python_convert-master/sumstats.py zscore --sumstats 03AD_NG2020.csv | \
python python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 --out 03AD_NG2020_noMHC.csv --force
gzip 03AD_NG2020_noMHC.csv 

###new
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --sumstats 03AD_NG2020_quan.ma --exclude-ranges 6:26000000-34000000 --out 03AD_NG2020_noMHC.csv
gzip 03AD_NG2020_noMHC.csv 



python python_convert-master/sumstats.py csv \
  --sumstats /storage/zhenghoufengLab/gaisirui/xuqi/pjKneeOA_NDD_MR/outcome/03AD_NG2020.txt \
  --out AD_NG2020.csv \
  --force \
  --auto \
  --head 5 \
  --n Neff
python python_convert-master/sumstats.py qc \
  --sumstats AD_NG2020.csv \
  --exclude-ranges 6:26000000-34000000 \
  --out AD_NG2020_qc_noMHC.csv \
  --force
gzip AD_NG2020_qc_noMHC.csv


python python_convert-master/sumstats.py csv --sumstats 04ALS_quan.ma --out 04ALS.csv --force --auto --head 5
python python_convert-master/sumstats.py zscore --sumstats 04ALS.csv | \
python python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 --out 04ALS_noMHC.csv --force
gzip 04ALS_noMHC.csv 


# Step 1: 计算 Z 分数

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore \
    --sumstats /storage/zhenghoufengLab/gaisirui/xuqi/pjKneeOA_NDD_MR/outcome/05PD_nalls_renamed.tsv \
    --out 05PD_nalls_zscore.tsv --force

# Step 2: 质量控制（QC），排除 MHC 区域

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc \
    --sumstats 05PD_nalls_zscore.tsv \
    --exclude-ranges 6:26000000-34000000 \
    --out 05PD_nalls_noMHC.tsv --force

# Step 3: 计算 Neff，并保存最终结果

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff \
    --sumstats 05PD_nalls_noMHC.tsv \
    --drop --factor 4 \
    --out 05PD_nalls_final.tsv --force


# 标准化 + 计算 Neff
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv \
  --sumstats /storage/zhenghoufengLab/gaisirui/xuqi/pjKneeOA_NDD_MR/outcome/05PD_nalls.tsv \
  --out PD_Nalls_2019.csv \
  --force \
  --auto \
  --ncase-val 15056 \
  --ncontrol-val 12637 \
  --chr chromosome \          # 改为 --chr 而非 --chromosome
  --bp base_pair_location \
  --a1 effect_allele \
  --a2 other_allele \
  --beta beta \
  --se standard_error \
  --frq effect_allele_frequency \
  --pval p_value

# 质量控制（排除 MHC、过滤低质量 SNP）
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats PD_Nalls_2019.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc \
  --exclude-ranges 6:26000000-34000000 \
  --out PD_Nalls_2019_qc.csv \
  --force

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --sumstats PD_Nalls_2019_qc.csv --drop --factor 4 --out PD_Nalls_2019_qc_final.csv --force

# 压缩输出
gzip PD_Nalls_2019_qc_final.csv



/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 05PD_nalls_quan.ma --out 05PD_nalls.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 05PD_nalls.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 05PD_nalls_noMHC.csv --force
gzip 05PD_nalls_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 06PD_nalls_withproxyPD_quan.ma --out 06PD_nalls_withproxyPD.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 06PD_nalls_withproxyPD.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 06PD_nalls_withproxyPD_noMHC.csv --force
gzip 06PD_nalls_withproxyPD_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 07PD_finngene_quan.ma --out 07PD_finngene.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 07PD_finngene.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 07PD_finngene_noMHC.csv --force
gzip 07PD_finngene_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 08PD_Nature2021_quan.ma --out 08PD_Nature2021.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 08PD_Nature2021.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 08PD_Nature2021_noMHC.csv --force
gzip 08PD_Nature2021_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 09PD_NG2024_quan.ma --out 09PD_NG2024.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 09PD_NG2024.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 09PD_NG2024_noMHC.csv --force
gzip 09PD_NG2024_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 10MS_quan.ma --out 10MS.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 10MS.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 --out 10MS_noMHC.csv
gzip 10MS_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 11MS_1_quan.ma --out 11MS_1.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 11MS_1.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 11MS_1_noMHC.csv --force
gzip 11MS_1_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 12MS_2_quan.ma --out 12MS_2.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 12MS_2.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 12MS_2_noMHC.csv --force
gzip 12MS_2_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 13MS_finngen_quan.ma --out 13MS_finngen.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 13MS_finngen.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 13MS_finngen_noMHC.csv --force
gzip 13MS_finngen_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 14sCJD_quan.ma --out 14sCJD.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 14sCJD.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 14sCJD_noMHC.csv --force
gzip 14sCJD_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 15LBD_quan.ma --out 15LBD.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 15LBD.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 15LBD_noMHC.csv --force
gzip 15LBD_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 16LBD_2_quan.ma --out 16LBD_2.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 16LBD_2.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 16LBD_2_noMHC.csv --force
gzip 16LBD_2_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 17LBD_3_quan.ma --out 17LBD_3.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 17LBD_3.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 17LBD_3_noMHC.csv --force
gzip 17LBD_3_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 18LBD_4_quan.ma --out 18LBD_4.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 18LBD_4.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 18LBD_4_noMHC.csv --force
gzip 18LBD_4_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 19LBD_5_quan.ma --out 19LBD_5.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 19LBD_5.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 19LBD_5_noMHC.csv --force
gzip 19LBD_5_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 20LBD_6_quan.ma --out 20LBD_6.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 20LBD_6.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 20LBD_6_noMHC.csv --force
gzip 20LBD_6_noMHC.csv 

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 21ALS_2_quan.ma --out 21ALS_2.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 21ALS_2.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 21ALS_2_noMHC.csv --force
gzip 21ALS_2_noMHC.csv

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 22ALS_3_quan.ma --out 22ALS_3.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 22ALS_3.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 22ALS_3_noMHC.csv --force
gzip 22ALS_3_noMHC.csv

/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py csv --sumstats 23ALS_4_quan.ma --out 23ALS_4.csv --force --auto --head 5
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py zscore --sumstats 23ALS_4.csv | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py qc --exclude-ranges 6:26000000-34000000 | \
/home/zhenghoufengLab/gaisirui/miniconda3/envs/mixer/bin/python3 python_convert-master/sumstats.py neff --drop --factor 4 --out 23ALS_4_noMHC.csv --force
gzip 23ALS_4_noMHC.csv

###STEP2: Univariate analysis
python3 /storage/zhenghoufengLab/gaisirui/xuqi/software/mixer/precimed/mixer.py fit1 \
      --trait1-file SSGAC_EDU_2018_no23andMe_noMHC.csv.gz \
      --out SSGAC_EDU_2018_no23andMe_noMHC.fit.rep${SLURM_ARRAY_TASK_ID} \
      --extract /storage/zhenghoufengLab/xuqi97/software/MiXeR/1000G_EUR_Phase3_plink/1000G.EUR.QC.prune_maf0p05_rand2M_r2p8.rep${SLURM_ARRAY_TASK_ID}.snps \
      --bim-file /storage/zhenghoufengLab/xuqi97/software/MiXeR/1000G_EUR_Phase3_plink/1000G.EUR.QC.@.bim \
      --ld-file /storage/zhenghoufengLab/xuqi97/software/MiXeR/1000G_EUR_Phase3_plink/1000G.EUR.QC.@.run4.ld \
      --lib /storage/zhenghoufengLab/gaisirui/xuqi/software/mixer/src/build/lib/libbgmg.so
