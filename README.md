# ![nfcore/neutronstar](docs/images/nfcore-neutronstar_logo.png)

**De novo assembly pipeline for 10X linked-reads.**

[![Build Status](https://travis-ci.org/remiolsen/nf-core-neutronstar.svg?branch=master)](https://travis-ci.org/remiolsen/nf-core-neutronstar)
[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A50.31.1-brightgreen.svg)](https://www.nextflow.io/)
[![Gitter](https://img.shields.io/badge/gitter-%20join%20chat%20%E2%86%92-4fb99a.svg)](https://gitter.im/nf-core/Lobby)

[![Docker Container available](https://img.shields.io/docker/automated/nfcore/neutronstar.svg)](https://hub.docker.com/r/nfcore/neutronstar/)
[![Docker Container available](https://img.shields.io/docker/automated/remiolsen/supernova.svg)](https://hub.docker.com/r/remiolsen/supernova/)
![Singularity Container available](
https://img.shields.io/badge/singularity-available-7E4C74.svg)
[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg)](http://bioconda.github.io/)


## Table of Contents

1. [Introduction](README.md#introduction)
   * [Disclaimer](README.md#disclaimer)
2. [Installation](docs/installation.md)
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

### Introduction

nf-core/neutronstar is a bioinformatics best-practice analysis pipeline used for de-novo assembly and quality-control of 10x Genomics Chromium data. The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It comes with docker / singularity containers to make the results highly reproducible.

#### Disclaimer

This software is in no way affiliated with nor endorsed by 10x Genomics.


---------

### Pipeline overview

![nf-core/neutronstar chart](docs/images/neutronstar_chart.png)

---------

### Credits
These scripts were originally written for use at the [National Genomics Infrastructure](https://portal.scilifelab.se/genomics/) at [SciLifeLab](http://www.scilifelab.se/) in Stockholm, Sweden. Written by Remi-Andre Olsen (@remiolsen).
