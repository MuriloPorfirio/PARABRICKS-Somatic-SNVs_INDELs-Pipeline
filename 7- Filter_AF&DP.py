# This script should be run in the same folder as the "vcf_info_af_dp.tsv" file.
# It filters variants with AF >= 0.05 and DP >= 10, and saves the result in a new .tsv file.

import pandas as pd

# Read the .tsv file generated from the VCF
df = pd.read_csv("vcf_info_af_dp.tsv", sep="\t")

# Convert AF and DP to numeric values (in case they’re stored as strings)
df["AF"] = pd.to_numeric(df["AF"], errors="coerce")
df["DP"] = pd.to_numeric(df["DP"], errors="coerce")

# Filter: keep only variants with allele frequency >= 5% and depth >= 10
df_filtered = df[(df["AF"] >= 0.05) & (df["DP"] >= 10)]

# Save the filtered data to a new .tsv file
df_filtered.to_csv("vcf_info_filtered.tsv", sep="\t", index=False)

print(f"Total variants after filtering: {len(df_filtered)}")
print("File saved as vcf_info_filtered.tsv")
