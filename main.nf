#!/usr/bin/env nextflow
/*
vim: syntax=groovy
-*- mode: groovy;-*-
*/


//##### Parameters
version = 0.1
def p = params
p.genomesize = 0
p.id = ''
p.fastqs = ''
p.sample = ''
p.maxreads = 0
p.bcfrac = 0
p.outdir="."
p.BUSCOdata = "$BUSCO_LINEAGE_SETS/eukaryota_odb9"
def supernova_optional = {->
    def str = ""
    if (p.sample != "") {str <<= "--sample={$p.sample} "}
    if (p.maxreads > 0) {str <<= "--maxreads=${p.maxreads} "}
    if (p.bcfrac > 0 ) {str <<= "--bcfrac=${p.bcfrac} "}
    return str
}

//###### Start
log.info "     \\|/"
log.info "  ----*----   N e u t r o n S t a r (${version})"
log.info "     /|\\" 
log.info "  supernova run --id=${p.id} --fastqs=${p.fastqs} ${supernova_optional()} "
log.info "  outdir = ${p.outdir}"

Channel
    .value([p.id, p.fastqs])
    .into { supernova_input; longranger_input }

process supernova {
    tag "${id}"
    publishDir "${p.outdir}/supernova/", mode: 'copy'

    input:
    set val(id), val(fastqs) from supernova_input

    output:
    set val(id), file("${id}") into supernova_results

    script:
    def mem = Math.round(task.memory.toBytes() / 1024 / 1024 / 1024)
    """
    supernova run --id=${id}_stage --fastqs=${fastqs} --localcores=${task.cpus} --localmem=${mem} ${supernova_optional()}
    rsync -rav --include="_*" --include="*.tgz" --include="outs/" --include="outs/*.*"  --include="assembly/" --include="stats/***" --include="logs/***" --include="a.base/" --include="a.hbx" --include="a.inv" --include="final/***" --exclude="*" "${id}_stage/" ${id}
    """
}

process mkoutput {
    tag "${id}"
    publishDir "${p.outdir}/assemblies/", mode: 'copy'

    input:
    set val(id), file(supernova_folder) from supernova_results

    output:
    set val(id), file("${id}.supernova.scf.fasta") into supernova_asm

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
    publishDir "${p.outdir}/align/${id}", mode: 'copy'

    input:
    set val(id), val(fastqs) from longranger_input

    output:
    set val(id), file("${id}.barcoded.R[12].fastq.gz") into longranger_fastq
    
    script:
    def mem = Math.round(task.memory.toBytes() / 1024 / 1024 / 1024)
    """
    longranger basic --id=${id} --fastqs=${fastqs} --localcores=${task.cpus} --localmem=${mem} ${supernova_optional()}
    pigz -d -c --processes ${task.cpus} ${id}/outs/barcoded.fastq.gz | paste - - - - - - - -  | tee >(cut -f 1-4 | tr "\t" "\n" | pigz --best --processes ${task.cpus} > ${id}.barcoded.R1.fastq.gz ) | cut -f 5-8 | tr "\t" "\n" | pigz --best --processes ${task.cpus} > ${id}.barcoded.R2.fastq.gz  
    """
}
*/

process quast {
    tag "${id}"
    publishDir "${p.outdir}/quast/${id}", mode: 'copy'

    input:
    set val(id), file(asm) from supernova_asm

    output:
    file("*") into quast_results
 
    script:
    def size_parameter = p.genomesize>0 ? "--est-ref-size ${p.genomesize}" : "" 
    """
    quast.py -s ${size_parameter} --threads ${task.cpus} ${asm}
    mv quast_results/latest/* .
    rm -r quast_results
    """
}

process busco {
    tag "${id}"
    publishDir "${p.outdir}/busco/", mode: 'copy'

    beforeScript 'source $BUSCO_SETUP'

    input:
    set val(id), file(asm) from supernova_asm

    output:
    file ("run_${id}/") into busco_results

    script:
    """
    BUSCO.py -i ${asm} -o ${id} -c ${task.cpus} -m genome -l ${p.BUSCOdata}
    """
}

