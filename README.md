# ![NGI-NeutronStar](docs/images/NGI-NeutronStar_logo.png)

[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A50.25.1-brightgreen.svg)](https://www.nextflow.io/)

### Introduction

NGI-NeutronStar is a bioinformatics best-practice analysis pipeline used for de-novo assembly and quality-control of 10x Genomics Chromium data. It's developed and used at the [National Genomics Infastructure](https://ngisweden.scilifelab.se/) at [SciLifeLab Stockholm](https://www.scilifelab.se/platforms/ngi/), Sweden.

The pipeline uses [Nextflow](https://www.nextflow.io), a bioinformatics workflow tool. It pre-processes raw data from FastQ inputs, aligns the reads and performs extensive quality-control on the results.


### Credits
These scripts were written for use at the [National Genomics Infrastructure](https://portal.scilifelab.se/genomics/) at [SciLifeLab](http://www.scilifelab.se/) in Stockholm, Sweden. Written by Remi-Andre Olsen (@remiolsen).


### Usage instructions
**Note! These instructions are certainly subject to change!** It is recommended that you start the pipeline inside a unix `screen` (or alternatively `tmux`). The pipeline is started using the command: 
```
nextflow run -profile nextflow_profile /path/to/NGI-NeutronStar/main.nf [Supernova options] (--clusterOptions)
```
* `nextflow_profile` is one of the environments that are defined in the file [nextflow.config](nextflow.config)
* `[Supernova options]` are the following options that are following supernova options (use the command `supernova run --help` for a more detailed description or alternatively read the documentation available by [10X Genomics](https://www.10xgenomics.com/))
  * `--fastqs` **required**
  * `--id` **required**
  * `--sample`
  * `--lanes`
  * `--indices`
  * `--bcfrac`
  * `--maxreads`
* `--clusterOptions` are the options to feed to the HPC job manager. For instance for SLURM `--clusterOptions="-A project -C node-type"`
* `--genomesize` **required** The estimated size of the genome(s) to be assembled. This is mainly used by Quast to compute NGxx statstics, e.g. N50 statistics bound by this value and not the assembly size.

NGI-NeutronStar also supports adding these parameters in a `.yaml` file. This way you can run several assemblies in parallel. The following example file (`sample_config.yaml`) will run two assemblies of the test data included in the Supernova installation, one using the default parameters, and one using barcode downsampling:

```
genomesize: 1000000
samples:
  - id: testrun
    fastqs: /sw/apps/bioinfo/Chromium/supernova/1.1.4/assembly-tiny-fastq/1.0.0/
  - id: testrun_bc05
    fastqs: /sw/apps/bioinfo/Chromium/supernova/1.1.4/assembly-tiny-fastq/1.0.0/
    maxreads: 500000000
    bcfrac: 0.5
```
Run nextflow using `nextflow run -profile -params-file sample_config.yaml /path/to/NGI-NeutronStar/main.nf (--clusterOptions)`

---

[![SciLifeLab](https://raw.githubusercontent.com/SciLifeLab/NGI-MethylSeq/master/docs/images/SciLifeLab_logo.png)](http://www.scilifelab.se/)
[![National Genomics Infrastructure](https://raw.githubusercontent.com/SciLifeLab/NGI-MethylSeq/master/docs/images/NGI_logo.png)](https://ngisweden.scilifelab.se/)

---
