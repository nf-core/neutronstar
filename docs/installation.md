# nf-core/neutronstar: Important installation information

## Introduction

nfcore/neutronstar have a few deviations from the [normal installation procedure](https://nf-co.re/usage/local_installation) for nf-core pipelines. They are are listed in this document.

### Singularity

If running the pipeline using the [Singularity](http://singularity.lbl.gov/) configurations (see below), Nextflow will automatically fetch the image from DockerHub. There there are two separate images, one for Supernova only and one for the other requirements of the pipeline.

If your compute environment does not have access to the internet you can build the image elsewhere and run the pipeline using:

```bash
# Build image
singularity pull --name "nf-core-neutronstar.sif" docker://nfcore/neutronstar
singularity pull --name "supernova.sif" docker://remiolsen/supernova
# Upload it to your_hpc:/singularity_images/
```

```bash
# Make a configuration file, custom.yaml with the following paths to your singularity_images

printf """
singularity {
  enabled = true
}

process {

  container = { "/singularity_images/nf-core-neutronstar.sif" }
  withLabel: 'supernova' {
    container = { "/singularity_images/supernova.sif" }
  }

}
""" > custom.yaml
```

```bash
# Run the pipeline with the command
nextflow run -c custom.yaml /my-pipelines/neutronstar-master
```

---------

### BUSCO data

By default nf-core/neutronstar will look for the BUSCO lineage datasets in the `data` folder, e.g. `/my-pipelines/neutronstar-master/data/`. However if you have these datasets installed any other path it is possible to specify this using the option `--busco_folder /path/to/lineage_sets/`. Included with the pipeline is a script to download BUSCO data, in `/my-pipelines/neutronstar/data/busco_data.py`

```bash
# Example downloading a minimal, but broad set of lineages
cd /my-pipelines/nf-core/neutronstar-master/data/
# To list the datasets
#Category minimal contains:
#  - bacteria_odb9
#  - eukaryota_odb9
#  - metazoa_odb9
#  - protists_ensembl
#  - embryophyta_odb9
#  - fungi_odb9
python busco_data.py list minimal
# To download them
python busco_data.py download minimal

```

It is recommended to add your custom path to the BUSCO data (*if you have these installed elsewhere on your system only*) to the `custom.yaml` configuration file. Like so:

```bash
printf """
params.busco_folder = '/path/to/lineage_sets/'
params.busco_data = 'eukaryota_odb9'
""" >> custom.yaml
```
