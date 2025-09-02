# Parabricks GPU Pipeline (Docker, Linux server)

**GPU‑accelerated** pipeline for NGS processing using **NVIDIA Parabricks**. Runs on a **Linux server** with **Docker** and **NVIDIA GPUs**. The focus is performance (GPU) and reproducibility (pinned Docker images).

---

## What this pipeline does

* Trim paired‑end FASTQs with optional FastQC
* Convert **FASTQ → BAM** using Parabricks, mark duplicates, and produce a **BQSR table**
* Validate / fix **Read Groups (RG)** if needed
* Apply **BQSR** (GPU)
* Call somatic variants (Parabricks Mutect2)
* Annotate variants (VEP and dbSNP on GPU)

---

## Requirements

* **Linux server** (tested on modern Ubuntu/CentOS/RHEL)
* **NVIDIA GPU** (CUDA‑capable) and **NVIDIA driver** installed on host
* **Docker** installed
* **NVIDIA Container Toolkit** (so containers can see the GPU)
* Enough **RAM** and **disk** for your datasets

Quick checks:

```bash
nvidia-smi            # GPU visible?
docker --version      # Docker installed?
```

---

## Docker images (with versions)

| Purpose                                                         | Image                                   | Version   |
| --------------------------------------------------------------- | --------------------------------------- | --------- |
| Trimming + FastQC                                               | `biowardrobe2/trimgalore`               | `v0.4.4`  |
| Parabricks (core tools: fq2bam, applybqsr, mutectcaller, dbsnp) | `nvcr.io/nvidia/clara/clara-parabricks` | `4.5.1-1` |
| BAM utilities (index, header checks)                            | `staphb/samtools`                       | `1.19`    |
| GATK (RG fixes, BaseRecalibrator)                               | `broadinstitute/gatk`                   | `latest`  |
| Variant Effect Predictor                                        | `ensemblorg/ensembl-vep`                | `latest`  |

---

## Folder layout (suggested)

```
/Genomes/                 # reference FASTA, .fai, .dict, known sites (VCFs)
/FASTQ/                   # raw or trimmed FASTQs
/BAM/                     # BAMs and indices
/VCFs/                    # VCF outputs
/logs/                    # logs from each step
```

---

## End‑to‑end flow (with RG‑dependent branch)

```mermaid
flowchart LR
A[1. Trimming_w_fastqc.sh\n(Trim Galore + optional FastQC)] --> B[2. fq2bam_PARABRICKS_n_BQRS-table-creation.sh\n(fq2bam + dup-mark + BQSR table)]
B --> C[3. Indexing-n-ReadGroupsChecking.sh\n(check @RG / SM / ID / PU; index if missing)]
C -->|RG OK| E[4. ApplyBQSR_PARABRICKS.sh\n(apply BQSR on GPU)]
C -->|RG wrong| D[3.1 Indexing-n-AddOrReplaceReadGroups_GATK.sh\n(fix RG with GATK)]
D --> F[3.3 BaseRecalibrator_GATK.sh\n(recreate BQSR table)]
F --> E
E --> G[4.1 indexing\n(index recalibrated BAM)]
G --> H[5. Mutect2_PARABRICKS.sh\n(somatic SNVs/indels)]
H --> I[6. Variants-Annotations-VEPensembl.sh\n(VEP functional annotation)]
H --> J[7. Variant_Annotation-dbSNP_PARABRICKS.sh\n(add rsIDs with dbSNP on GPU)]
```

---

## How to run (script by script)

Edit paths/variables **inside each script** before running (mounts, reference, known sites, output folders, GPU selection like `--gpus device=7` or `--gpus all`).

### 1) Trimming + (optional) FastQC

**Script:** `1-Trimming_w_fastqc.sh`
**Image:** `biowardrobe2/trimgalore:v0.4.4`

* Trims adapters and low‑quality ends (e.g., Q20, min length 20)
* **FastQC optional** (enable/disable in script)
* Outputs: trimmed FASTQs, QC reports, logs

### 2) FASTQ → BAM + duplicates + BQSR table (GPU)

**Script:** `2-fq2bam_PARABRICKS_n_BQRS-table-creation.sh`
**Image:** `nvcr.io/nvidia/clara/clara-parabricks:4.5.1-1`

* Converts paired FASTQs to BAM, marks duplicates
* Creates **BQSR table** and duplicate metrics
* GPU sort/write enabled (fast)

### 3) Index + Read Group checking

**Script:** `3-Indexing-n-ReadGroupsChecking.sh`
**Image:** `staphb/samtools:1.19`

* Shows `@RG` blocks and key tags (`SM`, `ID`, `PU`, `PL`, `LB`)
* Checks sort order (`@HD SO`)
* Indexes BAM if `.bai` missing

### 3.1) Fix Read Groups (if needed)

**Script:** `3.1-Indexing-n-AddOrReplaceReadGroups_GATK.sh`
**Image:** `broadinstitute/gatk:latest`

* Adds or replaces RG fields (`RGID`, `RGLB`, `RGPL`, `RGPU`, `RGSM`)
* Writes `*_fixed.bam` and creates `.bai`

### 3.3) Recreate BQSR table (if RG was fixed)

**Script:** `3.3-BaseRecalibrator_GATK.sh`
**Image:** `broadinstitute/gatk:latest`

* Runs **GATK BaseRecalibrator**
* Uses known sites (Mills indels, 1000G, etc.)
* Outputs a new `.recal.table`

### 4) Apply BQSR (GPU)

**Script:** `4-ApplyBQSR_PARABRICKS.sh`
**Image:** `nvcr.io/nvidia/clara/clara-parabricks:4.5.1-1`

* Applies BQSR to BAM using Parabricks (fast)

### 4.1) Index recalibrated BAM

**Script:** `4.1-indexing`
**Image:** `staphb/samtools:1.19`

* Indexes `*.recal.bam` (or `*.bqsr.bam`) → creates `.bai`

### 5) Somatic variant calling (GPU)

**Script:** `5-Mutect2_PARABRICKS.sh`
**Image:** `nvcr.io/nvidia/clara/clara-parabricks:4.5.1-1`

* **Mutect2 (Parabricks MutectCaller)** — tumor‑only or tumor/normal
* Requires correct `SM` tags in BAM headers (match `--tumor-name` / `--normal-name`)
* Outputs: somatic VCF + log

### 6) Functional annotation (VEP)

**Script:** `6-Variants-Annotations-VEPensembl.sh`
**Image:** `ensemblorg/ensembl-vep:latest`

* Adds gene/transcript consequences
