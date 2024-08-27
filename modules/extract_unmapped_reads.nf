// modules/extract_unmapped_reads.nf
process EXTRACT_UNMAPPED_READS {
    tag "${sample_id}"
    publishDir "${params.output_dir}/logs/host_removal", mode: 'copy', pattern: '*.stderr'
    publishDir "${params.output_dir}/host_removal", mode: 'copy', pattern: '*.{bam,sorted.bam}'

    input:
    tuple val(sample_id), path(sam2bam_output), val(single_end)

    output:
    tuple val(sample_id), path("*_unmapped.sorted.bam"), val(single_end), emit: extract_unmapped_sorted_output
    path("*.stderr"), emit: extract_unmapped_reads_logs

    script:
    """
    samtools view -b -f 13 -F 256 --threads $task.cpus ${sam2bam_output} -o ${sample_id}_unmapped.bam 2> ${sample_id}.unmapped.stderr
    samtools sort -n -m 5G --threads $task.cpus ${sample_id}_unmapped.bam -o ${sample_id}_unmapped.sorted.bam 2> ${sample_id}.sort.stderr
    """
}


