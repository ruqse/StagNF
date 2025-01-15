\# StagNF: A Nextflow Implementation of StaG-mwc

\[\![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A522.10.0-brightgreen.svg)\](https://www.nextflow.io/)
\[\![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)\](https://opensource.org/licenses/MIT)

\## Description

A Nextflow adaptation of the \[StaG Metagenomic Workflow Collaboration (mwc)\](https://github.com/ctmrbio/stag-mwc) project. This pipeline performs quality control, host removal, and taxonomic profiling of metagenomic samples.

\## Overview

The pipeline performs the following steps:

1\. Quality control and adapter trimming with \`fastp\`
2\. Host sequence removal using \`Bowtie2\`
3\. Taxonomic profiling with \`MetaPhlAn\`
4\. Comprehensive reporting with \`MultiQC\`

\## Requirements

\* \*\*Nextflow\*\* (>=22.10.0)
\* \*\*Conda/Mamba\*\*
\* \*\*Required tools\*\* (installed via conda):
  \* \`fastp\`
  \* \`bowtie2\`
  \* \`samtools\`
  \* \`metaphlan\`
  \* \`krona\`
  \* \`multiqc\`

\## Quick Start

\### 1. Clone the repository

\```bash
git clone https://github.com/ruqse/StagNF.git
cd StagNF
\```

\### 2. Initialize the environment

\```bash
source StaGnextflow_init.sh
\```

This initialization script:
\* Loads the required conda module
\* Activates the StagNF conda environment
\* Loads Nextflow and other bioinfo tools
\* Sets up necessary environment variables for Nextflow execution
\* Configures temporary directory settings for UPPMAX cluster usage

\### 3. Configure the pipeline

\* Edit \`nextflow.config\` to set your computing environment and resources
\* Modify input parameters in \`main.nf\` if needed

\### 4. Run the pipeline

\```bash
nextflow run main.nf -profile uppmax
\```

\## Input

The pipeline accepts both paired-end and single-end FASTQ files:

\```nextflow
params.reads = "$projectDir/data/*{1,2,R1,R2}.fastq.gz"
params.single_end_reads = "$projectDir/data/*.fastq.gz"
\```

\## Output

The pipeline generates the following output directories:

\* \`fastp/\`
  \* Quality control reports
  \* Trimmed reads
\* \`host_removal/\`
  \* Host-filtered reads
  \* Alignment statistics  
\* \`metaphlan/\`
  \* Taxonomic profiles
  \* Abundance tables
\* \`logs/\`
  \* Log files from all tools
\* \`multiqc/\`
  \* MultiQC report summarizing all results

\## Configuration

The pipeline includes built-in support for UPPMAX clusters through the profile configuration in \`nextflow.config\`. Default resource allocations can be modified in the config file:

\```groovy
process {
    executor = 'slurm'
    memory = { 20.GB * task.attempt }
    cpus = { 4 * task.attempt }
    time = { 2.h * task.attempt }
    maxRetries = 6
}
\```

\## Modules

The pipeline is built from modular components:

\* \*\*\`fastp\`\*\*: Quality control and adapter trimming
\* \*\*\`bowtie2\`\*\*: Host sequence alignment
\* \*\*\`metaphlan\`\*\*: Taxonomic profiling
\* \*\*\`multiqc\`\*\*: Report generation

Each module is defined in the \`modules/\` directory with standardized inputs, outputs and resource requirements.

\## Citation

If you use this pipeline, please cite:

\* \*\*StaG-mwc project\*\*: DOI:10.5281/zenodo.125840716
\* \*\*FastP\*\*: Chen et al. 2018 
\* \*\*Bowtie2\*\*: Langmead et al. 2012
\* \*\*MetaPhlAn\*\*: Beghini et al. 2021
\* \*\*MultiQC\*\*: Ewels et al. 2016

\## License

This project is licensed under the MIT License - see the \[LICENSE\](LICENSE) file for details.

\## Support

For questions and issues, please \[open an issue\](https://github.com/ruqse/StagNF/issues) on GitHub.

\## Contributing

Contributions are welcome! Please follow these steps:

1\. Fork the repository
2\. Create your feature branch (\`git checkout -b feature/AmazingFeature\`)
3\. Commit your changes (\`git commit -m 'Add some AmazingFeature'\`)
4\. Push to the branch (\`git push origin feature/AmazingFeature\`)
5\. Open a Pull Request

\## Acknowledgments

This pipeline is adapted from the StaG Metagenomic Workflow Collaboration (mwc) project, originally developed as a Snakemake workflow. The Nextflow implementation maintains the core functionality while leveraging Nextflow's workflow management capabilities.

\---

\*This Nextflow adaptation was developed by Faruk Dube at Scilifelab (Uppsala University).\*