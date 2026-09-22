# Subset to K=3
# Peter Fiorica
# 21 September 2026

library(dplyr)
library(data.table)

list <- fread("/projects/rpci/songyao/pnfioric/MultiEthnic_TILs_GWAS/Local_Ancestry_Inference/gnomad_meta_updated.tsv", header = T)

#fam <- fread("/vscratch/grp-songyao/pnfioric/temp_dir/WCHS_Pathways_HGDP_by_chr/genome_wide_admixture_input.fam", header = F) 
wchs_fam <-fread("/projects/rpci/wchs/pnfioric/WCHS_Merged_0.01_0.3_AABC_AMBER/WCHS_Full_genotypes.fam", header = F)

non_hgdp <- wchs_fam %>% filter(!V1 %in% list$s)%>% select(V1,V2)

list3 <- list %>% filter(`hgdp_tgp_meta.Genetic.region` %in% c("AFR", "EAS", "EUR")) %>% mutate(s2=s) %>% select(V1=s, V2=s2, pop=`hgdp_tgp_meta.Genetic.region`)

hgdp_pw_wchs <- bind_rows(non_hgdp, list3) %>% mutate(pop = if_else(is.na(pop), "GWAS", pop))

fwrite(hgdp_pw_wchs, "/projects/rpci/songyao/pnfioric/Ancestry_Calculation_PW_WCHS/k3_wchs_hgdp.txt", col.names = F, sep = "\t", quote = F, row.names = F)
