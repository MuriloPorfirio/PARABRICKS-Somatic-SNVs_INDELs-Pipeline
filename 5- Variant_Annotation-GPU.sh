# This command assumes all the inputs are in <INPUT_DIR> and all the outputs go to <OUTPUT_DIR>.
$ docker run --rm --gpus all --volume <INPUT_DIR>:/workdir --volume <OUTPUT_DIR>:/outputdir
    -w /workdir \
    nvcr.io/nvidia/clara/clara-parabricks:<VERSION-TAG> \
    pbrun dbsnp \
    --in-vcf /workdir/${INPUT_VCF} \
    --out-vcf /outputdir/${OUTPUT_VCF} \
    --in-dbsnp-file /workdir/${DBSNP_DATABASE}
