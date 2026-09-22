#!/bin/bash
#SBATCH --job-name=03A_keep_k3
#SBATCH --output=logs/R-%x_%A_%a.out         # Logs: logs/admix_global_ancestry_<JobID>_<ArrayID>.out
#SBATCH --error=logs/R-%x_%A_%a.err          # Errors: logs/admix_global_ancestry_<JobID>_<ArrayID>.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --partition=general-compute --qos=general-compute

module load gcc foss plink

BASE="/vscratch/grp-songyao/pnfioric/temp_dir/WCHS_Pathways_HGDP_by_chr"
KEEP="/projects/rpci/songyao/pnfioric/Ancestry_Calculation_PW_WCHS/k3_wchs_hgdp.txt"

CHR=${SLURM_ARRAY_TASK_ID}

plink \
    --bfile ${BASE}/genome_wide_admixture_input \
    --keep "${KEEP}" \
    --make-bed \
    --threads "${SLURM_CPUS_PER_TASK}" \
    --out ${BASE}/genome_wide_admixture_k3_wchs