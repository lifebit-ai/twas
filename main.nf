#!/usr/bin/env nextflow

def helpMessage() {
    log.info """
    Usage:
    The typical command for running the pipeline is as follows:
    nextflow run main.nf --bams sample.bam [Options]
    
    Inputs Options:
    --input         Input file

    Resource Options:
    --max_cpus      Maximum number of CPUs (int)
                    (default: $params.max_cpus)  
    --max_memory    Maximum memory (memory unit)
                    (default: $params.max_memory)
    --max_time      Maximum time (time unit)
                    (default: $params.max_time)
    See here for more info: https://github.com/lifebit-ai/hla/blob/master/docs/usage.md
    """.stripIndent()
}

// Show help message
if (params.help) {
  helpMessage()
  exit 0
}

// Define channels from repository files
projectDir = workflow.projectDir
ch_run_sh_script = Channel.fromPath("${projectDir}/bin/run.sh")


if (params.gwas_summary_statistics){
    Channel
    .fromPath("${params.gwas_summary_statistics}")
    .ifEmpty { exit 1, "GWAS summary statistics file not found: ${params.gwas_summary_statistics}" }
    .map {gwas_sumstats -> [ gwas_sumstats, gwas_sumstats+".tbi" ] }
    .set { ch_gwas_sumstats }
}



// Define Process
process ptwas_scan {
    tag "ptwas_scan"
    label 'low_memory'
    publishDir "${params.outdir}", mode: 'copy'

    input:
    set file(vcf_sumstats), file(vcf_sumstats_index) from ch_gwas_sumstats
    
    output:
    file "input_file_head.txt" into ch_out

    script:
    """
  echo "hello" > input_file_head.txt
    """
  }

// process report {
//     publishDir "${params.outdir}/MultiQC", mode: 'copy'

//     input:
//     file (table) from ch_out
    
//     output:
//     file "multiqc_report.html" into ch_multiqc_report

//     script:
//     """
//     cp -r ${params.report_dir}/* .
//     Rscript -e "rmarkdown::render('report.Rmd',params = list(res_table='$table'))"
//     mv report.html multiqc_report.html
//     """
// }
