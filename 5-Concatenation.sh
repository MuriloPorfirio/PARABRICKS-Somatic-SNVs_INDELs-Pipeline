#!/bin/bash
# === MERGE por amostra com Read Groups corrigidos ===

docker run --rm \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Com-Cabecalho-Corrigido_AddOrReplaceReadGroups_08-08-2025:/input \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Com-Cabecalho-Corrigido_AddOrReplaceReadGroups_08-08-2025/3-BAM-Concatenado-Com-Cabecalho-Corrigido_08-08-2025:/output \
  staphb/samtools \
  bash -c "
    echo '==> MERGING TUMOR BAMs'
    samtools merge -f /output/KOO311_TUMOR_merged.bam \
      /input/KOO311-T_S15_L001_fixed.bam \
      /input/KOO311-T_S31_L002_fixed.bam \
      /input/KOO311-T_S79_L005_fixed.bam \
      /input/KOO311-T_S95_L006_fixed.bam

    echo '==> MERGING NORMAL BAMs'
    samtools merge -f /output/KOO311_NORMAL_merged.bam \
      /input/KOO311-N_S16_L001_fixed.bam \
      /input/KOO311-N_S32_L002_fixed.bam \
      /input/KOO311-N_S80_L005_fixed.bam \
      /input/KOO311-N_S96_L006_fixed.bam
  "
