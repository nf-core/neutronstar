#!/usr/bin/env nextflow
/*
========================================================================================
                         nf-core/neutronstar
========================================================================================
 nf-core/neutronstar Analysis Pipeline.
 #### Homepage / Documentation
 https://github.com/nf-core/neutronstar
----------------------------------------------------------------------------------------
*/


def helpMessage() {
    log.info"""
    =========================================
     nf-core/neutronstar v${manifest.pipelineVersion}
    =========================================
    Usage:

    The typical command for running the pipeline is as follows:


    nextflow run -profile hpc,singularity nf-core/neutronstar --id assembly_id --fastqs fastq_path --genomesize 1000000

    Mandatory arguments:
      --id                          [Supernova parameter]
      --fastqs                      [Supernova parameter]
      --genomesize                  The estimated size of the genome(s) to be assembled. This is mainly used by Quast to compute NGxx statstics, e.g. N50 statistics bound by this value and not the assembly size.
      -profile                      Hardware config to use. docker / hpc
      --BUSCOdata                   The dataset BUSCO should use (e.g. eukaryota_odb9, protists_ensembl)

    Options:
      --sample                      [Supernova parameter]
      --lanes                       [Supernova parameter]
      --indices                     [Supernova parameter]
      --bcfrac                      [Supernova parameter]
      --project                     [Supernova parameter]
      --maxreads                    [Supernova parameter]
      --nopreflight                 [Supernova parameter]
      --minsize                     [Supernova mkdoutput parameter]
      --max_cpus                    Amount of cpu cores for the job scheduler to request. Supernova will use all of them. (default=16 for hpc config)
      --max_memory                  Amount of memory (in Gb) for the jobscheduler to request. Supernova will use all of it. (default=256 for hpc config)
      --max_time                    Amount of time for the job scheduler to request (in hours). (default=120)
      --full_output                 Keep all the files that are output from Supernova. By default only the final assembly graph is kept, as it is needed to make the output fasta files.
      --clusterOptions              The options to feed to the HPC job manager. For instance for SLURM --clusterOptions='-A project -C node-type'


    Other options:
      --outdir                      The output directory where the results will be saved
      --email                       Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits
      -name                         Name for the pipeline run. If not specified, the pipeline will automatically generate one from the uuid (i.e. nonsense).
      -params-file                  Give the arguments for this nextflow run as a structured JSON/YAML file
    """.stripIndent()
}

/*
 * SET UP CONFIGURATION VARIABLES
 */

// Show help emssage
params.help = false
if (params.help){
    helpMessage()
    exit 0
}


// Configurable variables
params.name = false
params.multiqc_config = "$baseDir/conf/multiqc_config.yaml"
params.email = false
params.plaintext_email = false

multiqc_config = file(params.multiqc_config)
output_docs = file("$baseDir/docs/output.md")
def buscoPath = "${params.BUSCOfolder}/${params.BUSCOdata}"

// NOTE - THIS IS NOT USED IN THIS PIPELINE, EXAMPLE ONLY
// If you want to use the above in a process, define the following:
//   input:
//   file fasta from fasta
//


// Has the run name been specified by the user?
//  this has the bonus effect of catching both -name and --name
custom_runName = params.name
if( !(workflow.runName ==~ /[a-z]+_[a-z]+/) ){
  custom_runName = workflow.runName
}
else {
  custom_runName = "supernova_assembly_${workflow.sessionId}"
}

// Check workDir/outdir paths to be S3 buckets if running on AWSBatch
// related: https://github.com/nextflow-io/nextflow/issues/813
if( workflow.profile == 'awsbatch') {
    if(!workflow.workDir.startsWith('s3:') || !params.outdir.startsWith('s3:')) exit 1, "Workdir or Outdir not on S3 - specify S3 Buckets for each to run on AWSBatch!"
}


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
assert new File(buscoPath).exists() : "Path not found ${buscoPath}"

