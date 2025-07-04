#!/bin/bash

# Script para concatenar arquivos FASTQ emparelhados automaticamente, sem interação

START_TIME=$(date +%s)  # Marca o tempo inicial

# ===== CONFIGURAÇÃO - EDITE AQUI =====

FILE_PATH="/caminho/para/arquivos"  # Caminho onde estão os arquivos FASTQ

# Mapeia nome da amostra para arquivos R1 e R2 (separados por :)
declare -A SAMPLES

# Formato: SAMPLES["nome"]="R1_1 R1_2:R2_1 R2_2"
SAMPLES["HG008"]="HG008_L1_R1.fastq.gz HG008_L2_R1.fastq.gz:HG008_L1_R2.fastq.gz HG008_L2_R2.fastq.gz"
SAMPLES["HG009"]="HG009_L1_R1.fastq.gz HG009_L2_R1.fastq.gz:HG009_L1_R2.fastq.gz HG009_L2_R2.fastq.gz"

# ===== FIM DA CONFIGURAÇÃO =====

# Cria diretório de saída com timestamp
TIMESTAMP=$(date +"%d-%m-%Y_%Hh%Mm")
OUTPUT_DIR="$FILE_PATH/2-concatenated_fastq_$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"  # Cria pasta de saída
LOG_FILE="$OUTPUT_DIR/concat_log.txt"  # Define caminho do log

echo "Output directory: $OUTPUT_DIR" | tee "$LOG_FILE"
echo "Total de amostras a processar: ${#SAMPLES[@]}" | tee -a "$LOG_FILE"

# Loop sobre cada amostra definida
for SAMPLE_NAME in "${!SAMPLES[@]}"; do
  echo ""
  echo "=== Concatenando: $SAMPLE_NAME ===" | tee -a "$LOG_FILE"

  # Separa R1 e R2 com base no separador ":"
  IFS=":" read -r R1_STRING R2_STRING <<< "${SAMPLES[$SAMPLE_NAME]}"

  # Transforma strings em arrays
  read -ra R1_FILES <<< "$R1_STRING"
  read -ra R2_FILES <<< "$R2_STRING"

  # Verifica se número de arquivos R1 e R2 é o mesmo
  if [[ "${#R1_FILES[@]}" -ne "${#R2_FILES[@]}" ]]; then
    echo "Erro: número de arquivos R1 e R2 não bate para $SAMPLE_NAME." | tee -a "$LOG_FILE"
    continue
  fi

  # Define arquivos de saída
  R1_OUT="$OUTPUT_DIR/${SAMPLE_NAME}_R1_combined.fastq.gz"
  R2_OUT="$OUTPUT_DIR/${SAMPLE_NAME}_R2_combined.fastq.gz"

  # Concatena arquivos R1
  for r1 in "${R1_FILES[@]}"; do
    if [[ ! -f "$FILE_PATH/$r1" ]]; then
      echo "Arquivo ausente: $r1. Pulando $SAMPLE_NAME." | tee -a "$LOG_FILE"
      continue 2
    fi
    cat "$FILE_PATH/$r1" >> "$R1_OUT"  # Adiciona ao arquivo final
  done

  # Concatena arquivos R2
  for r2 in "${R2_FILES[@]}"; do
    if [[ ! -f "$FILE_PATH/$r2" ]]; then
      echo "Arquivo ausente: $r2. Pulando $SAMPLE_NAME." | tee -a "$LOG_FILE"
      continue 2
    fi
    cat "$FILE_PATH/$r2" >> "$R2_OUT"  # Adiciona ao arquivo final
  done

  echo "Finalizado: $SAMPLE_NAME" | tee -a "$LOG_FILE"
done

# Calcula tempo total de execução
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

# Exibe sumário final
echo ""
echo "Concatenação finalizada com sucesso." | tee -a "$LOG_FILE"
echo "Arquivos combinados salvos em: $OUTPUT_DIR" | tee -a "$LOG_FILE"
echo "Log salvo em: $LOG_FILE"
echo "Tempo total: $TOTAL_TIME segundos" | tee -a "$LOG_FILE"
