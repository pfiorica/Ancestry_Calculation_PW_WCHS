#!/bin/bash
#SBATCH --job-name="01_plink_prune"
#SBATCH --array=1-22
#SBATCH --partition=general-compute --qos=general-compute
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --output=/projects/rpci/songyao/pnfioric/Ancestry_Calculation_PW_WCHS/logs/R-01_plink_prune_%A_%a.out
#SBATCH --error=/projects/rpci/songyao/pnfioric/Ancestry_Calculation_PW_WCHS/logs/R_01-plink_prune_%A_%a.err

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

MERGED_BASE="/vscratch/grp-songyao/pnfioric/temp_dir/WCHS_Pathways_HGDP_by_chr"

CHR="${SLURM_ARRAY_TASK_ID}"

RAW_PREFIX="${MERGED_BASE}/merged_raw_chr${CHR}"
PRUNE_TEMP="${MERGED_BASE}/temp_prune_chr${CHR}"
FINAL_PREFIX="${MERGED_BASE}/merged_pruned_chr${CHR}"

THREADS="${SLURM_CPUS_PER_TASK}"

# ============================================================
# Logging
# ============================================================

echo "============================================================"
echo "PLINK QC + LD PRUNING"
echo "============================================================"
echo "Job ID:        ${SLURM_JOB_ID}"
echo "Array Job ID:  ${SLURM_ARRAY_JOB_ID}"
echo "Array Task ID: ${SLURM_ARRAY_TASK_ID}"
echo "Chromosome:    ${CHR}"
echo "CPUs:          ${THREADS}"
echo "Start:         $(date)"
echo ""
echo "Raw prefix:    ${RAW_PREFIX}"
echo "Prune prefix:  ${PRUNE_TEMP}"
echo "Final prefix:  ${FINAL_PREFIX}"
echo "============================================================"

# ============================================================
# Check input files
# ============================================================

for ext in bed bim fam; do
    FILE="${RAW_PREFIX}.${ext}"

    if [[ ! -f "${FILE}" ]]; then
        echo "ERROR: Missing input file:"
        echo "  ${FILE}"
        exit 1
    fi
done

echo ""
echo "Input files found:"
ls -lh \
    "${RAW_PREFIX}.bed" \
    "${RAW_PREFIX}.bim" \
    "${RAW_PREFIX}.fam"

# ============================================================
# Step 1: QC + identify independent variants
#
# geno 0.05      = remove variants with >5% missingness
# maf 0.05       = MAF >= 5%
# max-maf 0.95   = MAF <= 95%
# snps-only      = retain SNPs
# indep-pairwise:
#     50 window
#     shift 10 variant at a time
#     r2 threshold 0.1
# ============================================================

module load gcc foss plink

echo ""
echo "============================================================"
echo "Step 1: PLINK QC + LD pruning"
echo "============================================================"
echo "Start: $(date)"

plink \
    --bfile "${RAW_PREFIX}" \
    --geno 0.05 \
    --maf 0.05 \
    --snps-only \
    --indep-pairwise 50 10 0.1 \
    --threads "${THREADS}" \
    --out "${PRUNE_TEMP}"

echo ""
echo "Step 1 complete: $(date)"

# Make sure PLINK actually produced the prune list
if [[ ! -f "${PRUNE_TEMP}.prune.in" ]]; then
    echo "ERROR: ${PRUNE_TEMP}.prune.in was not created."
    exit 1
fi

echo ""
echo "Number of variants retained for pruning:"
wc -l "${PRUNE_TEMP}.prune.in"

# ============================================================
# Step 2: Extract pruned variants
# ============================================================

echo ""
echo "============================================================"
echo "Step 2: Extract pruned variants"
echo "============================================================"
echo "Start: $(date)"

plink \
    --bfile "${RAW_PREFIX}" \
    --extract "${PRUNE_TEMP}.prune.in" \
    --make-bed \
    --threads "${THREADS}" \
    --out "${FINAL_PREFIX}"

echo ""
echo "Step 2 complete: $(date)"

# ============================================================
# Verify final output
# ============================================================

echo ""
echo "============================================================"
echo "Verifying final PLINK files"
echo "============================================================"

for ext in bed bim fam; do
    FILE="${FINAL_PREFIX}.${ext}"

    if [[ ! -f "${FILE}" ]]; then
        echo "ERROR: Missing output file:"
        echo "  ${FILE}"
        exit 1
    fi
done

echo ""
echo "Final files:"
ls -lh \
    "${FINAL_PREFIX}.bed" \
    "${FINAL_PREFIX}.bim" \
    "${FINAL_PREFIX}.fam"

echo ""
echo "Number of final variants:"
wc -l "${FINAL_PREFIX}.bim"

# ============================================================
# Cleanup intermediate files
# ============================================================

echo ""
echo "Cleaning up intermediate pruning files..."

rm -f \
    "${PRUNE_TEMP}.prune.in" \
    "${PRUNE_TEMP}.prune.out" \
    "${PRUNE_TEMP}.log" \
    "${PRUNE_TEMP}.nosex"

echo "Cleanup complete."

# ============================================================
# Done
# ============================================================

echo ""
echo "============================================================"
echo "Chromosome ${CHR} FINISHED SUCCESSFULLY"
echo "End: $(date)"
echo "============================================================"