// Header log info
log.info """=======================================================
                                          ,--./,-.
          ___     __   __   __   ___     /,-._.--~\'
    |\\ | |__  __ /  ` /  \\ |__) |__         }  {
    | \\| |       \\__, \\__/ |  \\ |___     \\`-._,-`-,
                                          `._,._,\'

nf-core/neutronstar v${params.pipelineVersion}"
======================================================="""
def summary = [:]
summary['Pipeline Name']  = 'nf-core/neutronstar'
summary['Pipeline Version'] = params.pipelineVersion
summary['Run Name']     = custom_runName ?: workflow.runName
summary['Fasta Ref']    = params.fasta
summary['Data Type']    = params.singleEnd ? 'Single-End' : 'Paired-End'
summary['Max Memory']   = params.max_memory
summary['Max CPUs']     = params.max_cpus
summary['Max Time']     = params.max_time
summary['Output dir']   = params.outdir
summary['Working dir']  = workflow.workDir
summary['Container Engine'] = workflow.containerEngine
if(workflow.containerEngine) summary['Container'] = workflow.container
summary['Current home']   = "$HOME"
summary['Current user']   = "$USER"
summary['Current path']   = "$PWD"
summary['Working dir']    = workflow.workDir
summary['Output dir']     = params.outdir
summary['Script dir']     = workflow.projectDir
summary['Config Profile'] = workflow.profile
if(workflow.profile == 'awsbatch'){
   summary['AWS Region'] = params.awsregion
   summary['AWS Queue'] = params.awsqueue
}
if(params.email) summary['E-mail Address'] = params.email
log.info summary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "========================================="


def create_workflow_summary(summary) {

    def yaml_file = workDir.resolve('workflow_summary_mqc.yaml')
    yaml_file.text  = """
    id: 'nf-core-neutronstar-summary'
    description: " - this information is collected when the pipeline is started."
    section_name: 'nf-core/neutronstar Workflow Summary'
    section_href: 'https://github.com/nf-core/neutronstar'
    plot_type: 'html'
    data: |
        <dl class=\"dl-horizontal\">
${summary.collect { k,v -> "            <dt>$k</dt><dd><samp>${v ?: '<span style=\"color:#999999;\">N/A</a>'}</samp></dd>" }.join("\n")}
        </dl>
    """.stripIndent()

   return yaml_file
}
for (i in samples) {
    log.info "  supernova run --id=${i[0]} --fastqs=${i[1]} ${i[2]} ${i[3]}"
}


Channel
    .from(samples)
    .set { supernova_input }


