gatk BaseRecalibrator \
  -I sample.bam \
  -R GRCh38.fasta \
  --known-sites Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
  --known-sites Homo_sapiens_assembly38.known_indels.vcf.gz \
  --known-sites 1000G_phase1.snps.high_confidence.hg38.vcf.gz \
  -O sample.recal.table
