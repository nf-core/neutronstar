### Usage instructions
It is recommended that you start the pipeline inside a unix `screen` (or alternatively `tmux`).

---------

#### Single assembly
To assemble a single sample, the pipeline can be started using the following command:
```
nextflow run -profile nextflow_profile /path/to/neutronstar [Supernova options] (--clusterOptions)
```
* `nextflow_profile` is one of the environments that are defined in the file [nextflow.config](nextflow.config)
* `[Supernova options]` are the following options that are following supernova options (use the command `supernova run --help` for a more detailed description or alternatively read the documentation available by [10X Genomics](https://www.10xgenomics.com/))
  * `--fastqs` **required**
  * `--id` **required**
  * `--sample`
  * `--lanes`
  * `--indices`
  * `--bcfrac`
  * `--maxreads` **required in Supernova >= 2.1**
  * `--accept_extreme_coverage`
  * `--nopreflight`
* `--clusterOptions` are the options to feed to the HPC job manager. For instance for SLURM `--clusterOptions="-A project -C node-type"`
* `--genomesize` **required** The estimated size of the genome(s) to be assembled. This is mainly used by Quast to compute NGxx statstics, e.g. N50 statistics bound by this value and not the assembly size.
* `--BUSCOdata` The dataset BUSCO should use (e.g. eukaryota_odb9, protists_ensembl)

---------

#### Multiple assemblies
nf-core/neutronstar also supports adding the above parameters in a `.yaml` file. This way you can run several assemblies in parallel. The following example file (`sample_config.yaml`) will run two assemblies of the test data included in the Supernova installation, one using the default parameters, and one using barcode downsampling:

```yaml
genomesize: 1000000
samples:
  - id: testrun
    fastqs: /sw/apps/bioinfo/Chromium/supernova/1.1.4/assembly-tiny-fastq/1.0.0/
    maxreads: all
  - id: testrun_bc05
    fastqs: /sw/apps/bioinfo/Chromium/supernova/1.1.4/assembly-tiny-fastq/1.0.0/
    maxreads: 500000000
    bcfrac: 0.5
```
Run nextflow using `nextflow run -profile nextflow_profile -params-file sample_config.yaml /path/to/neutronstar (--clusterOptions)`

---------

#### Advanced usage

If not specifying the option `-profile` it will use a default one that is suitable in a high-performance computing environment with a minimum of 256 Gb memory. For instance for a compute cluster with the [Slurm](https://slurm.schedmd.com/documentation.html) job scheduler and Singularity version >= 2.4 installed, `-profile singularity,slurm`.
If running tests on a laptop (Using for instance the test data included with Supernova) you should use the options `--max_cpu` and `--max_memory` to fit the specifications of you machine.

To greatly reduce the storage requirements of the assembly graphs of Supernova, only a limited number of files will be copied from it's output. Enough to run `supernova mkoutput`. If you for some reason require the full output, please run with the argument `--full_output`
