// modules/preprocessing_summary.nf
process PREPROCESSING_SUMMARY {
    publishDir "${params.output_dir}", mode: 'copy', pattern: 'preprocessing_read_counts.txt'
    publishDir "${params.output_dir}/logs", mode: 'copy', pattern: 'preprocessing_summary.log'

    input:
    path (fastp_json_logs_all)
    path (extract_unmapped_samtools_fastq_logs_all)
    val(output_dir)

    output:
    path "preprocessing_read_counts.txt"
    path "preprocessing_summary.log", emit: preprocessing_summary_logs

    script:
    """
    python3 $projectDir/scripts/preprocessing_summary.py \
             --fastp ${fastp_json_logs_all} \
             --bowtie2 ${extract_unmapped_samtools_fastq_logs_all} \
             --output-table preprocessing_read_counts.txt \
             > preprocessing_summary.log
    """
}
