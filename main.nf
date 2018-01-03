#!/usr/bin/env nextflow
/*
vim: syntax=groovy
-*- mode: groovy;-*-
*/


//##### Functions

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
def supernova_optional = {maxreads, bcfrac, nopreflight->
    def str = ""
    maxreads!=null ? str <<= "--maxreads=${maxreads} " : null
    bcfrac!=null ? str <<= "--bcfrac=${bcfrac} " : null
    nopreflight!=null ? str << "--nopreflight " : null
    return str
}


//##### Parameters
params.outdir="."
params.fastqc = false
params.mqc_config = "$baseDir/misc/multiqc_config.yaml"
params.minsize = 1000
params.assembly_project = "supernova_assembly_${workflow.sessionId}"
params.full_output = false

samples = []
if (params.samples == null) { //We don't have sample JSON/YAML file, just use cmd-line
    assert params.id != null : "Missing --id option"
    assert params.fastqs != null : "Missing --fastqs option"
    s = []
    s << params.id
    s << params.fastqs
    s << TenX_optional(params.sample, params.lanes, params.indices, params.project)
    s << supernova_optional(params.maxreads, params.bcfrac, params.nopreflight)
    samples << s
}

params.samples = []

for (sample in params.samples) { 
    assert sample.id != null : "Error in input parameter file"
    assert sample.fastqs != null : "Error in input parameter file"
    s = []
    s << sample.id
    s << sample.fastqs
    s << TenX_optional(sample.sample, sample.lanes, sample.indices, sample.project)
    s << supernova_optional(sample.maxreads, sample.bcfrac, sample.nopreflight)
    samples << s  
}

//Extra parameter evaluation
for (sample in params.samples) {
    assert sample.id.size() == sample.id.findAll(/[A-z0-9\\.\-]/).size() : "Illegal character(s) in sample ID: ${sample.id}."
    assert new File(sample.fastqs).exists() : "Path not found ${sample.fastqs}"
}
assert new File(params.BUSCOdata).exists() : "Path not found ${params.BUSCOdata}"

//###### Start
version = 0.4

log.info "     \\|/"
log.info "  ----*----   N e u t r o n S t a r (${version})"
log.info "     /|\\      run: ${params.assembly_project}"
log.info ""

for (i in samples) {  
    log.info "  supernova run --id=${i[0]} --fastqs=${i[1]} ${i[2]} ${i[3]}"
}
log.info "  outdir = ${params.outdir}"

Channel
    .from(samples)
    .into { supernova_input; longranger_input }


// Note: Defunct for now
process longranger {
    tag "${id}"
    publishDir "${params.outdir}/align/", mode: 'copy'
    
    when:
    params.fastqc

    input:
    set val(id), val(fastqs), val(tenx_options), val(supernova_options) from longranger_input

    output:
    set val(id), file("${id}.fastq.gz") into fastqc_input
    
    script:
    """
    longranger basic --id=${id} --fastqs=${fastqs} --localcores=${task.cpus} ${tenx_options}
    mv ${id}/outs/barcoded.fastq.gz ${id}.fastq.gz
    """
}

// Note: Defunct for now
process fastqc {
    tag "${id}"
    publishDir "${params.outdir}/fastqc/", mode: 'copy'

    when:
    params.fastqc

    input:
    set val(id), val(fastq) from fastqc_input

    output:
    file "*_fastqc.{zip,html}" into fastqc_results

    script:
    """
    fastqc -o . -q $fastq
    """
}

if (params.full_output) {
    process supernova {
        tag "${id}"
        publishDir "${params.outdir}/supernova/", mode: 'copy'

        input:
        set val(id), val(fastqs), val(tenx_options), val(supernova_options) from supernova_input

        output:
        set val(id), file("${id}/*") into supernova_results, supernova_results2
        file "v_supernova.txt" into v_supernova

        script:
        """
        supernova run --version > v_supernova.txt
        supernova run --id=${id} --fastqs=${fastqs} ${tenx_options} ${supernova_options}
        """
    }

}else {
    process supernova {
        tag "${id}"
        publishDir "${params.outdir}/supernova/", mode: 'copy'

        input:
        set val(id), val(fastqs), val(tenx_options), val(supernova_options) from supernova_input

        output:
        set val(id), file("{${id}/_*,${id}/*.tgz,${id}/outs,${id}/outs/*.*,${id}/outs/assembly/stats,${id}/outs/assembly/logs,${id}/outs/assembly/a.base/a.hbx,${id}/outs/assembly/a.base/a.inv,${id}/outs/assembly/a.base/final}") into supernova_results, supernova_results2
        file "v_supernova.txt" into v_supernova

        script:
        """
        supernova run --version > v_supernova.txt
        supernova run --id=${id} --fastqs=${fastqs} ${tenx_options} ${supernova_options}
        """
    }


}

process mkoutput {
    tag "${id}"
    publishDir "${params.outdir}/assemblies/", mode: 'copy'

    input:
    set val(id), file(supernova_folder) from supernova_results

    output:
    set val(id), file("${id}.fasta") into supernova_asm1, supernova_asm2
    file "${id}.phased.fasta"

    script:
    """
    supernova mkoutput --asmdir=outs/assembly --outprefix=${id} --style=pseudohap --minsize=${params.minsize}
    supernova mkoutput --asmdir=outs/assembly --outprefix=${id}.phased --style=megabubbles --minsize=${params.minsize}
    gzip -d ${id}.fasta.gz
    gzip -d ${id}.phased.fasta.gz
    """
}

process quast {
    tag "${id}"
    publishDir "${params.outdir}/quast/${id}", mode: 'copy'

    input:
    set val(id), file(asm) from supernova_asm1

    output:
    file("quast_results/latest/*") into quast_results
    file("v_quast.txt") into v_quast
 
    script:
    def size_parameter = params.genomesize!=null ? "--est-ref-size ${params.genomesize}" : "" 
    """
    quast.py -v > v_quast.txt
    quast.py ${size_parameter} --threads ${task.cpus} ${asm}
    """
}

process busco {
    tag "${id}"
    publishDir "${params.outdir}/busco/", mode: 'copy'

    input:
    set val(id), file(asm) from supernova_asm2

    output:
    file ("run_${id}/") into busco_results
    file "v_busco.txt" into v_busco

    script:
    // If statement is only for UPPMAX HPC environments, it shouldn't mess up anything else
    """
    if ! [ -z \${BUSCO_SETUP+x} ]; then source \$BUSCO_SETUP; fi
    BUSCO.py -v > v_busco.txt
    BUSCO.py -i ${asm} -o ${id} -c ${task.cpus} -m genome -l ${params.BUSCOdata}
    """
}

process software_versions {

    publishDir "${params.outdir}"
    input:
        file busco from v_busco
        file quast from v_quast
        file supernova from v_supernova
    output:
        file("versions.txt")
    script:
    """
    cat ${busco} ${quast} ${supernova} > versions.txt
    """

}

process multiqc {
    publishDir "${params.outdir}/multiqc"

    input:
    file ('fastqc/*') from fastqc_results.flatten().toList()
    file ('supernova/*') from supernova_results2.flatten().toList()
    file ('busco/*') from busco_results.flatten().toList()
    file ('quast/*') from quast_results.flatten().toList()

    output:
    file "*multiqc_report.html"
    file "*_data"

    script:
    """
    multiqc -i ${params.assembly_project} -f -s -m fastqc -m supernova -m busco -m quast --config ${params.mqc_config} .
    """    
}



