time docker run --rm --gpus device=7 \  # Measure total runtime; start a temporary container (deleted at the end) and expose only GPU #7. Change 7 to the GPU you want, or use "all" to expose all GPUs.
  -v /home/murilo.aguiar/raid-murilo:/workdir \  # Mount this host folder into the container at /workdir. Put here the real path on your machine that holds the reference FASTA (and any shared files).
  -v /home/murilo.aguiar/raid-murilo/Processos/06-08-2025-Fastq2bam_output_EXOMAS-LETICIA-FERRO:/outputdir \  # Mount the folder that already has your fq2bam outputs (BAM + .recal.table) and where the recalibrated BAM will be written.
  --workdir /workdir \  # Set the working directory inside the container. Any path starting with /workdir points to the first mount above.
  nvcr.io/nvidia/clara/clara-parabricks:4.5.1-1 \  # Parabricks image that contains the "pbrun applybqsr" tool. Change the tag if you use another version.
  pbrun applybqsr \  # Tool that APPLIES the BQSR corrections (uses the recalibration table to adjust base quality scores in the BAM).

    --ref /workdir/Genomas_de_referencia/humano/Genoma_Referencia_Cancer_in_a_Bottle/GRCh38_GIABv3_no_alt_analysis_set_maskedGRC_decoys_MAP2K3_KMT2C_KCNJ18.fasta \  # Reference FASTA. Must be the SAME one used in fq2bam and must match your knownSites build. Ideally have .fai and .dict generated.
    --in-bam /outputdir/HJVHNDSX7-1-IDUDI0031.bam \  # Input BAM from fq2bam (already aligned and duplicates marked). Make sure this file exists in /outputdir.
    --in-recal-file /outputdir/HJVHNDSX7-1-IDUDI0031.recal.table \  # The BQSR table created by BaseRecalibrator (from fq2bam). This is the “map” of corrections to apply.
    --out-bam /outputdir/HJVHNDSX7-1-IDUDI0031.bqsr.bam \  # Output BAM AFTER applying BQSR (new, corrected base qualities). Choose whatever filename you like.
    --num-gpus 1 \  # Tell Parabricks how many visible GPUs to use. Since you exposed only one (GPU 7), “1” is fine (you could even omit this).
    --num-threads 16 \  # CPU threads to use. Adjust to your machine (e.g., 8, 16, 32). More threads isn’t always faster; pick a sensible number.
    --tmp-dir /workdir/TMP_parabricks  # Temporary folder for intermediate files. Make sure it has free space; using a fast disk (NVMe) helps.
