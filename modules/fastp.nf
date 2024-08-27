// modules/fastp.nf
process FASTP {
    tag "${sample_id}"
    publishDir "${params.output_dir}/logs/fastp", mode: 'copy', pattern: '*.{json,stdout.log,stderr.log}'
    publishDir "${params.output_dir}/fastp", mode: 'copy', pattern: '*.{trimmed.fq.gz,html}'

    input:
    tuple val(sample_id), path(reads), val(single_end)

    output:
    tuple val(sample_id), path("*.trimmed.fq.gz"), val(single_end), emit: fastp_output
    path("*.json"), emit: fastp_json_logs

    script:
    def input = single_end ? "--in1 ${reads[0]}" : "--in1 ${reads[0]} --in2 ${reads[1]}"
    def output = single_end ? "--out1 ${sample_id}.trimmed.fq.gz" : "--out1 ${sample_id}_1.trimmed.fq.gz --out2 ${sample_id}_2.trimmed.fq.gz"
    """
    fastp $input $output \
          --json ${sample_id}.fastp.json \
          --html ${sample_id}.fastp.html \
          --thread $task.cpus \
          > ${sample_id}.fastp.log 2>&1
    """
}
