// modules/split_metaphlan_levels.nf
process SPLIT_METAPHLAN_LEVELS {
    publishDir "${params.output_dir}/metaphlan/levels", mode: 'copy', pattern: '*.tsv'

    input:
    path combine_metaphlan_tables_output

    output:
    path("*{species,genus,family,order}.tsv"), emit: level_tables

    script:
    """
    set +o pipefail
    sed '/#.*/d' ${combine_metaphlan_tables_output} | cut -f 1- | head -n1 | tee species.tsv genus.tsv family.tsv order.tsv > /dev/null

    sed '/#.*/d' ${combine_metaphlan_tables_output} | cut -f 1- | grep s__ | sed 's/^.*s__/s__/g' >> species.tsv
    sed '/#.*/d' ${combine_metaphlan_tables_output} | cut -f 1- | grep g__ | sed 's/^.*s__.*//g' | grep g__ | sed 's/^.*g__/g__/g' >> genus.tsv
    sed '/#.*/d' ${combine_metaphlan_tables_output} | cut -f 1- | grep f__ | sed 's/^.*g__.*//g' | grep f__ | sed 's/^.*f__/f__/g' >> family.tsv
    sed '/#.*/d' ${combine_metaphlan_tables_output} | cut -f 1- | grep o__ | sed 's/^.*f__.*//g' | grep o__ | sed 's/^.*o__/o__/g' >> order.tsv
    """
}
