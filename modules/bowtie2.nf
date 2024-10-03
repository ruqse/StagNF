// modules/bowtie2.nf
process BOWTIE2 {
    tag "${sample_id}"
    publishDir "${params.output_dir}/logs/bowtie2", mode: 'copy', pattern: '*.log'
    publishDir "${params.output_dir}/host_removal", mode: 'copy', pattern: '*.{sam}'

    input:
    tuple val(sample_id), path(fastp_output), val(single_end)


    output:
    tuple val(sample_id), path("*.sam"), val(single_end), emit: bowtie2_output
    path "*.log", emit: bowtie2_logs

    script:
    def input = single_end ? "-U ${fastp_output}" : "-1 ${fastp_output[0]} -2 ${fastp_output[1]}"
    """
    bowtie2 -x /sw/data/reference/Homo_sapiens/hg19/program_files/bowtie2/concat \
            ${input} \
            -S ${sample_id}.sam \
            --threads ${task.cpus} \
            > ${sample_id}.bowtie2.log 2>&1
    """
}