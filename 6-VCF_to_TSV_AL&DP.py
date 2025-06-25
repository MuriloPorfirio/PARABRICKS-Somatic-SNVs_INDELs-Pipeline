# Processe no mesmo diretório do input.

from cyvcf2 import VCF  # biblioteca moderna pra ler VCFs
import csv  # pra salvar em .tsv

# Caminho do VCF (ajuste se estiver em outro lugar)
vcf_path = "IDUDI0031.vcf"

# Nome do arquivo de saída
saida_tsv = "vcf_info_af_dp.tsv"

# Abre o VCF com cyvcf2
vcf = VCF(vcf_path)

# Lista pra guardar os dados
linhas = [["Chr", "Pos", "Ref", "Alt", "DP", "AF"]]  # cabeçalho

# Vai linha por linha no VCF
for variante in vcf:
    chr = variante.CHROM
    pos = variante.POS
    ref = variante.REF
    alt = variante.ALT[0] if variante.ALT else "."

    # pega DP (profundidade) e AF (frequência alélica)
    dp = variante.INFO.get("DP", "NA")
    af = variante.INFO.get("AF", "NA")
    if isinstance(af, list):
        af = af[0]  # se vier em lista, pega só o primeiro valor

    # adiciona a linha
    linhas.append([chr, pos, ref, str(alt), dp, af])

# Salva em .tsv (tab separado)
with open(saida_tsv, "w", newline="") as f:
    writer = csv.writer(f, delimiter="\t")
    writer.writerows(linhas)

print(f"Arquivo salvo como {saida_tsv}")
