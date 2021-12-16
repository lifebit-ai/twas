# TWAS pipeline

This pipeline performs transcriptome-wide association analysis using PTWAS software.

## Required inputs

Required inputs are:

- **gwas_summary_stats**: GWAS single-SNP z-scores in a bgzipped vcf file.

- **ld_reference_panel**: consists of a set of vcf files used for computing LD information. Default = 1000 Genomes project (phase 3 version 5).


## Optional inputs

- **PTWAS weights files**: used by PTWAS scan procedure to construct composite IVs, also known as the eQTL weights for burden test. Pre-computed weights file from 49 tissues in the GTEx project are used by default.


## Resources

http://sashagusev.github.io/2017-10/twas-vulnerabilities.html
