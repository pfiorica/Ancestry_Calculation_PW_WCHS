#!/bin/bash
#SBATCH --job-name=03_admix_global_ancestry
#SBATCH --output=logs/R-%x_%A_%a.out         # Logs: logs/admix_global_ancestry_<JobID>_<ArrayID>.out
#SBATCH --error=logs/R-%x_%A_%a.err          # Errors: logs/admix_global_ancestry_<JobID>_<ArrayID>.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=general-compute --qos=general-compute
#SBATCH --array=3                        # Runs K = 2 through 7 concurrently

# Create required output directories
mkdir -p logs results

# Load required module or Conda environment

module purge
#module load admixture/1.3.0

# Define variables
INPUT_BED="/vscratch/grp-songyao/pnfioric/temp_dir/WCHS_Pathways_HGDP_by_chr/genome_wide_admixture_k3_wchs.bed"  # Path to your QC/LD-pruned PLINK bed file
K_VAL=${SLURM_ARRAY_TASK_ID}
THREADS=${SLURM_CPUS_PER_TASK}
SEED=$((1000 + K_VAL * 37))  # Unique deterministic seed per K

cd results

# Execute ADMIXTURE with 5-fold cross-validation
/projects/rpci/songyao/pnfioric/software/admixture_linux-1.4.0/admixture --cv=5 -j${THREADS} -s ${SEED} ${INPUT_BED} ${K_VAL} | tee filt_admix_K${K_VAL}.log

echo "ADMIXTURE execution complete for K=${K_VAL}"
