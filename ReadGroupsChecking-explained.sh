#!/usr/bin/env bash
# This tells the computer: "use the Bash shell to run this file."

set -euo pipefail
# "Be careful mode":
#  -e : stop the whole script if any command fails (avoids continuing with bad results)
#  -u : stop if we try to use a variable that doesn't exist (catches typos)
#  -o pipefail : if we connect commands with pipes (A | B), fail the script if A fails too

BAM_HOST="${1:-/home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/KOO311-N_S16_L001.bam}"
# BAM_HOST is "the path to your BAM file".
# If you call the script like:  ./check_rg.sh /path/to/file.bam
#   -> BAM_HOST becomes /path/to/file.bam
# If you call with NO argument:
#   -> BAM_HOST becomes the default shown above.

# If the path is not absolute (doesn’t start with /), make it absolute.
if [[ "${BAM_HOST}" != /* ]]; then
  BAM_HOST="$(cd "$(dirname "$BAM_HOST")" && pwd -P)/$(basename "$BAM_HOST")"
fi
# Why? Docker likes absolute paths when we mount folders. This converts "relative" to "absolute".

SAMTOOLS_IMG="staphb/samtools:1.19"
# This is the Docker image we will use. It already has 'samtools' inside it.

HOST_DIR="$(dirname "$BAM_HOST")"
# The folder on your computer where the BAM lives. We will mount this into the container.

BAM_BASE="$(basename "$BAM_HOST")"
# Just the file name of the BAM (no folder). Easier to reference inside the container.

s() { docker run --rm -v "${HOST_DIR}:/data" "$SAMTOOLS_IMG" bash -lc "$*"; }
# This small helper function "s" runs whatever command we pass… INSIDE a samtools container.
#  --rm           : remove the container after it finishes (keeps things clean)
#  -v A:/data     : mount your local folder A into the container as /data
#  "$SAMTOOLS_IMG": which image to run (samtools)
#  bash -lc       : run a bash login shell and execute the following command string
# We’ll call:  s "samtools something /data/${BAM_BASE}"

echo "== @RG in header =="
s "samtools view -H /data/${BAM_BASE} | grep -n '^@RG' || true"
# Show all @RG lines in the BAM header.
# @RG lines DEFINE read groups. They must include fields like ID, SM, LB, PL, PU.

echo "== SM =="
s "samtools view -H /data/${BAM_BASE} | awk -F'\t' '/^@RG/{for(i=1;i<=NF;i++) if(\$i ~ /^SM:/) print substr(\$i,4)}' | sort -u"
# Show all SM (sample) values found in @RG. For one sample, usually there is exactly ONE unique SM.

echo "== ID =="
s "samtools view -H /data/${BAM_BASE} | awk -F'\t' '/^@RG/{for(i=1;i<=NF;i++) if(\$i ~ /^ID:/) print substr(\$i,4)}' | sort -u"
# Show all RG IDs. If you had multiple lanes, you want different IDs (one per lane).

echo "== PU =="
s "samtools view -H /data/${BAM_BASE} | awk -F'\t' '/^@RG/{for(i=1;i<=NF;i++) if(\$i ~ /^PU:/) print substr(\$i,4)}' | sort -u"
# Show all PU (platform unit) values. PU often encodes flowcell.lane.
# With multiple lanes, PU should differ per lane (helps optical-duplicate handling & metrics).

echo "== PL/LB =="
s "samtools view -H /data/${BAM_BASE} | awk -F'\t' '/^@RG/{pl=\"\";lb=\"\";for(i=1;i<=NF;i++){if(\$i ~ /^PL:/) pl=substr(\$i,4); if(\$i ~ /^LB:/) lb=substr(\$i,4);} if(pl!=\"\"||lb!=\"\") print \"PL=\"pl\"\tLB=\"lb}' | sort -u"
# Show PL (platform, e.g., ILLUMINA) and LB (library, e.g., lib1).
# These should be consistent and valid.

echo "== RG tags in reads (sample 10k) =="
s "samtools view /data/${BAM_BASE} | head -10000 | grep -o 'RG:Z:[^[:space:]]\\+' | head -20 || true"
# Now look inside the actual read records, not the header.
# Each read should carry a tag like RG:Z:<ID> that points to one of the @RG IDs in the header.
# We sample only the first 10k reads to keep things fast.

echo "== Count by RG (sample 200k) =="
s "samtools view /data/${BAM_BASE} | head -200000 | grep -o 'RG:Z:[^[:space:]]\\+' | sort | uniq -c | sort -nr | head || true"
# Quick histogram by RG (from first 200k reads). Useful to see if all reads are mapped to the expected RGs.

echo '== Sort order (@HD SO) =='
s "samtools view -H /data/${BAM_BASE} | awk -F'\t' '/^@HD/{for(i=1;i<=NF;i++) if(\$i ~ /^SO:/) print \$i}'"
# Check if the file is sorted by coordinate (common requirement for downstream tools).
# You’ll likely see SO:coordinate.

if [ ! -f "${BAM_HOST}.bai" ]; then
  echo "== Indexing (no .bai was present) =="
  s "samtools index /data/${BAM_BASE}"
else
  echo "== Index already exists (.bai found) =="
fi
# Many tools require an index (.bai). We create it if missing.

# If something is wrong…
# If the checker shows any of the following:
#   - Missing @RG lines in the header, or
#   - SM is wrong/generic (e.g., "sample"), or
#   - PL is invalid (e.g., "bar"), or
#   - Reads don’t carry RG:Z:<ID> tags,
# then use GATK/Picard AddOrReplaceReadGroups to fix the BAM by assigning proper RG fields.
# Set fields like:
#   SM=KOO311_NORMAL (or KOO311_TUMOR),
#   PL=ILLUMINA,
#   ID/PU appropriate and unique per lane.
# After fixing, re-run the checker to confirm everything is clean before moving on.
#
# Example (uncomment and edit paths/fields):
# docker run --rm -v /path/on/host:/data broadinstitute/gatk:latest \
#   gatk AddOrReplaceReadGroups \
#   -I /data/input.bam \
#   -O /data/output_fixed.bam \
#   -RGID N_L001 -RGLB lib1 -RGPL ILLUMINA -RGPU HKKKVBBXX.1 -RGSM KOO311_NORMAL \
#   --CREATE_INDEX true
