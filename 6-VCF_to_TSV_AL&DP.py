# Esse script deve ser executado no mesmo diretório onde está o VCF de entrada.
# Ele extrai os campos AF (frequência alélica) e DP (profundidade) da COLUNA FORMAT do VCF
# e salva as informações em um arquivo .tsv para filtragem posterior.

from cyvcf2 import VCF
import csv

# Nome do arquivo de entrada VCF
vcf_path = "IDUDI0031.vcf"

# Nome do arquivo de saída
saida_tsv = "vcf_info_af_dp.tsv"

# Abre o VCF
vcf = VCF(vcf_path)

# Lista com cabeçalho
linhas = [["Chr", "Pos", "Ref", "Alt", "DP", "AF"]]

# Itera sobre cada variante
for variante in vcf:
    chr = variante.CHROM
    pos = variante.POS
    ref = variante.REF
    alt = variante.ALT[0] if variante.ALT else "."

    # Pega os dados da amostra (primeira amostra do VCF)
    amostra = variante.format("AF")  # retorna uma matriz numpy
    dp_amostra = variante.format("DP")

    # Converte para string simples
    af = amostra[0][0] if amostra is not None else "NA"
    dp = dp_amostra[0][0] if dp_amostra is not None else "NA"

    # Adiciona à tabela
    linhas.append([chr, pos, ref, str(alt), dp, af])

# Salva o resultado
with open(saida_tsv, "w", newline="") as f:
    writer = csv.writer(f, delimiter="\t")
    writer.writerows(linhas)

print(f"Arquivo salvo como {saida_tsv}")
