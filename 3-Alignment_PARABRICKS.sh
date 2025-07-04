#!/bin/bash

# ============================================
# Non-Interactive Parabricks fq2bam Pipeline
# Author: Murilo Porfírio & としろ
# ============================================

SCRIPT_START_TIME=$(date +%s)  # Start total time counter

# ===================== PARAMETERS =====================

# Input FASTQ directory
INPUT_DIR="/path/to/fastq"

# FASTQ files in R1 R2 order
FASTQ_FILES=("sample1_R1.fastq.gz" "sample1_R2.fastq.gz" "sample2_R1.fastq.gz" "sample2_R2.fastq.gz")

# Reference genome
GENOME_FA="/path/to/reference/hg38.fa"

# KnownSites (optional) - leave empty if not used
KNOWN_SITES=("/path/to/dbsnp.vcf" "/path/to/mills.vcf")

# Custom UID (optional) - set to empty to use root
CUSTOM_UID=1001

# GPU indexes to use
SELECTED_GPUS="0"

# Enable low memory mode? (yes/no)
USE_LOW_MEMORY="yes"

# Temporary directory for processing
TMP_DIR="/fast_ssd/tmp"

# Number of CPU threads for BWA
CPU_THREADS=32

# Enable GPU sort/write? (yes/no)
GPU_OPTIMIZE="yes"

# Enable GDS? (yes/no)
USE_GDS="no"

# ===================== PROCESS =====================

# Parse user mode
USE_USER=""
if [[ "$CUSTOM_UID" =~ ^[0-9]+$ ]]; then
  USE_USER="--user $CUSTOM_UID"
fi

# Prepare knownSites parameters
KNOWN_SITES_PARAM=""
KNOWN_SITES_MOUNT=""
for i in "${!KNOWN_SITES[@]}"; do
  KS_FILE="${KNOWN_SITES[$i]}"
  ks_index=$((i+1))
  if [[ -f "$KS_FILE" ]]; then
    KNOWN_SITES_PARAM+=" --knownSites /knownsites$ks_index/$(basename "$KS_FILE")"
    KNOWN_SITES_MOUNT+=" -v $(dirname "$KS_FILE"):/knownsites$ks_index"
  fi
done

# Flags
LOW_MEMORY_PARAM=""
[[ "$USE_LOW_MEMORY" == "yes" ]] && LOW_MEMORY_PARAM="--low-memory"

GPU_OPT_PARAM=""
[[ "$GPU_OPTIMIZE" == "yes" ]] && GPU_OPT_PARAM="--gpusort --gpuwrite"

GDS_PARAM=""
[[ "$USE_GDS" == "yes" ]] && GDS_PARAM="--use-gds"

TMP_DIR_PARAM=""
TMP_DIR_MOUNT=""
if [[ -n "$TMP_DIR" ]]; then
  TMP_DIR_PARAM="--tmp-dir /tmp_dir"
  TMP_DIR_MOUNT="-v $TMP_DIR:/tmp_dir"
fi

# Output directory
TIMESTAMP=$(date +"%d-%m-%Y_%Hh%Mm")
OUTPUT_DIR="$INPUT_DIR/4-parabricks_output_$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

# Log output
SCRIPT_LOG="$OUTPUT_DIR/run_log.txt"
exec > >(tee -a "$SCRIPT_LOG") 2>&1

# Run fq2bam for each sample
NUM_FILES=${#FASTQ_FILES[@]}
for ((i=0; i<NUM_FILES; i+=2)); do
  SAMPLE_R1=${FASTQ_FILES[$i]}
  SAMPLE_R2=${FASTQ_FILES[$((i+1))]}
  SAMPLE_NAME=$(basename "$SAMPLE_R1" | cut -d '_' -f1)

  OUTPUT_BAM="/outputdir/${SAMPLE_NAME}_aligned.bam"
  RECAL_FILE="/outputdir/${SAMPLE_NAME}_recal.txt"

  SAMPLE_START_TIME=$(date +%s)

  echo ""
  echo "Processing sample: $SAMPLE_NAME"

  docker run --rm --gpus "device=$SELECTED_GPUS" $USE_USER \
    -v "$INPUT_DIR":/workdir \
    -v "$OUTPUT_DIR":/outputdir \
    -v "$(dirname "$GENOME_FA")":/refdir \
    $KNOWN_SITES_MOUNT \
    $TMP_DIR_MOUNT \
    nvcr.io/nvidia/clara/clara-parabricks:4.5.1-1 \
    pbrun fq2bam \
    --ref /refdir/$(basename "$GENOME_FA") \
    --in-fq /workdir/$SAMPLE_R1 /workdir/$SAMPLE_R2 \
    --out-bam $OUTPUT_BAM \
    --out-recal-file $RECAL_FILE \
    $KNOWN_SITES_PARAM \
    $LOW_MEMORY_PARAM \
    $TMP_DIR_PARAM \
    --bwa-cpu-thread-pool $CPU_THREADS \
    $GPU_OPT_PARAM \
    $GDS_PARAM

  SAMPLE_END_TIME=$(date +%s)
  echo "Sample $SAMPLE_NAME completed in $((SAMPLE_END_TIME - SAMPLE_START_TIME)) seconds."
done

# Total time
SCRIPT_END_TIME=$(date +%s)
TOTAL_DURATION=$((SCRIPT_END_TIME - SCRIPT_START_TIME))
echo ""
echo "All samples processed. Total time: ${TOTAL_DURATION}s"
echo "Output directory: $OUTPUT_DIR"

exit 0
