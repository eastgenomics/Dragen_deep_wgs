nextflow.enable.dsl = 2

workflow {

    ch_normal_fastq1 = Channel.fromPath(params.normal_fastq1)
    ch_normal_fastq2 = Channel.fromPath(params.normal_fastq2)
    ch_normal_RGSM = Channel.value(params.normal_RGSM)
    ch_normal_RGID = Channel.value(params.normal_RGID)
    ch_ref = Channel.fromPath(params.ref)
    ch_tumor_fastq1 = Channel.fromPath(params.tumor_fastq1)
    ch_tumor_fastq2 = Channel.fromPath(params.tumor_fastq2)
    ch_tumor_RGSM = Channel.value(params.tumor_RGSM)
    ch_tumor_RGID = Channel.value(params.tumor_RGID)
    ch_noise_file = Channel.fromPath(params.noise_file)
    ch_intermediate_dir = Channel.value(params.intermediate_dir)
    ch_prefix = Channel.value(params.prefix)
    ch_output_dir = Channel.value(params.output_dir)
    ch_lic = Channel.value(params.lic)

    run_dragen(
        ch_normal_fastq1,
        ch_normal_fastq2,
        ch_normal_RGSM,
        ch_normal_RGID,
        ch_tumor_fastq1,
        ch_tumor_fastq2,
        ch_tumor_RGSM,
        ch_tumor_RGID,
        ch_ref,
        ch_noise_file,
        ch_intermediate_dir,
        ch_prefix,
        ch_output_dir,
        ch_lic
    )
}

process run_dragen {

    label 'dragen'

    secret 'DRAGEN_USERNAME'
    secret 'DRAGEN_PASSWORD'

    publishDir "${params.output_dir}", mode: 'copy'
    
    input:
    path normal_fastq1
    path normal_fastq2
    val normal_RGSM
    val normal_RGID
    path tumor_fastq1
    path tumor_fastq2
    val tumor_RGSM
    val tumor_RGID
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
        --tumor-fastq1 ${tumor_fastq1} \\
        --tumor-fastq2 ${tumor_fastq2} \\
        --RGSM-tumor ${tumor_RGSM} \\
        --RGID-tumor ${tumor_RGID} \\
        --fastq-file1 ${normal_fastq1}\\
        --fastq-file2 ${normal_fastq2} \\
        --RGSM ${normal_RGSM} \\
        --RGID ${normal_RGID} \\
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
