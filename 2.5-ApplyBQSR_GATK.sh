gatk ApplyBQSR \
  -I sample.bam \
  -R GRCh38.fasta \
  --bqsr-recal-file sample.recal.table \
  -O sample.recal.bam
