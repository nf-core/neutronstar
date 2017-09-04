#!/usr/bin/env nextflow
/*
vim: syntax=groovy
-*- mode: groovy;-*-
*/


//##### Parameters
version = 0.3

// Common options for both supernova and longranger
def TenX_optional = {sample, lanes, indices, project->
    def str = ""
    sample!=null ? str <<= "--sample=${sample} " : null
    lanes!=null ? str <<= "--lanes=${lanes} " : null
    indices!=null ? str <<= "--indices=${indices} " : null
    project!=null ? str <<= "--project=${project} " : null
    return str
}
// Now only supernova options
def supernova_optional = {maxreads, bcfrac->
    def str = ""
    maxreads!=null ? str <<= "--maxreads=${maxreads} " : null
    bcfrac!=null ? str <<= "--bcfrac=${bcfrac} " : null
    return str
}

samples = []
if (params.samples == null) { //We don't have sample JSON/YAML file, just use cmd-line
    assert params.id != null : "Missing --id option"
    assert params.fastqs != null : "Missing --fastqs option"
    samples << params.id
    samples << params.fastqs
    samples << TenX_optional(params.sample, params.lanes, params.indices, params.project)
    samples << supernova_optional(params.maxreads, params.bcfrac)
}
for (sample in params.samples) { 
    assert sample.id != null : "Error in input parameter file"
    assert sample.fastqs != null : "Error in input parameter file"
    s = []
    s << sample.id
    s << sample.fastqs
    s << TenX_optional(sample.sample, sample.lanes, sample.indices, sample.project)
    s << supernova_optional(sample.maxreads, sample.bcfrac)
    samples << s  
}
params.outdir="."
params.BUSCOdata = "\$BUSCO_LINEAGE_SETS/eukaryota_odb9"


//###### Start
log.info "     \\|/"
log.info "  ----*----   N e u t r o n S t a r (${version})"
log.info "     /|\\"
for (i in samples) {  
    log.info "  supernova run --id=${i[0]} --fastqs=${i[1]} ${i[2]} ${i[3]}"
}
log.info "  outdir = ${params.outdir}"

Channel
    .from(samples)
    .into { supernova_input; longranger_input }

process supernova {
    tag "${id}"
    publishDir "${params.outdir}/supernova/", mode: 'copy'

    input:
    set val(id), val(fastqs), val(tenx_options), val(supernova_options) from supernova_input

    output:
    set val(id), file("${id}_supernova") into supernova_results

    script:
    def mem = Math.round(task.memory.toBytes() / 1024 / 1024 / 1024) - 2
    """
    supernova run --id=${id} --fastqs=${fastqs} --localcores=${task.cpus} --localmem=${mem} ${tenx_options} ${supernova_options}
    rsync -rav --include="_*" --include="*.tgz" --include="outs/" --include="outs/*.*"  --include="assembly/" --include="stats/***" --include="logs/***" --include="a.base/" --include="a.hbx" --include="a.inv" --include="final/***" --exclude="*" "${id}/" ${id}_supernova
    """
}

process mkoutput {
    tag "${id}"
    publishDir "${params.outdir}/assemblies/", mode: 'copy'

    input:
    set val(id), file(supernova_folder) from supernova_results

    output:
    set val(id), file("${id}.supernova.scf.fasta") into supernova_asm1, supernova_asm2

    script:
    def asm = "${id}.supernova.scf"
    """
    supernova mkoutput --asmdir=${supernova_folder}/outs/assembly --outprefix=${asm} --style=pseudohap
    gzip -d ${asm}.fasta.gz
    """
}
/*
process longranger {
    tag "${id}"
    publishDir "${params.outdir}/align/${id}", mode: 'copy'

    input:
    set val(id), val(fastqs), val(tenx_options), val(supernova_options) from longranger_input

    output:
    set val(id), file("${id}.barcoded.R[12].fastq.gz") into longranger_fastq
    
    script:
    def mem = Math.round(task.memory.toBytes() / 1024 / 1024 / 1024)
    """
    longranger basic --id=${id} --fastqs=${fastqs} --localcores=${task.cpus} --localmem=${mem} ${tenx_options}
    pigz -d -c --processes ${task.cpus} ${id}/outs/barcoded.fastq.gz | paste - - - - - - - -  | tee >(cut -f 1-4 | tr "\t" "\n" | pigz --best --processes ${task.cpus} > ${id}.barcoded.R1.fastq.gz ) | cut -f 5-8 | tr "\t" "\n" | pigz --best --processes ${task.cpus} > ${id}.barcoded.R2.fastq.gz  
    """
}
*/
process quast {
    tag "${id}"
    publishDir "${params.outdir}/quast/${id}", mode: 'copy'

    input:
    set val(id), file(asm) from supernova_asm1

    output:
    file("*") into quast_results
 
    script:
    def size_parameter = params.genomesize!=null ? "--est-ref-size ${params.genomesize}" : "" 
    """
    quast.py -s ${size_parameter} --threads ${task.cpus} ${asm}
    mv quast_results/latest/* .
    rm -r quast_results
    """
}

process busco {
    tag "${id}"
    publishDir "${params.outdir}/busco/", mode: 'copy'

    input:
    set val(id), file(asm) from supernova_asm2

    output:
    file ("run_${id}/") into busco_results

    script:
    // If statement is only for UPPMAX HPC environments, it shouldn't mess up anything else
    """
    if ! [ -z \${BUSCO_SETUP+x} ]; then source \$BUSCO_SETUP; fi
    BUSCO.py -i ${asm} -o ${id} -c ${task.cpus} -m genome -l ${params.BUSCOdata}
    """
}