if (params.full_output) {
    process supernova_full {
        tag "${id}"
        publishDir "${params.outdir}/supernova/", mode: 'copy'

        input:
        set val(id), val(fastqs), val(tenx_options), val(supernova_options) from supernova_input

        output:
        set val(id), file("${id}/*") into supernova_results, supernova_results2

        script:
        """
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
        set val(id), file("${id}_supernova") into supernova_results, supernova_results2

        script:
        """
        supernova run --id=${id} --fastqs=${fastqs} ${tenx_options} ${supernova_options}
        rsync -rav --include="_*" --include="*.tgz" --include="outs/" --include="outs/*.*"  --include="assembly/" --include="stats/***" --include="logs/***" --include="a.base/" --include="a.base/" --include="a.hbx" --include="a.inv" --include="final/***" --include="gang" --include="micro"  --include="a.hbx" --include="a.inv" --include="final/***" --exclude="*" "${id}/" ${id}_supernova
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
    supernova mkoutput --asmdir=${id}_supernova/outs/assembly --outprefix=${id} --style=pseudohap --minsize=${params.minsize}
    supernova mkoutput --asmdir=${id}_supernova/outs/assembly --outprefix=${id}.phased --style=megabubbles --minsize=${params.minsize}
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

    script:
    def size_parameter = params.genomesize!=null ? "--est-ref-size ${params.genomesize}" : ""
    """
    quast.py ${size_parameter} --threads ${task.cpus} ${asm}
    """
}


process busco {
    tag "${id}"
    publishDir "${params.outdir}/busco/", mode: 'copy'

    input:
    set val(id), file(asm) from supernova_asm2
    env AUGUSTUS_CONFIG_PATH from "\$PWD/augustus_config"

    output:
    file ("run_${id}/*.{txt,tsv}") into busco_results

    script:
    // If statement is only for UPPMAX HPC environments, it shouldn't mess up anything else
    """
    tar xfj $baseDir/misc/augustus_config.tar.bz2
    if ! [ -z \${BUSCO_SETUP+x} ]; then source \$BUSCO_SETUP; fi
    run_BUSCO.py -i ${asm} -o ${id} -c ${task.cpus} -m genome -l ${buscoPath}
    """
}

process supernova_version {

    output:
    file("v_supernova.txt") into v_supernova

    script:
    """
    supernova run --version > v_supernova.txt
    """

}

process software_versions {

    input:
      file "v_supernova.txt" from v_supernova
    output:
      file 'software_versions_mqc.yaml' into software_versions_yaml

    script:
    """
    echo $params.pipelineVersion > v_pipeline.txt
    echo $workflow.nextflow.version > v_nextflow.txt
    quast.py -v &> v_quast.txt
    multiqc --version > v_multiqc.txt
    run_BUSCO.py -v > v_busco.txt
    scrape_software_versions.py > software_versions_mqc.yaml
    """
}

process multiqc {
    publishDir "${params.outdir}/multiqc", mode: 'copy'

    input:
    file ('supernova/') from supernova_results2.collect()
    file ('busco/') from busco_results.collect()
    file ('quast/*') from quast_results.collect()
    file ('software_versions/') from software_versions_yaml.toList()

    output:
    file "*multiqc_report.html"
    file "*_data"

    script:
    """
    multiqc -i ${custom_runName} -f -s  --config ${params.mqc_config} .
    """
}


/*
 * Completion e-mail notification
 */
workflow.onComplete {

    // Set up the e-mail variables
    def subject = "[nf-core/neutronstar] Successful: $workflow.runName"
    if(!workflow.success){
      subject = "[nf-core/neutronstar] FAILED: $workflow.runName"
    }
    def email_fields = [:]
    email_fields['version'] = params.pipelineVersion
    email_fields['runName'] = custom_runName ?: workflow.runName
    email_fields['success'] = workflow.success
    email_fields['dateComplete'] = workflow.complete
    email_fields['duration'] = workflow.duration
    email_fields['exitStatus'] = workflow.exitStatus
    email_fields['errorMessage'] = (workflow.errorMessage ?: 'None')
    email_fields['errorReport'] = (workflow.errorReport ?: 'None')
    email_fields['commandLine'] = workflow.commandLine
    email_fields['projectDir'] = workflow.projectDir
    email_fields['summary'] = summary
    email_fields['summary']['Date Started'] = workflow.start
    email_fields['summary']['Date Completed'] = workflow.complete
    email_fields['summary']['Pipeline script file path'] = workflow.scriptFile
    email_fields['summary']['Pipeline script hash ID'] = workflow.scriptId
    if(workflow.repository) email_fields['summary']['Pipeline repository Git URL'] = workflow.repository
    if(workflow.commitId) email_fields['summary']['Pipeline repository Git Commit'] = workflow.commitId
    if(workflow.revision) email_fields['summary']['Pipeline Git branch/tag'] = workflow.revision
    email_fields['summary']['Nextflow Version'] = workflow.nextflow.version
    email_fields['summary']['Nextflow Build'] = workflow.nextflow.build
    email_fields['summary']['Nextflow Compile Timestamp'] = workflow.nextflow.timestamp

    // Render the TXT template
    def engine = new groovy.text.GStringTemplateEngine()
    def tf = new File("$baseDir/assets/email_template.txt")
    def txt_template = engine.createTemplate(tf).make(email_fields)
    def email_txt = txt_template.toString()

    // Render the HTML template
    def hf = new File("$baseDir/assets/email_template.html")
    def html_template = engine.createTemplate(hf).make(email_fields)
    def email_html = html_template.toString()

    // Render the sendmail template
    def smail_fields = [ email: params.email, subject: subject, email_txt: email_txt, email_html: email_html, baseDir: "$baseDir" ]
    def sf = new File("$baseDir/assets/sendmail_template.txt")
    def sendmail_template = engine.createTemplate(sf).make(smail_fields)
    def sendmail_html = sendmail_template.toString()

    // Send the HTML e-mail
    if (params.email) {
        try {
          if( params.plaintext_email ){ throw GroovyException('Send plaintext e-mail, not HTML') }
          // Try to send HTML e-mail using sendmail
          [ 'sendmail', '-t' ].execute() << sendmail_html
          log.info "[nf-core/neutronstar] Sent summary e-mail to $params.email (sendmail)"
        } catch (all) {
          // Catch failures and try with plaintext
          [ 'mail', '-s', subject, params.email ].execute() << email_txt
          log.info "[nf-core/neutronstar] Sent summary e-mail to $params.email (mail)"
        }
    }

    // Write summary e-mail HTML to a file
    def output_d = new File( "${params.outdir}/Documentation/" )
    if( !output_d.exists() ) {
      output_d.mkdirs()
    }
    def output_hf = new File( output_d, "pipeline_report.html" )
    output_hf.withWriter { w -> w << email_html }
    def output_tf = new File( output_d, "pipeline_report.txt" )
    output_tf.withWriter { w -> w << email_txt }

    log.info "[nf-core/neutronstar] Pipeline Complete"

}
