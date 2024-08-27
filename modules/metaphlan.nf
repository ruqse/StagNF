// modules/metaphlan.nf
process METAPHLAN {
    tag "${sample_id}"
    publishDir "${params.output_dir}/logs/metaphlan", mode: 'copy', pattern: '*.{stdout.log,stderr.log,debug.log}'
    publishDir "${params.output_dir}/metaphlan", mode: 'copy', pattern: '*.{sam.bz2,bowtie2.bz2,metaphlan.txt}'

    input:
    tuple val(sample_id), path(extract_unmapped_fastq_output), val(single_end)

    output:
    tuple val(sample_id), path("*.{sam.bz2,bowtie2.bz2}")
    tuple val(sample_id), path("*.metaphlan.txt"), emit: metaphlan_output
    path("*.metaphlan.txt"), emit: metaphlan_output_txt
    path("*.{stdout.log,stderr.log,debug.log}"), emit: metaphlan_logs

    script:
    def input_files = single_end ? extract_unmapped_fastq_output : extract_unmapped_fastq_output.join(',')
    """
    metaphlan \
        --input_type fastq \
        --nproc $task.cpus \
        --sample_id ${sample_id} \
        --samout ${sample_id}.sam.bz2 \
        --bowtie2out ${sample_id}.bowtie2.bz2 \
        -x ${params.metaphlan_index} \
        --bowtie2db ${params.metaphlan_db} \
        ${input_files} \
        -o ${sample_id}.metaphlan.txt \
        > ${sample_id}.metaphlan.stdout.log \
        2> ${sample_id}.metaphlan.stderr.log
    """
}