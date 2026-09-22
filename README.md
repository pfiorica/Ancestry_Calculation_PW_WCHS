---
title: "ADMIXTURE Estimation for WCHS and Pathways"
author: "Peter Fiorica"
date: "`r Sys.Date()`"
output: html_document
---

# Introduction

For Qiao Wang's thesis project, she request global ancestry estimated for WCHS and Pathways. Previously, I calculated these with filtered data for individuals from WCHS and Pathways with matching TILs data. This substantially limited the WCHS dataset and moderately limited the Pathways data. Instead the plan is to merge all 6692 samples in the WCHS shared directory and the 4300+ samples with Pathways genotypes. When I performed this analysis in my data, I used RFMix and FLARE for local ancestry estimation primarily; however, these software also calculate chromosome-level global ancestry data.

The plan this time is to use ADMIXTURE [1]. ADMIXTURE allows for global ancestry estimation without phasing. The phasing step takes some time, so ADMIXTURE is preferred. ADMIXTURE is also the field standard for global ancestry estimation.

# Starting Files

    ln -s /projects/rpci/wchs/pnfioric/WCHS_Merged_0.01_0.3_AABC_AMBER/WCHS_Full_genotypes.bed WCHS_Full_genotypes.bed
    ln -s /projects/rpci/wchs/pnfioric/WCHS_Merged_0.01_0.3_AABC_AMBER/WCHS_Full_genotypes.fam WCHS_Full_genotypes.fam
    ln -s /projects/rpci/wchs/pnfioric/WCHS_Merged_0.01_0.3_AABC_AMBER/WCHS_Full_genotypes.bim WCHS_Full_genotypes.bim
    ln -s /projects/rpci/wchs/pnfioric/WCHS_Merged_0.01_0.3_AABC_AMBER/WCHS_Full_genotypes.log WCHS_Full_genotypes.log

# Processing

1.  `00_Split_WCHS.sh`: Splits the WCHS genotypes into individuals autosomes, so it is easier for merging and pruning.

2.  `Merging_PW_WCHS_1kGP_HGDP.ipynb`: This merges Pathways, WCHS, and the reference data for ancestry estimation. It is not particularly efficient, but the reference data is large. The code had also already been written in hail in the past.

3.  `01_Pruning_Merged.sh`: This performs the LD pruning before running ADMIXTURE on the data.

4.   `02_merge_pruned_chr.sh` : This combines all the pruned chromosome level data

5.  `03_Subset_Reference_WCHS.R` : This subsets the data to include only the 3 super populations from the reference data and WCHS data. We remove Pathways and samples that are not EUR, EAS, or AFR here.

6.  `04_keep_list_k3.sh`: The actual plink command that filters the genotypes. Subset data to k=3.

7.  `05_run_admixture.sh` : Runs admixture. This script can be adjusted to be run as an array for K=2 to K=12. This is currently set at K=3.

8.  `06_Process_Admixture_Results.Rmd` : Processes the admixture results and write file for Qiao.

[***Important Side Note:***]{.underline}

The following IDs need to be removed downstream. While their genotypic data is reliable, their corresponding phenotypic data is not.

NJ00999 NJ01262 NJ01271 NJ01325 NJ01409 NJ01413 NJ01520 NJ01563 NJ01614 NJ02871

### References

[1] D.H. Alexander, J. Novembre, and K. Lange. Fast model-based estimation of ancestry in unrelated individuals. Genome Research, 19:1655--1664, 2009.

### Methods text

Germline genotypes went through standard GWAS QC [Turner et al.]. Following QC, genotypes were imputed with the TOPMed Imputation Panel [Das et al.] Imputed genotypes were filter to R^2^\>0.3 and MAF \>0.001. Following post-imputation filtering, the datasets were merged with 3398 harmonized 1000 Genomes Project & Human Genome Diversity Project samples [Koenig et al]. Samples were subsequently filtered to include only samples from the African, East Asian, and European super populations. The combined dataset was then filtered to genotyping rate \>95% and MAF \>0.05. Pruning was performed with PLINK with the `--indep-pairwise 50 10 0.1` flag with the stated parameters [Purcell et al.]. Following pruning, 262,666 variants were used for K=3 ancestry estimation with ADMIXTURE.

### Text References

Das S, Forer L, Schönherr S, Sidore C, Locke AE, Kwong A, Vrieze S, Chew EY, Levy S, McGue M, Schlessinger D, Stambolian D, Loh PR, Iacono WG, Swaroop A, Scott LJ, Cucca F, Kronenberg F, Boehnke M, Abecasis GR, Fuchsberger C. [Next-generation genotype imputation service and methods](https://www.ncbi.nlm.nih.gov/pubmed/27571263). Nature Genetics 48, 1284--1287 (2016).

Koenig Z, Yohannes MT, Nkambule LL, Zhao X, Goodrich JK, Kim HA, Wilson MW, Tiao G, Hao SP, Sahakian N, Chao KR, Walker MA, Lyu Y; gnomAD Project Consortium; Rehm HL, Neale BM, Talkowski ME, Daly MJ, Brand H, Karczewski KJ, Atkinson EG, Martin AR. A harmonized public resource of deeply sequenced diverse human genomes. Genome Res. 2024 Jun 25;34(5):796-809. doi: 10.1101/gr.278378.123. PMID: 38749656; PMCID: PMC11216312.

Purcell S, Neale B, Todd-Brown K, Thomas L, Ferreira MA, Bender D, Maller J, Sklar P, de Bakker PI, Daly MJ, Sham PC. PLINK: a tool set for whole-genome association and population-based linkage analyses. Am J Hum Genet. 2007 Sep;81(3):559-75. doi: 10.1086/519795. Epub 2007 Jul 25. PMID: 17701901; PMCID: PMC1950838.

Turner S, Armstrong LL, Bradford Y, Carlson CS, Crawford DC, Crenshaw AT, de Andrade M, Doheny KF, Haines JL, Hayes G, Jarvik G, Jiang L, Kullo IJ, Li R, Ling H, Manolio TA, Matsumoto M, McCarty CA, McDavid AN, Mirel DB, Paschall JE, Pugh EW, Rasmussen LV, Wilke RA, Zuvich RL, Ritchie MD. Quality control procedures for genome-wide association studies. Curr Protoc Hum Genet. 2011 Jan;Chapter 1:Unit1.19. doi: 10.1002/0471142905.hg0119s68. PMID: 21234875; PMCID: PMC3066182.
