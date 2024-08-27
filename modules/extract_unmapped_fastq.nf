// modules/extract_unmapped_fastq.nf
process EXTRACT_UNMAPPED_FASTQ {
    tag "${sample_id}"
    publishDir "${params.output_dir}/logs/host_removal", mode: 'copy', pattern: '*.log'
    publishDir "${params.output_dir}/host_removal", mode: 'copy', pattern: '*.fq.gz'

    input:
    tuple val(sample_id), path(extract_unmapped_sorted_output), val(single_end)

    output:
    tuple val(sample_id), path("*.fq.gz"), val(single_end), emit: extract_unmapped_fastq_output
    path("*.log"), emit: extract_unmapped_samtools_fastq_logs

    script:
    def output = single_end ? "-0 ${sample_id}.fq.gz" : "-1 ${sample_id}_1.fq.gz -2 ${sample_id}_2.fq.gz"
    """
    samtools fastq --threads $task.cpus \
        $output \
        -s /dev/null \
        -n ${extract_unmapped_sorted_output} \
        2>> ${sample_id}.extract_unmapped.log
    """
}


