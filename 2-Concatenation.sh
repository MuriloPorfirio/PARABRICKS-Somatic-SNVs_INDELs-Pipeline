#!/bin/bash

# Script para concatenar arquivos FASTQ emparelhados sem interação

START_TIME=$(date +%s)  # Marca o tempo inicial

# ===== CONFIGURAÇÃO - EDITE OS VALORES ABAIXO =====

PATIENTS=2  # Número de pacientes

PAIRED="yes"  # Só suportado modo paired-end

FILE_PATH="/caminho/para/arquivos"  # Caminho para os arquivos FASTQ

# Informações por paciente: nome da amostra, arquivos R1 e R2 para cada lane
declare -A SAMPLES

# Formato: SAMPLES["nome"]="R1_1 R1_2:R2_1 R2_2"
SAMPLES["HG008"]="HG008_L1_R1.fastq.gz HG008_L2_R1.fastq.gz:HG008_L1_R2.fastq.gz HG008_L2_R2.fastq.gz"
SAMPLES["HG009"]="HG009_L1_R1.fastq.gz HG009_L2_R1.fastq.gz:HG009_L1_R2.fastq.gz HG009_L2_R2.fastq.gz"

# ===== FIM DA CONFIGURAÇÃO =====

# Cria diretório de saída com timestamp
TIMESTAMP=$(date +"%d-%m-%Y_%Hh%Mm")
OUTPUT_DIR="$FILE_PATH/2-concatenated_fastq_$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"  # Cria diretório
LOG_FILE="$OUTPUT_DIR/concat_log.txt"  # Define log

echo "Output directory: $OUTPUT_DIR" | tee "$LOG_FILE"

# Loop sobre os pacientes
for SAMPLE_NAME in "${!SAMPLES[@]}"; do
  echo ""
  echo "=== Concatenando: $SAMPLE_NAME ===" | tee -a "$LOG_FILE"

  # Separa R1 e R2 usando o separador ":"
  IFS=":" read -r R1_STRING R2_STRING <<< "${SAMPLES[$SAMPLE_NAME]}"

  # Transforma string em array
  read -ra R1_FILES <<< "$R1_STRING"
  read -ra R2_FILES <<< "$R2_STRING"

  # Verifica se número de arquivos R1 e R2 coincidem
  if [[ "${#R1_FILES[@]}" -ne "${#R2_FILES[@]}" ]]; then
    echo "Erro: número de arquivos R1 e R2 não coincidem para $SAMPLE_NAME." | tee -a "$LOG_FILE"
    continue
  fi

  # Define arquivos de saída
  R1_OUT="$OUTPUT_DIR/${SAMPLE_NAME}_R1_combined.fastq.gz"
  R2_OUT="$OUTPUT_DIR/${SAMPLE_NAME}_R2_combined.fastq.gz"

  # Concatena R1
  for r1 in "${R1_FILES[@]}"; do
    if [[ ! -f "$FILE_PATH/$r1" ]]; then
      echo "Arquivo ausente: $r1. Pulando $SAMPLE_NAME." | tee -a "$LOG_FILE"
      continue 2
    fi
    cat "$FILE_PATH/$r1" >> "$R1_OUT"  # Concatena no arquivo final
  done

  # Concatena R2
  for r2 in "${R2_FILES[@]}"; do
    if [[ ! -f "$FILE_PATH/$r2" ]]; then
      echo "Arquivo ausente: $r2. Pulando $SAMPLE_NAME." | tee -a "$LOG_FILE"
      continue 2
    fi
    cat "$FILE_PATH/$r2" >> "$R2_OUT"  # Concatena no arquivo final
  done

  echo "Finalizado: $SAMPLE_NAME" | tee -a "$LOG_FILE"
done

# Calcula tempo total
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

# Mostra resumo final
echo ""
echo "Todos os pacientes válidos foram processados."
echo "Arquivos gerados em: $OUTPUT_DIR"
echo "Log salvo em: $LOG_FILE"
echo "Tempo total: $TOTAL_TIME segundos" | tee -a "$LOG_FILE"
