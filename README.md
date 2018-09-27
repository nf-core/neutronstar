# nf-core/neutronstar
**De novo assembly pipeline for 10X linked-reads, used at the SciLifeLab National Genomics Infrastructure.**

[![Build Status](https://travis-ci.org/nf-core/neutronstar.svg?branch=master)](https://travis-ci.org/remiolsen/nf-core-neutronstar)
[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A50.30.0-brightgreen.svg)](https://www.nextflow.io/)
![Singularity Container available](
https://img.shields.io/badge/singularity-available-7E4C74.svg)


## Table of Contents

1. [Introduction](README.md#introduction)
   * [Disclaimer](README.md#disclaimer)
2. [Installation](docs/installation.md)
   * [Singularity](docs/installation.md#singularity)
   * [Busco data](docs/installation.md#busco-data)
3. [Usage instructions](docs/usage.md)
   * [Single assembly](docs/usage.md#single-assembly)
   * [Multiple assemblies](docs/usage.md#multiple-assemblies)
   * [Advanced usage](docs/usage.mdd#advanced-usage)
4. [Pipeline output](docs/output.md)
5. [Pipeline overview](README.md#pipeline-overview)
6. [Credits](README.md#pipeline-overview)

---------

### Introduction

NGI-NeutronStar is a bioinformatics best-practice analysis pipeline used for de-novo assembly and quality-control of 10x Genomics Chromium data. The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It comes with docker / singularity containers to make the results highly reproducible.

#### Disclaimer

This software is in no way affiliated with nor endorsed by 10x Genomics.


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
