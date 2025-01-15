# StagNF: A Nextflow Implementation of StaG-mwc

[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A522.10.0-brightgreen.svg)](https://www.nextflow.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![UPPMAX Ready](https://img.shields.io/badge/UPPMAX-Ready-blue.svg)](https://www.uppmax.uu.se/)
[![HPC Compatible](https://img.shields.io/badge/HPC-Compatible-orange.svg)](https://github.com/ruqse/StagNF)

A Nextflow adaptation of the [StaG Metagenomic Workflow Collaboration (mwc)](https://github.com/ctmrbio/stag-mwc) project. This pipeline performs quality control, host removal, and taxonomic profiling of metagenomic samples. Initially developed for UPPMAX clusters but designed to be easily adaptable to any HPC environment.

---

## 🔍 Overview

The pipeline performs the following steps:

1. Quality control and adapter trimming with `fastp`
2. Host sequence removal using `Bowtie2`
3. Taxonomic profiling with `MetaPhlAn`
4. Comprehensive reporting with `MultiQC`

---

## ⚡ Quick Start

### Prerequisites

* **Nextflow** (>=22.10.0)
* **Conda/Mamba**
* **Required tools** (installed via conda):
  ```
  - fastp
  - bowtie2
  - samtools
  - metaphlan
  - krona
  - multiqc
  ```

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/ruqse/StagNF.git
   cd StagNF
   ```

2. **Initialize the environment**
   ```bash
   source StaGnextflow_init.sh
   ```
   
   <details>
   <summary>Initialization Details</summary>
   
   The initialization script performs the following:
   ```bash
   # Core Setup
   - Loads required conda modules
   - Activates the StagNF conda environment
   - Sets up Nextflow and bioinfo tools
   
   # Environment Configuration
   - Sets TMPDIR for your specific HPC
   - Configures cluster-specific parameters
   - Establishes pipeline logging directories
   
   # UPPMAX-Specific (can be modified for other HPCs)
   - Sets SNIC_TMP directories
   - Configures Uppmax-specific paths
   - Establishes project directories
   ```
   
   > **For non-UPPMAX systems**: Modify environment variables and paths in the initialization script according to your HPC's requirements.
   </details>

3. **Configure the pipeline**
   - Edit `nextflow.config` for computing resources:
     ```groovy
     // Example HPC configurations
     profiles {
         uppmax {
             // Default UPPMAX settings
             process.executor = 'slurm'
             process.clusterOptions = '-A project_id'
         }
         
         generic_slurm {
             // For other SLURM-based clusters
             process.executor = 'slurm'
             // Modify parameters for your system
         }
         
         sge {
             // For SGE-based systems
             process.executor = 'sge'
         }
         
         custom {
             // Your HPC settings here
         }
     }
     ```
   - Modify `main.nf` for input parameters

4. **Run the pipeline**
   ```bash
   # For UPPMAX systems
   nextflow run main.nf -profile uppmax
   
   # For other SLURM clusters
   nextflow run main.nf -profile generic_slurm
   
   # For custom configurations
   nextflow run main.nf -profile custom
   ```

---

## 📥 Input

The pipeline accepts both paired-end and single-end FASTQ files:

```nextflow
// For paired-end reads
params.reads = "$projectDir/data/*{1,2,R1,R2}.fastq.gz"

// For single-end reads
params.single_end_reads = "$projectDir/data/*.fastq.gz"
```

---

## 📤 Output Structure

The pipeline generates the following directory structure:

```
results/
├── host_removal/
│   ├── *.bam                     # Mapped reads to host genome
│   └── *_unmapped.sorted.bam     # Unmapped reads (non-host)
│
├── logs/
│   ├── bowtie2/                  # Bowtie2 alignment logs
│   ├── fastp/                    # FastP quality trimming logs
│   ├── host_removal/             # Host removal processing logs
│   ├── metaphlan/                # MetaPhlAn profiling logs
│   ├── multiqc/                  # MultiQC logs
│   └── preprocessing_summary.log
│
├── metaphlan/
│   ├── all_samples.metaphlan.txt  # Combined taxonomic profiles
│   ├── levels/                    # Taxonomic level-specific tables
│   │   ├── family.tsv
│   │   ├── genus.tsv
│   │   ├── order.tsv
│   │   └── species.tsv
│   ├── *.bowtie2.bz2            # Compressed alignment files
│   ├── *.krona                   # Krona visualization files
│   ├── *.metaphlan.txt          # Per-sample taxonomic profiles
│   └── *.sam.bz2                # Compressed SAM files
│
├── multiqc/
│   ├── multiqc_report.html       # Interactive HTML report
│   ├── multiqc_report_data/      # Raw data for the report
│   └── multiqc_report_plots/     # Generated plots
│
└── preprocessing_read_counts.txt  # Summary of read counts
```

> **Note**: Files with `*` represent sample-specific files, where the wildcard is replaced with the sample identifier (e.g., SRR18765383)

---

## 🧩 Modules & Scripts

### Core Processing Modules

#### Quality Control
- **`fastp`**
  - Performs quality control and adapter trimming
  - Handles both single-end and paired-end reads
  - Generates JSON reports and HTML visualizations

#### Host Removal Pipeline
- **`bowtie2`**
  - Aligns reads against human reference genome (hg19)
  - Supports both single-end and paired-end alignment
  - Outputs SAM format alignments

- **`sam2bam`**
  - Converts SAM to BAM format
  - Optimized for parallel processing
  - Generates compressed BAM output

- **`extract_unmapped_reads`**
  - Extracts reads that don't map to host genome
  - Uses different flags for single-end (-f 4) and paired-end (-f 13 -F 256)
  - Produces sorted BAM output

- **`extract_unmapped_fastq`**
  - Converts unmapped BAM to FASTQ format
  - Handles both single and paired-end data
  - Compresses output with gzip

#### Taxonomic Profiling
- **`metaphlan`**
  - Performs taxonomic profiling of microbial communities
  - Uses MetaPhlAn marker gene database
  - Generates species-level abundance profiles

- **`combine_metaphlan_tables`**
  - Merges individual sample profiles
  - Removes redundant file extensions
  - Creates a combined abundance table

- **`split_metaphlan_levels`**
  - Separates taxonomic levels into distinct files
  - Processes species, genus, family, and order levels
  - Generates clean TSV files for each level

- **`metaphlan_krona`**
  - Converts MetaPhlAn output to Krona format
  - Extracts species-level classifications
  - Prepares data for interactive visualization

- **`metaphlan_krona_plots`**
  - Generates interactive Krona visualizations
  - Creates both per-sample and combined plots
  - Outputs HTML format for easy sharing

#### Quality Reporting
- **`preprocessing_summary`**
  - Summarizes read counts at each processing step
  - Combines FastP and Bowtie2 statistics
  - Generates a comprehensive summary table

- **`multiqc`**
  - Aggregates QC reports from all steps
  - Creates an interactive HTML report
  - Exports results for further analysis

### Visualization Scripts

Located in `scripts/` directory:

#### Analysis Scripts
- **`preprocessing_summary.py`**
  - Summarizes read counts through pipeline stages
  - Generates quality metrics visualization
  - Creates detailed processing statistics

- **`plot_proportion_kraken2.py`**
  - Visualizes proportion of classified reads
  - Creates histograms and barplots
  - Outputs publication-ready figures

- **`plot_sketch_comparison_heatmap.py`**
  - Generates sample similarity heatmaps
  - Performs hierarchical clustering
  - Visualizes sample relationships

#### Utility Scripts
- **`join_tables.py`**
  - Combines feature tables across samples
  - Handles missing values
  - Supports multiple input formats

- **`make_count_table.py`**
  - Creates count tables from RPKM data
  - Processes multi-column annotations
  - Generates normalized abundance tables

- **`area_plot.py`**
  - Creates stacked area plots
  - Visualizes taxonomic compositions
  - Supports multiple visualization modes

> Each module and script is designed to work independently while maintaining consistent input/output formats for seamless pipeline integration. All modules include comprehensive logging and error handling for robust execution in high-performance computing environments.

---

## 📚 Citation

Please cite the following if you use this pipeline:

* **StaG-mwc project**: DOI:10.5281/zenodo.125840716
* **FastP**: Chen et al. 2018 
* **Bowtie2**: Langmead et al. 2012
* **MetaPhlAn**: Beghini et al. 2021
* **MultiQC**: Ewels et al. 2016

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 💬 Support

- 🐛 [Report a bug](https://github.com/ruqse/StagNF/issues)

---

## 👏 Acknowledgments

This pipeline is adapted from the StaG Metagenomic Workflow Collaboration (mwc) project, originally developed as a Snakemake workflow. The Nextflow implementation maintains the core functionality while leveraging Nextflow's workflow management capabilities.

---

<div align="center">
<em>This Nextflow adaptation was developed by Faruk Dube at Scilifelab (Uppsala University)</em>
</div>