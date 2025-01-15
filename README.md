# StagNF: A Nextflow Implementation of StaG-mwc

[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A522.10.0-brightgreen.svg)](https://www.nextflow.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Nextflow adaptation of the [StaG Metagenomic Workflow Collaboration (mwc)](https://github.com/ctmrbio/stag-mwc) project. This pipeline performs quality control, host removal, and taxonomic profiling of metagenomic samples.

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
   > This script will:
   > - Load required conda modules
   > - Activate the StagNF environment
   > - Configure Nextflow settings
   > - Set up cluster-specific parameters

3. **Configure the pipeline**
   - Edit `nextflow.config` for computing resources
   - Modify `main.nf` for input parameters

4. **Run the pipeline**
   ```bash
   nextflow run main.nf -profile uppmax
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

## ⚙️ Configuration

The pipeline includes built-in support for UPPMAX clusters. Configure resources in `nextflow.config`:

```groovy
process {
    executor = 'slurm'
    
    // Resource allocation with automatic retry scaling
    memory = { 20.GB * task.attempt }
    cpus = { 4 * task.attempt }
    time = { 2.h * task.attempt }
    
    maxRetries = 6
}
```

---

## 🧩 Modules

| Module | Description |
|--------|-------------|
| `fastp` | Quality control and adapter trimming |
| `bowtie2` | Host sequence alignment |
| `metaphlan` | Taxonomic profiling |
| `multiqc` | Report generation |

> Each module is defined in the `modules/` directory with standardized inputs, outputs, and resource requirements.

---

## 📚 Citation

Please cite the following if you use this pipeline:

* **StaG-mwc project**: DOI:10.5281/zenodo.125840716
* **FastP**: Chen et al. 2018 
* **Bowtie2**: Langmead et al. 2012
* **MetaPhlAn**: Beghini et al. 2021
* **MultiQC**: Ewels et al. 2016

---

## 🤝 Contributing

We welcome contributions! Here's how:

1. Fork the repository
2. Create your feature branch
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. Commit your changes
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. Push to the branch
   ```bash
   git push origin feature/AmazingFeature
   ```
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 💬 Support

- 🐛 [Report a bug](https://github.com/ruqse/StagNF/issues)
- 💡 [Request a feature](https://github.com/ruqse/StagNF/issues)
- 📝 [View documentation](https://github.com/ruqse/StagNF/wiki)

---

## 👏 Acknowledgments

This pipeline is adapted from the StaG Metagenomic Workflow Collaboration (mwc) project, originally developed as a Snakemake workflow. The Nextflow implementation maintains the core functionality while leveraging Nextflow's workflow management capabilities.

---

<div align="center">
<em>This Nextflow adaptation was developed by Faruk Dube at Scilifelab (Uppsala University)</em>
</div>