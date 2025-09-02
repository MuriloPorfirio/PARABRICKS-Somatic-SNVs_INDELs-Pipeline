time docker run --rm --gpus device=7 \
  -v /home/murilo.aguiar/raid-murilo:/workdir \
  -v /home/murilo.aguiar/raid-murilo/Processos/06-08-2025-Fastq2bam_output_EXOMAS-LETICIA-FERRO:/outputdir \
  --workdir /workdir \
  nvcr.io/nvidia/clara/clara-parabricks:4.5.1-1 \
  pbrun applybqsr \
    --ref /workdir/Genomas_de_referencia/humano/Genoma_Referencia_Cancer_in_a_Bottle/GRCh38_GIABv3_no_alt_analysis_set_maskedGRC_decoys_MAP2K3_KMT2C_KCNJ18.fasta \
    --in-bam /outputdir/HJVHNDSX7-1-IDUDI0031.bam \
    --in-recal-file /outputdir/HJVHNDSX7-1-IDUDI0031.recal.table \
    --out-bam /outputdir/HJVHNDSX7-1-IDUDI0031.bqsr.bam \
    --num-gpus 1 \
    --num-threads 16 \
    --tmp-dir /workdir/TMP_parabricks
