// modules/combine_metaphlan_tables.nf
process COMBINE_METAPHLAN_TABLES {
    publishDir "${params.output_dir}/metaphlan", mode: 'copy', pattern: 'all_samples.metaphlan.txt'
    publishDir "${params.output_dir}/logs/metaphlan", mode: 'copy', pattern: 'combine_metaphlan_tables.log'

    input:
    path metaphlan_output_all

    output:
    path("all_samples.metaphlan.txt"), emit: combine_metaphlan_tables_output
    path("*.log"), emit: combine_metaphlan_tables_logs

    script:
    """
    merge_metaphlan_tables.py ${metaphlan_output_all} > all_samples.metaphlan.txt 2> combine_metaphlan_tables.log
    sed --in-place 's/\\.metaphlan//g' all_samples.metaphlan.txt
    """
}
