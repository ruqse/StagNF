#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Input parameters
params.reads = "$projectDir/data/testdata_mix/*{1,2}.fastq.gz"
// params.single_end = false
params.reference = "/sw/data/reference/Homo_sapiens/hg19/program_files/bowtie2/concat"
params.metaphlan_db = "/crex/proj/naiss2023-23-521/nobackup/Analyses/Faruk/Vaginal_microbiome/MiniStagNF/mpa_vOct22_CHOCOPhlAnSGB_202212"
params.metaphlan_index = "mpa_vOct22_CHOCOPhlAnSGB_202212"

// Validate input
def input_files = file(params.reads)
if( input_files instanceof List ) {
    if( input_files.size() == 0 ) {
        error "No files found matching pattern: ${params.reads}"
    }
} else if( !input_files.exists() ) {
    error "File or directory not found: ${params.reads}"
}

// Derive output directory name
def input_dir = input_files[0].parent
params.output_dir = "${input_dir.name}_results"

// Create output directory
file(params.output_dir).mkdirs()

// Debug: Print input parameters
log.info """
         Input reads: ${params.reads}
         Reference: ${params.reference}
         Output directory: ${params.output_dir}
         """

// Import modules
include { FASTP } from './modules/fastp'
include { BOWTIE2 } from './modules/bowtie2'
include { SAM2BAM } from './modules/sam2bam'
include { EXTRACT_UNMAPPED_READS } from './modules/extract_unmapped_reads'
include { EXTRACT_UNMAPPED_FASTQ } from './modules/extract_unmapped_fastq'
include { PREPROCESSING_SUMMARY } from './modules/preprocessing_summary'
include { METAPHLAN } from './modules/metaphlan'
include { METAPHLAN_KRONA } from './modules/metaphlan_krona'
include { COMBINE_METAPHLAN_TABLES } from './modules/combine_metaphlan_tables'
include { SPLIT_METAPHLAN_LEVELS } from './modules/split_metaphlan_levels'
include { METAPHLAN_KRONA_PLOTS } from './modules/metaphlan_krona_plots'
include { MULTIQC } from './modules/multiqc'



// Create input channel
Channel
    .fromFilePairs(params.reads, size: -1, checkIfExists: true) { file -> 
        file.name.replaceAll(/\.fastq\.gz$/, '').replaceAll(/_[12]$/, '')
    }
    .map { sample_id, files ->
        def single_end = files.size() == 1
        return tuple(sample_id, files, single_end)
    }
    .unique()
    .set { read_pairs_ch }

read_pairs_ch.view { sample_id, files, single_end -> 
    "Sample: $sample_id, Files: $files, Single-end: $single_end" 
}


// Main workflow
workflow {

    
    fastp_output = FASTP(read_pairs_ch)


    // BOWTIE2 INPUT DEBUG
    fastp_output.fastp_output.view { "FASTP output: $it" }

    bowtie2_output = BOWTIE2(fastp_output.fastp_output)

    // Debug: Print bowtie2_output
    bowtie2_output.bowtie2_output.view { "BOWTIE2 output: $it" }

    sam2bam_output = SAM2BAM(bowtie2_output.bowtie2_output)
    extract_unmapped_sorted_output = EXTRACT_UNMAPPED_READS(sam2bam_output.sam2bam_output)
    extract_unmapped_fastq_output = EXTRACT_UNMAPPED_FASTQ(extract_unmapped_sorted_output.extract_unmapped_sorted_output)
    extract_unmapped_sorted_output.extract_unmapped_sorted_output.view { "EXTRACT_UNMAPPED_READS output: $it" }

    // Debug: Print extract_unmapped_fastq_output
    extract_unmapped_fastq_output.extract_unmapped_fastq_output.view { "EXTRACT_UNMAPPED_FASTQ output: $it" }
    
    
    // Debug: Print extract_unmapped_fastq_output
    extract_unmapped_fastq_output.extract_unmapped_fastq_output.view { "EXTRACT_UNMAPPED_FASTQ output: $it" }
    
    // Collect fastp JSON logs with full paths
    fastp_json_logs_all = fastp_output.fastp_json_logs.collect()

    // Collect samtools fastq logs with full paths
    extract_unmapped_samtools_fastq_logs_all = extract_unmapped_fastq_output.extract_unmapped_samtools_fastq_logs.collect()
    
    preprocessing_summary_output = PREPROCESSING_SUMMARY(fastp_json_logs_all, extract_unmapped_samtools_fastq_logs_all, params.output_dir)

    // debug metaphlan input

    metaphlan_output = METAPHLAN(extract_unmapped_fastq_output.extract_unmapped_fastq_output)
    metaphlan_krona_output = METAPHLAN_KRONA(metaphlan_output.metaphlan_output)

    metaphlan_output_all = metaphlan_output.metaphlan_output_txt.collect()
    combine_metaphlan_tables_output = COMBINE_METAPHLAN_TABLES(metaphlan_output_all)

    split_metaphlan_levels_output = SPLIT_METAPHLAN_LEVELS(combine_metaphlan_tables_output.combine_metaphlan_tables_output)

    metaphlan_krona_output_all = metaphlan_krona_output.metaphlan_krona_output_txt.collect()
    metaphlan_krona_plots_output = METAPHLAN_KRONA_PLOTS(metaphlan_krona_output_all)

    // Collect all output channels for MultiQC
    multiqc_input = fastp_output.fastp_json_logs.mix(
        bowtie2_output.bowtie2_logs,
        sam2bam_output.sam2bam_logs,
        extract_unmapped_fastq_output.extract_unmapped_samtools_fastq_logs,
        extract_unmapped_sorted_output.extract_unmapped_reads_logs,
        metaphlan_output.metaphlan_logs,
        metaphlan_output.metaphlan_output_txt,
        metaphlan_krona_output.metaphlan_krona_logs,
        combine_metaphlan_tables_output.combine_metaphlan_tables_logs,
        metaphlan_krona_plots_output.metaphlan_krona_plots_logs,
        preprocessing_summary_output,
        split_metaphlan_levels_output
    ).collect()

    // Run MultiQC after all other processes have completed
    MULTIQC(multiqc_input)
}

workflow.onComplete {
    log.info """
             Pipeline execution summary
             ---------------------------
             Completed at: ${workflow.complete}
             Duration    : ${workflow.duration}
             Success     : ${workflow.success}
             workDir     : ${workflow.workDir}
             exit status : ${workflow.exitStatus}
             """
}