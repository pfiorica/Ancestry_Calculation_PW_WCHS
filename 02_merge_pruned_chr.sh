#!/bin/bash
#SBATCH --job-name=02_Merge_Pruned_Files
#SBATCH --partition=general-compute --qos=general-compute
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=logs/R-%x_%A_%a.out         # Logs: logs/admix_global_ancestry_<JobID>_<ArrayID>.out
#SBATCH --error=logs/R-%x_%A_%a.err          # Errors: logs/admix_global_ancestry_<JobID>_<ArrayID>.err


merged_dir="/vscratch/grp-songyao/pnfioric/temp_dir/WCHS_Pathways_HGDP_by_chr"
cd $merged_dir

# Generate list of chromosome files to merge (chr2 through chr22)
rm -f merge_list.txt
for chr in {2..22}; do
    echo "merged_pruned_chr${chr}.bed merged_pruned_chr${chr}.bim merged_pruned_chr${chr}.fam" >> merge_list.txt
done

module load gcc foss plink

# Merge all chromosomes into a single genome-wide dataset
plink --bfile merged_pruned_chr1 \
      --merge-list merge_list.txt \
      --make-bed \
      --out genome_wide_admixture_input
