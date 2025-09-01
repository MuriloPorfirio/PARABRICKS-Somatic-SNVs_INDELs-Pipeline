time docker run --rm --gpus device=7 \  # [OPCIONAL - DOCKER] Mede o tempo total ("time"), remove o contêiner ao fim (--rm) e usa a GPU nº 7. Troque 7 pela GPU desejada (0,1,2...). Para usar todas, use "all".
  --volume /home/murilo.aguiar/raid-murilo:/workdir \  # [OPCIONAL - DOCKER] Monta sua pasta do computador dentro do contêiner em /workdir. Troque o caminho da esquerda pelo local correto no seu host.
  --volume /home/murilo.aguiar/raid-murilo/Processos/06-08-2025-Fastq2bam_output_EXOMAS-LETICIA-FERRO:/outputdir \  # [OPCIONAL - DOCKER] Pasta do host onde os resultados serão salvos. Garanta permissão de escrita.
  --workdir /workdir \  # [OPCIONAL - DOCKER] Define a pasta de trabalho dentro do contêiner. Todos os caminhos que começam com /workdir devem existir no host (pois /workdir aponta para a primeira montagem).
  --user 1006 \  # [OPCIONAL - DOCKER] Força o processo a rodar com seu UID (ex.: 1006) para evitar arquivos de saída como "root". Descubra seu UID com "id -u".
  nvcr.io/nvidia/clara/clara-parabricks:4.5.1-1 \  # [OBRIGATÓRIO - IMAGEM] Escolhe a imagem do Parabricks (versão 4.5.1-1) que contém o "pbrun fq2bam".
  pbrun fq2bam \  # [OBRIGATÓRIO - COMANDO] Inicia o pipeline fq2bam (BWA-MEM acelerado + sort + markdups + BQSR opcional).

  --ref /workdir/Genomas_de_referencia/humano/Genoma_Referencia_Cancer_in_a_Bottle/GRCh38_GIABv3_no_alt_analysis_set_maskedGRC_decoys_MAP2K3_KMT2C_KCNJ18.fasta \  # [OBRIGATÓRIO] Caminho do FASTA de referência. Deve combinar com os VCFs (mesma build hg38). Tenha .fai e .dict gerados.
  --in-fq /workdir/Processos/Fastq_Trimados_11-07-2025/HJVHNDSX7-1-IDUDI0031_S12_L001_R1_001_val_1.fq.gz \  # [CONDICIONAL] Entrada em pares (R1). É necessário fornecer alguma fonte de leitura: --in-fq (pares), OU --in-se-fq (single), OU --in-fq-list (arquivo de lista).
          /workdir/Processos/Fastq_Trimados_11-07-2025/HJVHNDSX7-1-IDUDI0031_S12_L001_R2_001_val_2.fq.gz \  # [CONDICIONAL] Entrada em pares (R2). Combine com o R1 correspondente. Arquivos .fastq.gz são aceitos.
  --knownSites /workdir/Genomas_de_referencia/humano/variantes_conhecidas_para_BaseRecalibrator-ApplyBQSR/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \  # [OPCIONAL] VCF de variantes conhecidas. Ativa BQSR somente se **também** tiver --out-recal-file. Precisa de índice .tbi ao lado.
  --knownSites /workdir/Genomas_de_referencia/humano/variantes_conhecidas_para_BaseRecalibrator-ApplyBQSR/Homo_sapiens_assembly38.known_indels.vcf.gz \  # [OPCIONAL] Mais um VCF de indels conhecidos (recomendado). Também .tbi presente.
  --knownSites /workdir/Genomas_de_referencia/humano/variantes_conhecidas_para_BaseRecalibrator-ApplyBQSR/1000G_phase1.snps.high_confidence.hg38.vcf.gz \  # [OPCIONAL] VCF de SNPs conhecidos (recomendado). Também precisa do .tbi.
  --out-bam /outputdir/HJVHNDSX7-1-IDUDI0031-part1.bam \  # [OBRIGATÓRIO] Saída principal alinhada (BAM ou CRAM). Use .bam (ou .cram). Será escrito em /outputdir no host.
  --out-recal-file /outputdir/HJVHNDSX7-1-IDUDI0031.recal.table \  # [OPCIONAL] Gera o relatório/tabela do BQSR. **BQSR só roda se houver pelo menos um --knownSites** junto.
  --out-duplicate-metrics /outputdir/HJVHNDSX7-1-IDUDI0031.dup_metrics.txt \  # [OPCIONAL] Salva métricas de duplicatas (quantas foram marcadas, etc.).
  --out-qc-metrics-dir /outputdir/qc_metrics \  # [OPCIONAL] Pasta para relatórios de qualidade (QC). Se não existir, costuma ser criada.
  --tmp-dir /workdir/TMP_parabricks \  # [OPCIONAL] Pasta temporária dentro do contêiner (no host). Garanta espaço livre suficiente.
  --num-cpu-threads-per-stage 32 \  # [OPCIONAL] Nº de threads de CPU por GPU. Ajuste conforme seus núcleos (ex.: 16–64). Mais nem sempre é melhor.

  --read-group-sm KOO311_TUMOR \  # [OPCIONAL] Campo SM (Sample) do Read Group. **Importante**: use exatamente o mesmo nome que usará depois nos callers (ex.: --tumor-sample).
  --read-group-lb lib1 \  # [OPCIONAL] Campo LB (Library). Se não souber, "lib1" está ok. Mantenha o mesmo LB para as lanes/pares desta amostra.
  --read-group-pl ILLUMINA \  # [OPCIONAL] Campo PL (Platform). Exemplos válidos: ILLUMINA, IONTORRENT, ONT. Para exoma Illumina, mantenha "ILLUMINA".
  --read-group-id-prefix HJVHNDSX7-1-IDUDI0031 \  # [OPCIONAL] Gera automaticamente ID e PU para cada par de FASTQ usando este prefixo. Evita ter que escrever "@RG ...". Mantém SM/LB/PL iguais.
  --bwa-options "-K 10000000"  # [OPCIONAL] Passa opções direto ao BWA-MEM. "-K 10000000" ajuda a compatibilizar o resultado com pipelines CPU (diferenças mínimas).
