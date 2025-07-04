#!/bin/bash

# Trim Galore em modo não-interativo usando Docker

# ===== CONFIGURAÇÃO INICIAL - EDITE AQUI =====

N=3                            # Número de pacientes
LANES=2                        # Número de lanes por paciente
INPUT_DIR="/caminho/para/entrada"  # Caminho para os arquivos .fastq/.gz
OUTPUT_PARENT="/caminho/para/saida" # Caminho onde a pasta de saída será criada
FILES=("sample1_R1.fastq.gz" "sample1_R2.fastq.gz" "sample2_R1.fastq.gz" "sample2_R2.fastq.gz")  # Lista de arquivos
RAM=8                          # RAM em GB a ser usada
CUSTOM_UID="1000"             # UID do usuário (ou deixe vazio para padrão)
QUALITY=20                    # Qualidade mínima para corte
MIN_LENGTH=20                 # Tamanho mínimo da leitura após corte
ADAPTER_TYPE="auto"          # Tipo de adaptador (illumina/nextera/auto)
RUN_FASTQC="yes"             # Executar FastQC (yes/no)

# ===== FIM DA CONFIGURAÇÃO =====

# Calcula o número total de arquivos esperados
TOTAL_FILES=$((N * LANES * 2))

# Cria diretório de saída com timestamp
TIMESTAMP=$(date +"%d-%m-%Y_%Hh%Mm")
OUTPUT_DIR="$OUTPUT_PARENT/1-PARABRICKS_trimmed_files_$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"  # Cria diretório de saída

# Configura UID no Docker
if [[ "$CUSTOM_UID" =~ ^[0-9]+$ ]]; then
  USE_USER="--user $CUSTOM_UID"  # Usa UID customizado
else
  USE_USER=""  # Usa padrão
fi

# Define opção de adaptador
if [[ "$ADAPTER_TYPE" == "illumina" ]]; then
  ADAPTER_OPTION="--illumina"
elif [[ "$ADAPTER_TYPE" == "nextera" ]]; then
  ADAPTER_OPTION="--nextera"
else
  ADAPTER_OPTION=""
fi

# Define opção do FastQC
if [[ "$RUN_FASTQC" == "yes" ]]; then
  FASTQC_OPTION="--fastqc"
else
  FASTQC_OPTION="--no_fastqc"
fi

# Inicia processamento
START_TIME=$(date +%s)  # Marca tempo de início
LOG_FILE="$OUTPUT_DIR/trimming_log_$(date +"%Y-%m-%d_%H%M").log"  # Define arquivo de log
echo "Iniciando trimming..." | tee -a "$LOG_FILE"

# Loop sobre os pares de arquivos
i=0
while [[ $i -lt ${#FILES[@]} ]]; do
  R1="${FILES[$i]}"        # Arquivo R1
  R2="${FILES[$((i+1))]}"  # Arquivo R2

  echo "Processando: $R1 e $R2" | tee -a "$LOG_FILE"

  # Executa Trim Galore dentro do Docker
  docker run --rm \
    -v "$INPUT_DIR":/data \
    -v "$OUTPUT_DIR":/output \
    $USE_USER \
    biowardrobe2/trimgalore:v0.4.4 \
    trim_galore --paired \
      --quality "$QUALITY" \
      --length "$MIN_LENGTH" \
      $ADAPTER_OPTION \
      $FASTQC_OPTION \
      "/data/$R1" "/data/$R2" \
      -o "/output" 2>&1 | tee -a "$LOG_FILE"

  # Verifica status da execução
  if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    echo "Erro ao processar $R1 e $R2" | tee -a "$LOG_FILE"
  else
    echo "Concluído: $R1 e $R2" | tee -a "$LOG_FILE"
  fi

  i=$((i + 2))  # Avança para o próximo par
done

# Finaliza com sumário
END_TIME=$(date +%s)  # Marca tempo final
TOTAL_TIME=$((END_TIME - START_TIME))  # Calcula tempo total

# Exibe e salva sumário final
echo "Trimming concluído." | tee -a "$LOG_FILE"
echo "Tempo total: $TOTAL_TIME segundos" | tee -a "$LOG_FILE"
echo "Resultados salvos em: $OUTPUT_DIR"
echo "Log disponível em: $LOG_FILE"
