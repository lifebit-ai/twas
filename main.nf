#!/usr/bin/env nextflow

def helpMessage() {
    log.info """
    Usage:
    The typical command for running the pipeline is as follows:
    nextflow run main.nf --gwas_summary_statistics gwas_summary.tsv.gz [Options]
    
    Inputs Options:
    --gwas_summary_statistics        Path to input GWAS summary statistics file.
    --ld_reference_panel             Path to LD reference panel.
    --eqtl_weights                   Path to eQTL weights.
    
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
ch_calculate_z_script = Channel.fromPath("${projectDir}/bin/calculate_z.py")


if (params.gwas_summary_statistics){
    Channel
        .fromPath("${params.gwas_summary_statistics}")
        .ifEmpty { exit 1, "GWAS summary statistics file not found: ${params.gwas_summary_statistics}" }
        .set { ch_gwas_sumstats }
    if (params.gwas_summary_statistics.endsWith(".vcf.gz") || params.gwas_summary_statistics.endsWith(".vcf")) {
        vcf = true
    } else {
        vcf = false
        ch_gwas_sumstats.set{ ch_transformed_gwas_vcf }
    }

}

if (params.annotate_vcf) {
    Channel
    .fromPath("${params.gene_annotations}")
    .ifEmpty { exit 1, "File with gene annotations not found: ${params.gene_annotations}" }
    .set { ch_gene_annotations }

    Channel
    .fromPath("${params.codons}")
    .ifEmpty { exit 1, "File with codons not found: ${params.codons}" }
    .set { ch_codon_file }

    Channel
    .fromPath("${params.priority_file}")
    .ifEmpty { exit 1, "Priority file not found: ${params.priority_file}" }
    .set { ch_priority_file }

    Channel
        .fromPath("${params.ref_fasta}")
        .ifEmpty { exit 1, "Reference genome not found: ${params.ref_fasta}" }
        .set { ch_ref_fasta }
    Channel
        .fromPath("${params.ref_fasta_index}")
        .ifEmpty { exit 1, "Reference genome index not found: ${params.ref_fasta_index}" }
        .set { ch_ref_fasta_index }
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

if (vcf) {
    process transform_gwas_vcf {
        tag "transform_gwas_vcf"
        publishDir "${params.outdir}", mode: 'copy'

        input:
        file(gwas_vcf) from ch_gwas_sumstats
        each file(calculate_z_script) from ch_calculate_z_script
        output:
        file("transformed_gwas_vcf.txt.gz") into (ch_transformed_gwas_vcf, ch_transformed_gwas_vcf_annot)
        script:
        """
        echo "#CHR POS REF ALT SNP_ID BETA SE P" > temp.txt
        bcftools query -f'chr%CHROM %POS %REF %ALT [%SNP] [%BETA] [%SE] [%P]\n' $gwas_vcf >> temp.txt
        # Generating the N column
        echo "N" > n_col.txt
        for i in \$(seq 2 `wc -l < temp.txt`); do
            echo $params.gwas_sample_size >> n_col.txt
        done
        paste -d " " temp.txt n_col.txt > base.data
        python3 $calculate_z_script -i base.data -o transformed_gwas_vcf.txt
        bgzip transformed_gwas_vcf.txt
        """

    }
    if (params.annotate_vcf) {
        process add_annotations {
            tag "annotate"
            publishDir "${params.outdir}", mode: 'copy'

            input:
            file(vcf_sumstats) from ch_transformed_gwas_vcf_annot
            file(ref_fasta) from ch_ref_fasta
            file(ref_fasta_index) from ch_ref_fasta_index
            file(gene_annotations) from ch_gene_annotations
            file(codon_file) from ch_codon_file
            file(priority_file) from ch_priority_file
    
            output:
            file("annotated.txt.gz") into ch_annot_transformed_gwas
            file("add_annotations.log")
            script:
            """
            /anno/anno -i $vcf_sumstats -g $gene_annotations -o annotated --inputFormat plain -c $codon_file -p $priority_file -r $ref_fasta 2>&1 | tee -a add_annotations.log
            echo "#CHR\tPOS\tREF\tALT\tSNP_ID\tN\tZSCORE\tANNO" > annotated.txt
            tail -n +2 annotated | cut -f1-8 >> annotated.txt
            bgzip -c annotated.txt > annotated.txt.gz
            """

        }
    }
}

ch_ptwas_gwas_sumstats = params.annotate_vcf ? ch_annot_transformed_gwas : ch_transformed_gwas_vcf

process ptwas_scan {
    tag "ptwas_scan"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    file(vcf_sumstats) from ch_ptwas_gwas_sumstats
    file(ld_reference_panel) from ch_ld_reference
    file(eqtl_weights) from ch_eqtl_weights
    
    output:
    set file("*stratified_out.txt"), file("*summary_out.txt") into ch_gambit_output
    file("ptwas_scan.log")

    script:
    """
    tar xvzf ${ld_reference_panel}
    tabix -p vcf -f ${eqtl_weights}
    tabix -p vcf -f ${vcf_sumstats}
    ${params.gambit_exec_path} --gwas ${vcf_sumstats} --betas ${eqtl_weights} --ldref G1K_EUR_3V5/chr*.vcf.gz --ldref-only 2>&1 | tee -a ptwas_scan.log
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
