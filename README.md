# ![NGI-NeutronStar](docs/images/NGI-NeutronStar_logo.png)

[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A50.27.6-brightgreen.svg)](https://www.nextflow.io/)

## Table of Contents

1. [Introduction](README.md#introduction)
   * [Disclaimer](README.md#disclaimer)
2. [Installation](README.md#installation)
   * [Singularity](README.md#singularity)
   * [Busco data](README.md#busco-data)
3. [Usage instuctions](README.md#usage-instructions)
   * [Single assembly](README.md#single-assembly)
   * [Multiple assemblies](README.md#multiple-assemblies)
   * [Advanced usage](README.md#advanced-usage)
4. [Pipeline overview](README.md#pipeline-overview)
5. [Credits](README.md#pipeline-overview)

---------

### Introduction

NGI-NeutronStar is a bioinformatics best-practice analysis pipeline used for de-novo assembly and quality-control of 10x Genomics Chromium data. It's developed and used at the [National Genomics Infastructure](https://ngisweden.scilifelab.se/) at [SciLifeLab Stockholm](https://www.scilifelab.se/platforms/ngi/), Sweden. The pipeline uses [Nextflow](https://www.nextflow.io), a bioinformatics workflow tool.

#### Disclaimer

This software is in no way affiliated with nor endorsed by 10x Genomics.

### Installation

Nextflow runs on most POSIX systems (Linux, Mac OSX etc). It can be installed by running the following commands:

```
# Make sure that Java v7+ is installed:
java -version

# Install Nextflow
curl -fsSL get.nextflow.io | bash

# Add Nextflow binary to your PATH:
mv nextflow ~/bin
# OR system-wide installation:
# sudo mv nextflow /usr/local/bin
```
You need NextFlow version >= 0.25 to run this pipeline.

While it is possible to run the pipeline by having nextflow fetch it directly from GitHub, e.g `nextflow run SciLifeLab/NGI-NeutronStar`, depending on your system you will most likely have to download it (and configure it):

```
get https://github.com/SciLifeLab/NGI-NeutronStar/archive/master.zip
unzip master.zip -d /my-pipelines/
cd /my_data/
nextflow run /my-pipelines/NGI-NeutronStar-master
```

#### Singularity

If running the pipeline using the [Singularity](http://singularity.lbl.gov/) configurations (see below), Nextflow will automatically fetch the image from DockerHub. However if your compute environment does not have access to the internet you can build the image elsewhere and run the pipeline using:

```
# Build image
singularity pull --name "ngi-neutronstar.simg" docker://remiolsen/ngi-neutronstar
# After uploading it to your_hpc:/singularity_images/
nextflow run -with-singularity /singularity_images/ngi-neutronstar.simg /my-pipelines/NGI-NeutronStar-master
``` 

#### Busco data

By default NGI-NeutronStar will look for the BUSCO lineage datasets in the `data` folder, e.g. `/my-pipelines/NGI-NeutronStar-master/data/`. However if you have these datasets installed any other path it is possible to specify this using the option `--BUSCOfolder /path/to/lineage_sets/`. Included with the pipeline is a script to download BUSCO data, in `/my-pipelines/NGI-NeutronStar-master/data/busco_data.py`

```
# Example downloading a minimal, but broad set of lineages
cd /my-pipelines/NGI-NeutronStar-master/data/
# To list the datasets
#Category minimal contains:
#  - bacteria_odb9
#  - eukaryota_odb9
#  - metazoa_odb9
#  - protists_ensembl
#  - embryophyta_odb9
#  - fungi_odb9
python busco_data.py list minimal
# To downoad them
python busco_data.py download minimal

```

---------

### Usage instructions
It is recommended that you start the pipeline inside a unix `screen` (or alternatively `tmux`). 

#### Single assembly
To assemble a single sample, the pipeline can be started using the following command: 
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

#### Multiple assemblies
NGI-NeutronStar also supports adding the above parameters in a `.yaml` file. This way you can run several assemblies in parallel. The following example file (`sample_config.yaml`) will run two assemblies of the test data included in the Supernova installation, one using the default parameters, and one using barcode downsampling:

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

#### Advanced usage

If not specifying the option `-profile` it will use a default one that is suitable to testing the pipeline on a typical laptop computer (using the test dataset included with the Supernova package). In a high-performance computing environment (and with real data) you should specify one of the `hpc` profiles. For instance for a compute cluster with the [Slurm](https://slurm.schedmd.com/documentation.html) job scheduler and Singularity version >= 2.4 installed, `hpc_singularity_slurm`. 

---------

### Pipeline overview
![NGI-NeutronStarChart](docs/images/NGI-NeutronStar_chart.png)

---------

### Credits
These scripts were written for use at the [National Genomics Infrastructure](https://portal.scilifelab.se/genomics/) at [SciLifeLab](http://www.scilifelab.se/) in Stockholm, Sweden. Written by Remi-Andre Olsen (@remiolsen).


---

[![SciLifeLab](https://raw.githubusercontent.com/SciLifeLab/NGI-MethylSeq/master/docs/images/SciLifeLab_logo.png)](http://www.scilifelab.se/)
[![National Genomics Infrastructure](https://raw.githubusercontent.com/SciLifeLab/NGI-MethylSeq/master/docs/images/NGI_logo.png)](https://ngisweden.scilifelab.se/)

---
