nextflow.enable.dsl = 2

workflow {

    fastq1 = Channel.fromPath(params.fastq1)
    fastq2 = Channel.fromPath(params.fastq2)
    ch_ref = Channel.fromPath(params.ref)
    RGSM = params.RGSM
    RGID = params.RGID
    fastq1_tumor = Channel.fromPath(params.fastq1_tumor)
    fastq2_tumor = Channel.fromPath(params.fastq2_tumor)
    RGSM_tumor = params.RGSM_tumor
    RGID_tumor = params.RGID_tumor
    noise_file = Channel.fromPath(params.noise_file)
    intermediate_dir = Channel.value(params.intermediate_dir)
    prefix = Channel.value(params.prefix)
    output_dir = Channel.value(params.output_dir)
    lic = Channel.value(params.lic)

    run_dragen(
        fastq1,
        fastq2,
        RGSM,
        RGID,
        fastq1_tumor,
        fastq2_tumor,
        RGSM_tumor,
        RGID_tumor,
        ch_ref,
        noise_file,
        intermediate_dir,
        prefix,
        output_dir,
        lic
    )
}

process run_dragen {

    label 'dragen'

    secret 'DRAGEN_USERNAME'
    secret 'DRAGEN_PASSWORD'

    publishDir "${params.output_dir}", mode: 'copy'
    
    input:
    path fastq1
    path fastq2
    val RGSM
    val RGID
    path fastq1_tumor
    path fastq2_tumor
    val RGSM_tumor
    val RGID_tumor
    path ref_gz
    path noise_file
    val intermediate_dir
    val prefix
    val output_dir
    val lic

    output:
    path("${params.output_dir}")

    script:
    """
    mkdir ref_data
    tar xvfz $ref_gz -C ref_data

    mkdir ${params.output_dir}
    mkdir ${params.intermediate_dir}

    /opt/edico/bin/dragen \\
        -r ref_data \\
        --tumor-fastq1 ${fastq1_tumor} \\
        --tumor-fastq2 ${fastq2_tumor} \\
        --RGSM-tumor ${RGSM_tumor} \\
        --RGID-tumor ${RGID_tumor} \\
        --fastq-file1 ${fastq1} \\
        --fastq-file2 ${fastq2} \\
        --RGSM ${RGSM} \\
        --RGID ${RGID} \\
        --enable-map-align true \\
        --enable-map-align-output true \\
        --enable-sort true \\
        --enable-duplicate-marking true \\
        --enable-variant-caller true \\
        --vc-systematic-noise ${noise_file} \\
        --intermediate-results-dir ${intermediate_dir} \\
        --output-file-prefix ${prefix} \\
        --output-directory ${output_dir} \\
        --lic-server ${lic}
    """
}
