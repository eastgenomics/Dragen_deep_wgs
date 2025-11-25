nextflow.enable.dsl = 2

workflow {

    normal_fastq_list = Channel.fromPath(params.normal_fastq_list)
    normal_RGSM = Channel.value(params.RGSM)
    ch_ref = Channel.fromPath(params.ref)
    tumor_fastq_list = Channel.fromPath(params.tumor_fastq_list)
    tumor_RGSM = Channel.value(params.RGSM)
    noise_file = Channel.fromPath(params.noise_file)
    intermediate_dir = Channel.value(params.intermediate_dir)
    prefix = Channel.value(params.prefix)
    output_dir = Channel.value(params.output_dir)
    lic = Channel.value(params.lic)

    run_dragen(
        normal_fastq_list,
        normal_RGSM,
        tumor_fastq_list,
        tumor_RGSM,
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
    path normal_fastq_list
    val normal_RGSM
    path tumor_fastq_list
    val tumor_RGSM
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
        --tumor-fastq-list ${tumor_fastq_list} \\
        --tumor-fastq-list-sample-id ${tumor_RGSM} \\
        --fastq-list ${normal_fastq_list}\\
        --fastq-list-sample-id ${normal_RGSM} \\
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
