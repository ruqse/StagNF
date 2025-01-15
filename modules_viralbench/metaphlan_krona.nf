// modules/metaphlan_krona.nf
process METAPHLAN_KRONA {
    tag "${sample_id}"
    publishDir "${params.output_dir}/logs/metaphlan", mode: 'copy', pattern: '*.log'
    publishDir "${params.output_dir}/metaphlan", mode: 'copy', pattern: '*.krona'

    input:
    tuple val(sample_id), path(metaphlan_output)

    output:
    tuple val(sample_id), path("*.krona"), emit: metaphlan_krona_output
    path("*.krona"), emit: metaphlan_krona_output_txt
    path("*.log"), emit: metaphlan_krona_logs

    script:
    """
    set +o pipefail
    sed '/#/d' ${metaphlan_output} \
       | grep -E "s__|unclassified" \
       | cut -f1,3 \
       | awk '{print \$2,"\\t",\$1}' \
       | sed 's/|\\w__/\\t/g' \
       | sed 's/k__//' \
       > ${sample_id}.krona \
       2> ${sample_id}.metaphlan_krona.log
    """
}