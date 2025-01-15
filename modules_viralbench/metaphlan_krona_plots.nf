// modules/metaphlan_krona_plots.nf
process METAPHLAN_KRONA_PLOTS {
    publishDir "${params.output_dir}/logs/metaphlan", mode: 'copy', pattern: '*.log'
    publishDir "${params.output_dir}/metaphlan", mode: 'copy', pattern: '*_krona.html'

    input:
    path metaphlan_krona_output_all

    output:
    path("*.log"), emit: metaphlan_krona_plots_logs
    path("*_krona.html"), emit: metaphlan_krona_plots_output

    script:
    """
    ktImportText \
        -o all_samples_metaphlan_krona.html \
        ${metaphlan_krona_output_all} \
        > all_sample_metaphlan_krona_plot.log

    ktImportText \
        -o combined_metaphlan_krona.html \
        -c \
        ${metaphlan_krona_output_all} \
        >> combined_metaphlan_krona_plot.log
    """
}
