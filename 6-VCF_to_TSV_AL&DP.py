# This script should be run in the same directory as the input VCF file.
# It extracts the AF (allele frequency) and DP (depth) fields from the FORMAT column of the VCF
# and saves this information into a .tsv file for later filtering.

from cyvcf2 import VCF
import csv

# Input VCF file name
vcf_path = "IDUDI0031.vcf"

# Output TSV file name
output_tsv = "vcf_info_af_dp.tsv"

# Open the VCF
vcf = VCF(vcf_path)

# Initialize list with header
rows = [["Chr", "Pos", "Ref", "Alt", "DP", "AF"]]

# Iterate through each variant
for variant in vcf:
    chr = variant.CHROM
    pos = variant.POS
    ref = variant.REF
    alt = variant.ALT[0] if variant.ALT else "."

    # Extract AF and DP from the FORMAT field (first sample only)
    af_field = variant.format("AF")  # returns a numpy array
    dp_field = variant.format("DP")

    # Convert to simple values
    af = af_field[0][0] if af_field is not None else "NA"
    dp = dp_field[0][0] if dp_field is not None else "NA"

    # Add to table
    rows.append([chr, pos, ref, str(alt), dp, af])

# Save as .tsv (tab-separated)
with open(output_tsv, "w", newline="") as f:
    writer = csv.writer(f, delimiter="\t")
    writer.writerows(rows)

print(f"File saved as {output_tsv}")
