#!/bin/bash
#SBATCH --array=1-22
#SBATCH --partition=general-compute --qos=general-compute
#SBATCH --time=48:00:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --constraint=IB
#SBATCH --mem=32000
#SBATCH --job-name="PLINK_genofilter_genotypes"
#SBATCH --output=/projects/rpci/songyao/pnfioric/Ancestry_Calculation_PW_WCHS/logs/WCHS_split_%A_%a.out
#SBATCH --error=/projects/rpci/songyao/pnfioric/Ancestry_Calculation_PW_WCHS/logs/WCHS_split_%A_%a.err

# -----------------------------
# Input/output
# -----------------------------

BASE="/projects/rpci/wchs/pnfioric/WCHS_Merged_0.01_0.3_AABC_AMBER/WCHS_Full_genotypes"
OUT="/vscratch/grp-songyao/pnfioric/temp_dir/WCHS_by_chr"

mkdir -p "$OUT"
mkdir -p "/projects/rpci/songyao/pnfioric/Ancestry_Calculation_PW_WCHS"

# Chromosome corresponding to this array task
CHR=${SLURM_ARRAY_TASK_ID}

echo "========================================"
echo "Job ID:       ${SLURM_JOB_ID}"
echo "Array task:   ${SLURM_ARRAY_TASK_ID}"
echo "Chromosome:   ${CHR}"
echo "Start time:   $(date)"
echo "========================================"

module load gcc foss plink

# -----------------------------
# Run PLINK
# -----------------------------

plink \
    --bfile "$BASE" \
    --chr "$CHR" \
    --make-bed \
    --out "${OUT}/WCHS_chr${CHR}"

# -----------------------------
# Check success
# -----------------------------

if [[ $? -eq 0 ]]; then
    echo "Successfully completed chromosome ${CHR}"
    echo "Output:"
    ls -lh "${OUT}/WCHS_chr${CHR}".{bed,bim,fam}
else
    echo "ERROR: PLINK failed for chromosome ${CHR}"
    exit 1
fi

echo "End time: $(date)"
