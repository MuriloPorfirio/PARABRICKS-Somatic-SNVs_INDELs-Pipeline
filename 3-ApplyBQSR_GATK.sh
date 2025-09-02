docker run --rm \
  -u $(id -u):$(id -g) \
  -v /home/murilo.aguiar/raid-murilo:/workdir \
  broadinstitute/gatk:latest \
  gatk ApplyBQSR \
    -I /workdir/Processos/06-08-2025-Fastq2bam_output_EXOMAS-LETICIA-FERRO/HJVHNDSX7-1-IDUDI0031.bam \
    -R /workdir/Genomas_de_referencia/humano/Genoma_Referencia_Cancer_in_a_Bottle/GRCh38_GIABv3_no_alt_analysis_set_maskedGRC_decoys_MAP2K3_KMT2C_KCNJ18.fasta \
    --bqsr-recal-file /workdir/Processos/06-08-2025-Fastq2bam_output_EXOMAS-LETICIA-FERRO/HJVHNDSX7-1-IDUDI0031.recal.table \
    -O /workdir/Processos/06-08-2025-Fastq2bam_output_EXOMAS-LETICIA-FERRO/HJVHNDSX7-1-IDUDI0031.recal.bam
