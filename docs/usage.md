# nf-core/neutronstar: Usage

## Table of contents

<!-- Install Atom plugin markdown-toc-auto for this ToC to auto-update on save -->
<!-- TOC START min:2 max:3 link:true asterisk:true update:true -->
* [Table of contents](#table-of-contents)
* [Introduction](#introduction)
* [Running the pipeline](#running-the-pipeline)
  * [Updating the pipeline](#updating-the-pipeline)
  * [Reproducibility](#reproducibility)
* [Main arguments](#main-arguments)
  * [Single assembly](#single-assembly)
  * [Multiple assemblies](#multiple-assemblies)
  * [Advanced usage](#advanced-usage)
  * [`-profile`](#-profile)
* [Job resources](#job-resources)
  * [Automatic resubmission](#automatic-resubmission)
  * [Custom resource requests](#custom-resource-requests)
* [Other command line parameters](#other-command-line-parameters)
  * [`--outdir`](#--outdir)
  * [`--email`](#--email)
  * [`--email_on_fail`](#--email_on_fail)
  * [`-name`](#-name)
  * [`-resume`](#-resume)
  * [`-c`](#-c)
  * [`--custom_config_version`](#--custom_config_version)
  * [`--custom_config_base`](#--custom_config_base)
  * [`--max_memory`](#--max_memory)
  * [`--max_time`](#--max_time)
  * [`--max_cpus`](#--max_cpus)
  * [`--plaintext_email`](#--plaintext_email)
  * [`--monochrome_logs`](#--monochrome_logs)
  * [`--multiqc_config`](#--multiqc_config)
<!-- TOC END -->

## Introduction

Nextflow handles job submissions on SLURM or other environments, and supervises running the jobs. Thus the Nextflow process must run until the pipeline is finished. We recommend that you put the process running in the background through `screen` / `tmux` or similar tool. Alternatively you can run nextflow within a cluster job submitted your job scheduler.

It is recommended to limit the Nextflow Java virtual machines memory. We recommend adding the following line to your environment (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```

## Running the pipeline

The typical command for running the pipeline is as follows:

```bash
nextflow run nf-core/neutronstar -profile docker --id assembly_id --fastqs fastq_path --genomesize 1000000
```

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work            # Directory containing the nextflow working files
results         # Finished results (configurable, see below)
.nextflow_log   # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

```bash
nextflow pull nf-core/neutronstar
```

### Reproducibility

It's a good idea to specify a pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [nf-core/neutronstar releases page](https://github.com/nf-core/neutronstar/releases) and find the latest version number - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future.

## Main arguments

### Single assembly

To assemble a single sample, the pipeline can be started using the following command:

```bash
nextflow run -profile nextflow_profile /path/to/neutronstar [Supernova options] (--clusterOptions)
```

* `nextflow_profile` is one of the environments that are defined in the file [nextflow.config](nextflow.config)
* `[Supernova options]` are the following options that are following supernova options (use the command `supernova run --help` for a more detailed description or alternatively read the documentation available by [10X Genomics](https://www.10xgenomics.com/))
  * `--fastqs` **required** Path of folder created by mkfastq or bcl2fastq.
  * `--id` **required** A unique run id, used to name output folder [a-zA-Z0-9_-]+.
  * `--sample` Prefix of the filenames of FASTQs to select.
  * `--lanes` Comma-separated lane numbers.
  * `--indices` Comma-separated sample index set "SI-001" or sequences.
  * `--bcfrac` Fraction of barcodes in the sample to use.
  * `--maxreads` Downsample if more than NUM individual reads are provided or 'all' to use all reads provided (default='all')
  * `--no_accept_extreme_coverage` Disables `--accept_extreme_coverage` option for Supernova
  * `--nopreflight` Skip preflight checks.
  * `--minsize` Skip FASTA records shorter than NUM. (default=1000)
* `--clusterOptions` are the options to feed to the HPC job manager. For instance for SLURM `--clusterOptions="-A project -C node-type"`
* `--genomesize` The estimated size of the genome(s) to be assembled. This is mainly used by Quast to compute NGxx statstics, e.g. N50 statistics bound by this value and not the assembly size.
* `--busco_data` The dataset BUSCO should use (e.g. eukaryota_odb9, protists_ensembl)
* `--busco_folder` Path to directory containing BUSCO datasets (default=$baseDir/data)

---------

### Multiple assemblies

nf-core/neutronstar also supports adding the above parameters in a `.yaml` file. This way you can run several assemblies in parallel. The following example file (`sample_config.yaml`) will run two assemblies of the test data included in the Supernova installation, one using the default parameters, and one using barcode downsampling:

```yaml
genomesize: 1000000
samples:
  - id: testrun
    fastqs: /sw/apps/bioinfo/Chromium/supernova/1.1.4/assembly-tiny-fastq/1.0.0/
  - id: testrun_bc05
    fastqs: /sw/apps/bioinfo/Chromium/supernova/1.1.4/assembly-tiny-fastq/1.0.0/
    maxreads: 500000000
    bcfrac: 0.5
```

Run nextflow using `nextflow run -profile nextflow_profile -params-file sample_config.yaml /path/to/neutronstar (--clusterOptions)`

---------

### Advanced usage

To greatly reduce the storage requirements of the assembly graphs of Supernova, only a limited number of files will be copied from it's output. Enough to run `supernova mkoutput`. If you for some reason require the full output, please run with the argument `--full_output`

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments. Note that multiple profiles can be loaded, for example: `-profile docker` - the order of arguments is important!

If `-profile` is not specified at all the pipeline will be run locally and expects all software to be installed and available on the `PATH`.

* `conda`
  * A generic configuration profile to be used with [conda](https://conda.io/docs/)
  * Pulls most software from [Bioconda](https://bioconda.github.io/)
* `docker`
  * A generic configuration profile to be used with [Docker](http://docker.com/)
  * Pulls software from dockerhub: [`nfcore/neutronstar`](http://hub.docker.com/r/nfcore/neutronstar/)
* `singularity`
  * A generic configuration profile to be used with [Singularity](http://singularity.lbl.gov/)
  * Pulls software from DockerHub: [`nfcore/neutronstar`](http://hub.docker.com/r/nfcore/neutronstar/)
* `test`
  * A profile with a complete configuration for automated testing
  * Includes links to test data so needs no other parameters

## Job resources

### Automatic resubmission

Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the steps in the pipeline, if the job exits with an error code of `143` (exceeded requested resources) it will automatically resubmit with higher requests (2 x original, then 3 x original). If it still fails after three times then the pipeline is stopped.

### Custom resource requests

Wherever process-specific requirements are set in the pipeline, the default value can be changed by creating a custom config file. See the files hosted at [`nf-core/configs`](https://github.com/nf-core/configs/tree/master/conf) for examples.

If you are likely to be running `nf-core` pipelines regularly it may be a good idea to request that your custom config file is uploaded to the `nf-core/configs` git repository. Before you do this please can you test that the config file works with your pipeline of choice using the `-c` parameter (see definition below). You can then create a pull request to the `nf-core/configs` repository with the addition of your config file, associated documentation file (see examples in [`nf-core/configs/docs`](https://github.com/nf-core/configs/tree/master/docs)), and amending [`nfcore_custom.config`](https://github.com/nf-core/configs/blob/master/nfcore_custom.config) to include your custom profile.

If you have any questions or issues please send us a message on [Slack](https://nf-co.re/join/slack/).

## Other command line parameters

### `--outdir`

The output directory where the results will be saved.

### `--email`

Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits. If set in your user config file (`~/.nextflow/config`) then you don't need to specify this on the command line for every run.

### `--email_on_fail`

This works exactly as with `--email`, except emails are only sent if the workflow is not successful.

### `-name`

Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic.

This is used in the MultiQC report (if not default) and in the summary HTML / e-mail (always).

**NB:** Single hyphen (core Nextflow option)

### `-resume`

Specify this when restarting a pipeline. Nextflow will used cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously.

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

**NB:** Single hyphen (core Nextflow option)

### `-c`

Specify the path to a specific config file (this is a core NextFlow command).

**NB:** Single hyphen (core Nextflow option)

Note - you can use this to override pipeline defaults.

### `--custom_config_version`

Provide git commit id for custom Institutional configs hosted at `nf-core/configs`. This was implemented for reproducibility purposes. Default is set to `master`.

```bash
## Download and use config file with following git commid id
--custom_config_version d52db660777c4bf36546ddb188ec530c3ada1b96
```

### `--custom_config_base`

If you're running offline, nextflow will not be able to fetch the institutional config files
from the internet. If you don't need them, then this is not a problem. If you do need them,
you should download the files from the repo and tell nextflow where to find them with the
`custom_config_base` option. For example:

```bash
## Download and unzip the config files
cd /path/to/my/configs
wget https://github.com/nf-core/configs/archive/master.zip
unzip master.zip

## Run the pipeline
cd /path/to/my/data
nextflow run /path/to/pipeline/ --custom_config_base /path/to/my/configs/configs-master/
```

> Note that the nf-core/tools helper package has a `download` command to download all required pipeline
> files + singularity containers + institutional configs in one go for you, to make this process easier.

### `--max_memory`

Use to set a top-limit for the default memory requirement for each process.
Should be a string in the format integer-unit. eg. `--max_memory '8.GB'`

### `--max_time`

Use to set a top-limit for the default time requirement for each process.
Should be a string in the format integer-unit. eg. `--max_time '2.h'`

### `--max_cpus`

Use to set a top-limit for the default CPU requirement for each process.
Should be a string in the format integer-unit. eg. `--max_cpus 1`

### `--plaintext_email`

Set to receive plain-text e-mails instead of HTML formatted.

### `--monochrome_logs`

Set to disable colourful command line output and live life in monochrome.

### `--multiqc_config`

Specify a path to a custom MultiQC configuration file.
