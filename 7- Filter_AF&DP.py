#Este script deve ser executado na mesma pasta onde está o input.

import pandas as pd

# Lê o .tsv que foi gerado com as informações extraídas do VCF
df = pd.read_csv("vcf_info_af_dp.tsv", sep="\t")

# Converte as colunas AF e DP para numérico (caso estejam como string)
df["AF"] = pd.to_numeric(df["AF"], errors="coerce")
df["DP"] = pd.to_numeric(df["DP"], errors="coerce")

# Aplica o filtro: apenas variantes com AF >= 0.05 e DP >= 10
df_filtrado = df[(df["AF"] >= 0.05) & (df["DP"] >= 10)]

# Salva o resultado filtrado
df_filtrado.to_csv("vcf_info_filtrado.tsv", sep="\t", index=False)

print(f"Total de variantes após o filtro: {len(df_filtrado)}")
print("Arquivo salvo como vcf_info_filtrado.tsv")
