# ![nfcore/neutronstar](docs/images/nfcore-neutronstar_logo.png)

**De novo assembly pipeline for 10X linked-reads.**

[![GitHub Actions CI Status](https://github.com/nf-core/neutronstar/workflows/nf-core%20CI/badge.svg)](https://github.com/nf-core/neutronstar/actions)
[![GitHub Actions Linting Status](https://github.com/nf-core/neutronstar/workflows/nf-core%20linting/badge.svg)](https://github.com/nf-core/neutronstar/actions)
[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A519.10.0-brightgreen.svg)](https://www.nextflow.io/)

[![Docker Container available](https://img.shields.io/docker/automated/nfcore/neutronstar.svg)](https://hub.docker.com/r/nfcore/neutronstar/)
[![Docker Container available](https://img.shields.io/docker/automated/nfcore/supernova.svg)](https://hub.docker.com/r/nfcore/supernova/)
[![Singularity Container available](https://img.shields.io/badge/singularity-available-purple.svg)](https://www.sylabs.io/docs/)
[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg)](http://bioconda.github.io/)

## Table of Contents

1. [Introduction](README.md#introduction)
   * [Disclaimer](README.md#disclaimer)
2. [Important installation information](docs/installation.md)
   * [Singularity](docs/installation.md#singularity)
   * [Busco data](docs/installation.md#busco-data)
3. [Usage instructions](docs/usage.md)
   * [Single assembly](docs/usage.md#single-assembly)
   * [Multiple assemblies](docs/usage.md#multiple-assemblies)
   * [Advanced usage](docs/usage.md#advanced-usage)
4. [Pipeline output](docs/output.md)
5. [Pipeline overview](README.md#pipeline-overview)
6. [Credits](README.md#pipeline-overview)

---------

## Introduction

nf-core/neutronstar is a bioinformatics best-practice analysis pipeline used for de-novo assembly and quality-control of 10x Genomics Chromium data.
The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It comes with docker containers making installation trivial and results highly reproducible.

## Quick Start

i. Install [`nextflow`](https://nf-co.re/usage/installation)

ii. Install either [`Docker`](https://docs.docker.com/engine/installation/) or [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) for full pipeline reproducibility (please only use [`Conda`](https://conda.io/miniconda.html) as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))

iii. Download the pipeline and test it on a minimal dataset with a single command

```bash
nextflow run nf-core/neutronstar -profile test,<docker/singularity/conda/institute>
```

> Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment.

iv. Start running your own analysis!

<!-- TODO nf-core: Update the default command above used to run the pipeline -->

```bash
nextflow run nf-core/neutronstar -profile <docker/singularity/conda/institute> --id assembly_id --fastqs fastq_path --genomesize 1000000
```

See [usage docs](docs/usage.md) for all of the available options when running the pipeline.

## Disclaimer

This software is in no way affiliated with nor endorsed by 10x Genomics.

## Pipeline overview

![nf-core/neutronstar chart](docs/images/neutronstar_chart.png)

## Credits

nf-core/neutronstar was originally written by Remi-Andre Olsen (@remiolsen).

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on [Slack](https://nfcore.slack.com/channels/neutronstar) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citation

If you use nf-core/neutronstar for your analysis, please cite it using the following doi:

You can cite the `nf-core` pre-print as follows:

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).  
> ReadCube: [Full Access Link](https://rdcu.be/b1GjZ)
