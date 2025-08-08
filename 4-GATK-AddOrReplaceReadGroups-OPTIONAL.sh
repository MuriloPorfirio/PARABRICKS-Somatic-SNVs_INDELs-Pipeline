#!/bin/bash
# === JUST IN CASE YOU REACH THIS STEP WITH BAM FILES MISSING OR HAVING INCORRECT READ GROUP HEADERS ===
# Fix BAM headers if original files were generated without proper @RG fields (SM, PL, etc.)

docker run --rm \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025:/input \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Com-Cabecalho-Corrigido_AddOrReplaceReadGroups_08-08-2025:/output \
  broadinstitute/gatk:latest \
  gatk AddOrReplaceReadGroups \
  -I /input/KOO311-T_S15_L001.bam \
  -O /output/KOO311-T_S15_L001_fixed.bam \
  -RGID T_L001 \
  -RGLB lib1 \
  -RGPL ILLUMINA \
  -RGPU L001 \
  -RGSM KOO311_TUMOR

docker run --rm \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025:/input \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Com-Cabecalho-Corrigido_AddOrReplaceReadGroups_08-08-2025:/output \
  broadinstitute/gatk:latest \
  gatk AddOrReplaceReadGroups \
  -I /input/KOO311-T_S31_L002.bam \
  -O /output/KOO311-T_S31_L002_fixed.bam \
  -RGID T_L002 \
  -RGLB lib1 \
  -RGPL ILLUMINA \
  -RGPU L002 \
  -RGSM KOO311_TUMOR

docker run --rm \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025:/input \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Com-Cabecalho-Corrigido_AddOrReplaceReadGroups_08-08-2025:/output \
  broadinstitute/gatk:latest \
  gatk AddOrReplaceReadGroups \
  -I /input/KOO311-T_S79_L005.bam \
  -O /output/KOO311-T_S79_L005_fixed.bam \
  -RGID T_L005 \
  -RGLB lib1 \
  -RGPL ILLUMINA \
  -RGPU L005 \
  -RGSM KOO311_TUMOR

docker run --rm \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025:/input \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Com-Cabecalho-Corrigido_AddOrReplaceReadGroups_08-08-2025:/output \
  broadinstitute/gatk:latest \
  gatk AddOrReplaceReadGroups \
  -I /input/KOO311-T_S95_L006.bam \
  -O /output/KOO311-T_S95_L006_fixed.bam \
  -RGID T_L006 \
  -RGLB lib1 \
  -RGPL ILLUMINA \
  -RGPU L006 \
  -RGSM KOO311_TUMOR

docker run --rm \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025:/input \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Com-Cabecalho-Corrigido_AddOrReplaceReadGroups_08-08-2025:/output \
  broadinstitute/gatk:latest \
  gatk AddOrReplaceReadGroups \
  -I /input/KOO311-N_S16_L001.bam \
  -O /output/KOO311-N_S16_L001_fixed.bam \
  -RGID N_L001 \
  -RGLB lib1 \
  -RGPL ILLUMINA \
  -RGPU L001 \
  -RGSM KOO311_NORMAL

docker run --rm \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025:/input \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Com-Cabecalho-Corrigido_AddOrReplaceReadGroups_08-08-2025:/output \
  broadinstitute/gatk:latest \
  gatk AddOrReplaceReadGroups \
  -I /input/KOO311-N_S32_L002.bam \
  -O /output/KOO311-N_S32_L002_fixed.bam \
  -RGID N_L002 \
  -RGLB lib1 \
  -RGPL ILLUMINA \
  -RGPU L002 \
  -RGSM KOO311_NORMAL

docker run --rm \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025:/input \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Com-Cabecalho-Corrigido_AddOrReplaceReadGroups_08-08-2025:/output \
  broadinstitute/gatk:latest \
  gatk AddOrReplaceReadGroups \
  -I /input/KOO311-N_S80_L005.bam \
  -O /output/KOO311-N_S80_L005_fixed.bam \
  -RGID N_L005 \
  -RGLB lib1 \
  -RGPL ILLUMINA \
  -RGPU L005 \
  -RGSM KOO311_NORMAL

docker run --rm \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025:/input \
  -v /home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Com-Cabecalho-Corrigido_AddOrReplaceReadGroups_08-08-2025:/output \
  broadinstitute/gatk:latest \
  gatk AddOrReplaceReadGroups \
  -I /input/KOO311-N_S96_L006.bam \
  -O /output/KOO311-N_S96_L006_fixed.bam \
  -RGID N_L006 \
  -RGLB lib1 \
  -RGPL ILLUMINA \
  -RGPU L006 \
  -RGSM KOO311_NORMAL

