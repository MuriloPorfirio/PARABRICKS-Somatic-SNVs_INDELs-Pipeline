#!/usr/bin/env bash
set -euo pipefail

BAM_HOST="${1:-/home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/KOO311-N_S16_L001.bam}"
# Make absolute if a relative path was given
if [[ "${BAM_HOST}" != /* ]]; then
  BAM_HOST="$(cd "$(dirname "$BAM_HOST")" && pwd -P)/$(basename "$BAM_HOST")"
fi

SAMTOOLS_IMG="staphb/samtools:1.19"
HOST_DIR="$(dirname "$BAM_HOST")"
BAM_BASE="$(basename "$BAM_HOST")"

s() { docker run --rm -v "${HOST_DIR}:/data" "$SAMTOOLS_IMG" bash -lc "$*"; }

echo "== @RG in header =="
s "samtools view -H /data/${BAM_BASE} | grep -n '^@RG' || true"
echo "== SM =="
s "samtools view -H /data/${BAM_BASE} | awk -F'\t' '/^@RG/{for(i=1;i<=NF;i++) if(\$i ~ /^SM:/) print substr(\$i,4)}' | sort -u"
echo "== ID =="
s "samtools view -H /data/${BAM_BASE} | awk -F'\t' '/^@RG/{for(i=1;i<=NF;i++) if(\$i ~ /^ID:/) print substr(\$i,4)}' | sort -u"
echo "== PU =="
s "samtools view -H /data/${BAM_BASE} | awk -F'\t' '/^@RG/{for(i=1;i<=NF;i++) if(\$i ~ /^PU:/) print substr(\$i,4)}' | sort -u"
echo "== PL/LB =="
s "samtools view -H /data/${BAM_BASE} | awk -F'\t' '/^@RG/{pl=\"\";lb=\"\";for(i=1;i<=NF;i++){if(\$i ~ /^PL:/) pl=substr(\$i,4); if(\$i ~ /^LB:/) lb=substr(\$i,4);} if(pl!=\"\"||lb!=\"\") print \"PL=\"pl\"\tLB=\"lb}' | sort -u"

echo "== RG tags in reads (first 10k) =="
s "samtools view /data/${BAM_BASE} | head -10000 | grep -o 'RG:Z:[^[:space:]]\\+' | head -20 || true"
echo "== Count by RG (first 200k) =="
s "samtools view /data/${BAM_BASE} | head -200000 | grep -o 'RG:Z:[^[:space:]]\\+' | sort | uniq -c | sort -nr | head || true"

echo "== Sort order (@HD SO) =="
s "samtools view -H /data/${BAM_BASE} | awk -F'\t' '/^@HD/{for(i=1;i<=NF;i++) if(\$i ~ /^SO:/) print \$i}'"

if [ ! -f "${BAM_HOST}.bai" ]; then
  echo "== Indexing (no .bai was present) =="
  s "samtools index /data/${BAM_BASE}"
else
  echo "== Index already exists (.bai found) =="
fi
