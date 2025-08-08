time docker run --rm --gpus '"device=7"' \ #<<< Set the GPU device to use
    --volume /home/murilo.aguiar/raid-murilo:/workdir \ #<<< Mount the host data directory
    --volume /home/murilo.aguiar/raid-murilo/Processos/06-08-2025-Fastq2bam_output_EXOMAS-LETICIA-FERRO:/outputdir \ #<<< Mount the output directory
    --workdir /workdir \ #<<< Working directory inside the container
    --user 1006 \ #<<< UID to avoid permission issues when writing files
    nvcr.io/nvidia/clara/clara-parabricks:4.5.1-1 \ #<<< Parabricks image with fq2bam
    pbrun fq2bam \
    --ref /workdir/Genomas_de_referencia/humano/Genoma_Referencia_Cancer_in_a_Bottle/GRCh38_GIABv3_no_alt_analysis_set_maskedGRC_decoys_MAP2K3_KMT2C_KCNJ18.fasta \ #<<< Reference genome
    --in-fq /workdir/Processos/Fastq_Trimados_11-07-2025/HJVHNDSX7-1-IDUDI0031_S12_L001_R1_001_val_1.fq.gz \
            /workdir/Processos/Fastq_Trimados_11-07-2025/HJVHNDSX7-1-IDUDI0031_S12_L001_R2_001_val_2.fq.gz \ #<<< Paired-end FASTQ files
    --knownSites /workdir/Genomas_de_referencia/humano/variantes_conhecidas_para_BaseRecalibrator-ApplyBQSR/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
    --knownSites /workdir/Genomas_de_referencia/humano/variantes_conhecidas_para_BaseRecalibrator-ApplyBQSR/Homo_sapiens_assembly38.known_indels.vcf.gz \
    --knownSites /workdir/Genomas_de_referencia/humano/variantes_conhecidas_para_BaseRecalibrator-ApplyBQSR/1000G_phase1.snps.high_confidence.hg38.vcf.gz \ #<<< Known sites for BQSR
    --out-bam /outputdir/HJVHNDSX7-1-IDUDI0031-part1.bam \ #<<< Output BAM file
    --out-recal-file /outputdir/HJVHNDSX7-1-IDUDI0031.recal.table \ #<<< BQSR table output
    --out-duplicate-metrics /outputdir/HJVHNDSX7-1-IDUDI0031.dup_metrics.txt \ #<<< Duplicate metrics output
    --out-qc-metrics-dir /outputdir/qc_metrics \ #<<< QC metrics output directory
    --tmp-dir /workdir/TMP_parabricks \ #<<< Temp dir for intermediate files
    --num-cpu-threads-per-stage 32 \ #<<< Threads per stage (adjust to your server)

    #OPTIONAL (If you opt to not do that, be asure the head is correct after alignment):
    --read-group-id HJVHNDSX7-1-IDUDI0031 \ #<<< RGID: Unique ID, use flowcell or sample-specific code from FASTQ file name
    --read-group-sm KOO311_TUMOR \ #<<< RGSM: Sample name — must match '--tumor-sample' or '--normal-sample' in variant calling
    --read-group-lb lib1 \ #<<< RGLB: Library name — arbitrary, can be 'lib1' unless specific info is available
    --read-group-pl ILLUMINA \ #<<< RGPL: Platform — choose from ILLUMINA, IONTORRENT, ONT, etc.
    --read-group-pu HJVHNDSX7.1.L001 \ #<<< RGPU: Platform Unit — usually flowcell.lane info, extract from FASTQ or sequencer naming
