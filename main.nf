#!/usr/bin/env nextflow

def helpMessage() {
    log.info """
    Usage:
    The typical command for running the pipeline is as follows:
    nextflow run main.nf --gwas_summary_statistics gwas_summary.csv [Options]
    
    Inputs Options:
    --gwas_summary_statistics        Path to input GWAS summary statistics file.
    --ld_reference_panel             Path to LD reference panel.
    
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
    .set { ch_gwas_sumstats }
}


if (params.ld_reference_panel){
    Channel
    .fromPath("${params.ld_reference_panel}")
    .ifEmpty { exit 1, "File with LD reference panel not found: ${params.ld_reference_panel}" }
    .set { ch_ld_reference }
}

if (params.eqtl_weights){
    Channel
    .fromPath("${params.eqtl_weights}")
    .ifEmpty { exit 1, "File with eQTL weights not found: ${params.eqtl_weights}" }
    .set { ch_eqtl_weights }
}



// Define Process
process ptwas_scan {
    tag "ptwas_scan"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    set file(vcf_sumstats), file(vcf_sumstats_index) from ch_gwas_sumstats
    file(ld_reference_panel) from ch_ld_reference
    file(eqtl_weights) from ch_eqtl_weights
    
    output:
    set file("*stratified_out.txt"), file("*summary_out.txt") into ch_gambit_output

    script:
    """
    tar xvzf ${ld_reference_panel}
    tabix -p vcf -f ${eqtl_weights}
    tabix -p vcf -f ${vcf_sumstats}
    ${params.gambit_exec_path} --gwas ${vcf_sumstats} --betas ${eqtl_weights} --ldref G1K_EUR_3V5/chr*.vcf.gz --ldref-only 
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
