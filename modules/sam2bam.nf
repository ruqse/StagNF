// modules/sam2bam.nf
process SAM2BAM {
    tag "${sample_id}"
    publishDir "${params.output_dir}/logs/host_removal", mode: 'copy', pattern: '*.stderr'
    publishDir "${params.output_dir}/host_removal", mode: 'copy', pattern: '*.bam'

    input:
    tuple val(sample_id), path(bowtie2_output), val(single_end)

    output:
    tuple val(sample_id), path("*.bam"), val(single_end), emit: sam2bam_output
    path("*.stderr"), emit: sam2bam_logs

    script:
    """
    samtools view -b --threads $task.cpus ${bowtie2_output} -o ${sample_id}.bam 2> ${sample_id}.sam2bam.stderr
    """
}
