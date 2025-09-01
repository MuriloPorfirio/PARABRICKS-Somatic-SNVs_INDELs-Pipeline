#!/usr/bin/env bash  # Diz ao sistema para executar este arquivo com o shell Bash.
set -euo pipefail    # Modo “seguro”: (-e) para se algo falhar o script para; (-u) proíbe variável não definida; (pipefail) falha se qualquer comando no pipe falhar.

# Ajuste estes dois caminhos UMA VEZ e evite repetir:
IN_DIR="/home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025"  # Pasta onde estão seus BAMs originais (de entrada). Use caminho ABSOLUTO.
OUT_DIR="/home/murilo.aguiar/raid-murilo/Processos/1-Alinhamento-ExomaCompleto-LeticiaFerro-Parabricks_06-08-2025/2-BAMs-Cabecalho-Corrigido"  # Pasta onde serão salvos os BAMs corrigidos (de saída). Precisa ter permissão de escrita.
IMG="broadinstitute/gatk:latest"  # Imagem Docker do GATK/Picard. Já existe no seu host; ela contém o comando "gatk AddOrReplaceReadGroups".

# ============================
# AMOSTRA: TUMOR (exemplo)
# ============================
docker run --rm \                                                                 # Cria um contêiner temporário e apaga ao final (não acumula lixo).
  -v "${IN_DIR}":/input \                                                         # Monta sua pasta de entrada no contêiner como /input (para o GATK enxergar seus BAMs).
  -v "${OUT_DIR}":/output \                                                       # Monta sua pasta de saída no contêiner como /output (para gravar os BAMs corrigidos).
  "${IMG}" \                                                                      # Usa a imagem do GATK definida acima.
  gatk AddOrReplaceReadGroups \                                                   # Ferramenta que cria/troca os Read Groups no BAM (cabeçalho e tag RG nos reads).
    -I /input/KOO311_TUMOR.bam \                                                  # (I = Input) BAM de ENTRADA. Troque pelo nome do seu arquivo de tumor.
    -O /output/KOO311_TUMOR_fixed.bam \                                           # (O = Output) BAM de SAÍDA corrigido. Vai nascer em OUT_DIR com este nome.
    -RGID TUMOR \                                                                 # ID do Read Group (um rótulo). Aqui usamos “TUMOR”. Pode ser outro nome, mas mantenha sem espaços.
    -RGLB lib1 \                                                                  # LB (Library). Nome da biblioteca. Se não souber, “lib1” é aceitável e consistente.
    -RGPL ILLUMINA \                                                              # PL (Platform). Precisa ser um valor reconhecido (ex.: ILLUMINA, IONTORRENT, ONT). Para exoma Illumina, use ILLUMINA.
    -RGPU UNIT1 \                                                                 # PU (Platform Unit). Uma “unidade”/identificador do sequenciamento (ex.: flowcell.lane). Aqui, sem lanes, usamos “UNIT1” só para ter algo válido.
    -RGSM KOO311_TUMOR \                                                          # SM (Sample). Nome EXATO da amostra de tumor; o mesmo que você usará nos callers (ex.: --tumor-sample KOO311_TUMOR).
    --CREATE_INDEX true                                                           # Pede para criar automaticamente o índice .bai do BAM _fixed (necessário para várias ferramentas).

# ============================
# AMOSTRA: NORMAL (exemplo)
# ============================
docker run --rm \                                                                 # Mesmo processo para a amostra NORMAL.
  -v "${IN_DIR}":/input \                                                         # Monta a pasta de entrada como /input.
  -v "${OUT_DIR}":/output \                                                       # Monta a pasta de saída como /output.
  "${IMG}" \                                                                      # Usa a mesma imagem GATK.
  gatk AddOrReplaceReadGroups \                                                   # Mesma ferramenta para corrigir os Read Groups.
    -I /input/KOO311_NORMAL.bam \                                                 # BAM de ENTRADA do NORMAL. Troque pelo seu arquivo real.
    -O /output/KOO311_NORMAL_fixed.bam \                                          # BAM de SAÍDA do NORMAL, corrigido.
    -RGID NORMAL \                                                                # ID do Read Group para o NORMAL (ex.: “NORMAL”). Pode renomear, mas sem espaços e único por arquivo.
    -RGLB lib1 \                                                                  # Biblioteca (LB). Mantemos “lib1” por consistência.
    -RGPL ILLUMINA \                                                              # Plataforma (PL). Valor reconhecido; aqui “ILLUMINA”.
    -RGPU UNIT1 \                                                                 # Unidade da plataforma (PU). Um rótulo simples “UNIT1” é suficiente se você não precisa detalhar lanes.
    -RGSM KOO311_NORMAL \                                                         # Sample (SM). Nome EXATO da amostra NORMAL; o mesmo que os callers esperam (ex.: --normal-sample KOO311_NORMAL).
    --CREATE_INDEX true                                                           # Cria o índice .bai do BAM _fixed automaticamente na pasta de saída.
