#!/bin/bash

# Diretórios e arquivos
BASE="/home/murilo.aguiar/raid-murilo"
BAM_DIR="$BASE/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Com-Cabecalho-Corrigido_AddOrReplaceReadGroups_08-08-2025/3-BAM-Concatenado-Com-Cabecalho-Corrigido_08-08-2025"
OUTPUT_DIR="$BAM_DIR/4-Recalibration_PARABRICKS_output_08-08-2025"
REF_GENOME="$BASE/Genomas_de_referencia/humano/hg38.fa"
TMP_DIR="$BASE/TMP_parabricks"

KNOWN1="$BASE/Genomas_de_referencia/humano/variantes_conhecidas_para_BaseRecalibrator-ApplyBQSR/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"
KNOWN2="$BASE/Genomas_de_referencia/humano/variantes_conhecidas_para_BaseRecalibrator-ApplyBQSR/Homo_sapiens_assembly38.known_indels.vcf.gz"
KNOWN3="$BASE/Genomas_de_referencia/humano/variantes_conhecidas_para_BaseRecalibrator-ApplyBQSR/1000G_phase1.snps.high_confidence.hg38.vcf.gz"

declare -A BAMS=(
  ["KOO311_TUMOR"]="KOO311_TUMOR_merged.bam"
  ["KOO311_NORMAL"]="KOO311_NORMAL_merged.bam"
)

# Loop de execução para cada amostra
for SAMPLE_NAME in "${!BAMS[@]}"; do
  BAM_FILE="${BAMS[$SAMPLE_NAME]}"
  
  echo "===> Recalibrando: $SAMPLE_NAME"

  docker run --rm \
    --gpus '"device=7"' \
    --volume "$BASE":/workdir \
    --workdir /workdir \
    --user 1006 \
    nvcr.io/nvidia/clara/clara-parabricks:4.5.1-1 \
    pbrun bqsr \
      --ref /workdir/$(realpath --relative-to="$BASE" "$REF_GENOME") \
      --in-bam /workdir/$(realpath --relative-to="$BASE" "$BAM_DIR/$BAM_FILE") \
      --knownSites /workdir/$(realpath --relative-to="$BASE" "$KNOWN1") \
      --knownSites /workdir/$(realpath --relative-to="$BASE" "$KNOWN2") \
      --knownSites /workdir/$(realpath --relative-to="$BASE" "$KNOWN3") \
      --out-recal-file /workdir/$(realpath --relative-to="$BASE" "$OUTPUT_DIR")/"$SAMPLE_NAME.recal.table" \
      --tmp-dir /workdir/$(realpath --relative-to="$BASE" "$TMP_DIR")

  echo " Finalizado: $SAMPLE_NAME"
  echo "----------------------------------------"
done
