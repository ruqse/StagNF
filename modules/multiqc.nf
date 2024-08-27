// modules/multiqc.nf
process MULTIQC {
    publishDir "${params.output_dir}/multiqc", mode: 'copy'
    publishDir "${params.output_dir}/logs/multiqc", mode: 'copy', pattern: '*.log'

    input:
    path(multiqc_input)

    output:
    path("*")
    //path("multiqc.log")

    script:
    """
    multiqc ${multiqc_input} \
       --filename multiqc_report.html \
       --force \
       --export \
       2> multiqc.log
    """
}