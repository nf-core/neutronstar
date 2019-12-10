# ![nfcore/neutronstar](docs/images/nfcore-neutronstar_logo.png)

**De novo assembly pipeline for 10X linked-reads.**

[![Build Status](https://travis-ci.com/nf-core/neutronstar.svg?branch=master)](https://travis-ci.com/nf-core/neutronstar)
[![GitHub Actions CI Status](https://github.com/nf-core/neutronstar/workflows/nf-core%20CI/badge.svg)](https://github.com/nf-core/neutronstar/actions)
[![GitHub Actions Linting Status](https://github.com/nf-core/neutronstar/workflows/nf-core%20linting/badge.svg)](https://github.com/nf-core/neutronstar/actions)
[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A519.04.0-brightgreen.svg)](https://www.nextflow.io/)

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

ii. Install one of [`docker`](https://docs.docker.com/engine/installation/), [`singularity`](https://www.sylabs.io/guides/3.0/user-guide/) or [`conda`](https://conda.io/miniconda.html)

iii. Download the pipeline and test it on a minimal dataset with a single command

```bash
nextflow run nf-core/neutronstar -profile test,<docker/singularity/conda>
```

iv. Start running your own analysis!

```bash
nextflow run nf-core/neutronstar -profile <docker/singularity/conda> --id assembly_id --fastqs fastq_path --genomesize 1000000
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

For further information or help, don't hesitate to get in touch on [Slack](https://nfcore.slack.com/channels/nf-core/neutronstar) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citation

If you use nf-core/neutronstar for your analysis, please cite it using the following doi:

You can cite the `nf-core` pre-print as follows:

> Ewels PA, Peltzer A, Fillinger S, Alneberg JA, Patel H, Wilm A, Garcia MU, Di Tommaso P, Nahnsen S. **nf-core: Community curated bioinformatics pipelines**. *bioRxiv*. 2019. p. 610741. [doi: 10.1101/610741](https://www.biorxiv.org/content/10.1101/610741v1).
