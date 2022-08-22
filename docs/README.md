# twas

## Overview

This pipeline performs transcriptome-wide association analysis using PTWAS/GAMBIT software to investigate causal relationships between gene expressions and complex traits. For this, the following inputs are _required_:

## Required parameters

- **`--gwas_summary_statistics`** : Path to file containing GWAS summary statistics (in [GWAS VCF](https://github.com/MRCIEU/gwas-vcf-specification) format) 

- **`--gwas_sample_size`** : Sample size of GWAS study.

## Optional parameters

- **`--ld_reference_panel`** : LD reference panel. Default = 1000Genomes phase 3 EUR LD panel.

- **`--eqtl_weights`** : eQTL weights. Default = eQTL weights provided in [ptwas resources](https://drive.google.com/drive/folders/16wfZhTJrbHS0HVGVLbDFOTzl8dpcqicr).

> N.B. The default reference files are provided in _hg38_ build.

- **`--annotate_vcf`** : If the GWAS summary statistics do not contain annotations in `ANNO` column, [TabAnno](https://github.com/zhanxw/anno) is run to generate variant-level annotations in `ANNO` column. An example of running a pipeline with TabAnno annotation switched on:
```
nextflow run main.nf --config conf/test_vcf.config --annotate_vcf -with-docker
```

- **`--gene_annotations`** : File with gene annotations in refFlat format (default=`refFlat.txt.gz` from UCSC)

- **`--codons`** : Human Codon file.

- **`--priority_file`** : File determining the priority of annotations.

- **`--ref_fasta`** : Reference genome in FASTA format.

- **`--ref_fasta_index`** : Corresponding reference genome index in .fai format.

> The annotation-specific parameters have default files which are adapted from reference files provided by [TabAnno](http://zhanxw.github.io/anno/).


- **`--med_memory`** : Memory (in GB) allocated for `transform_gwas_vcf` and `add_annotations` processes. Default = `6.GB`.

# Input

The main input of the pipeline is a file supplied via `--gwas_summary_statistics` containing harmonised GWAS summary statistics in GWAS VCF format. 

Example of input file:

```
##trait=<background_source_origin="NA">
##trait=<background_source_concept_code="NA">
##trait=<background_source_vocabulary="NA">
##trait=<background_source_concept_id="NA">
##trait=<background_source_concept_name="NA">
##trait=<background_concept_id="NA">
##trait=<background_concept_code="NA">
##trait=<background_concept_name="NA">
##trait=<background_vocabulary="NA">
##trait=<background_domain_name="NA">
##trait=<background_concept_class_name="NA">
##trait=<background_standard_concept="NA">
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  GWAS
1       785910  .       G       C       .       .       .       SNP:BETA:FRQ:SE:P:STD_BETA:STD_BETA_SE:OR_      rs12565286:0.1632:0.0609:0.2577:0.5
266:0.002836:0.004479:1.344486
1       788439  .       T       A       .       .       .       SNP:BETA:FRQ:SE:P:STD_BETA:STD_BETA_SE:OR_      rs11804171:0.141:0.0611:0.2581:0.58
48:0.002451:0.004486:1.291424
1       788511  .       G       C       .       .       .       SNP:BETA:FRQ:SE:P:STD_BETA:STD_BETA_SE:OR_      rs2977670:-0.15:0.9379:0.2696:0.577
9:-0.002607:0.004686:0.761801
```

Essential columns in GWAS VCF are:

- `CHR`
- `POS`
- `REF`
- `ALT`
- `SNP_ID`
- `BETA`
- `SE`
- `P`

# Processes

## Default

- **`transform_gwas_vcf`**: Transform GWAS VCF into a format suitable for ptwas.

- **`add_annotations`**: Append variant-level annotations using TabAnno.

- **`ptwas_scan`**: TWAS analysis.



# Output

Main outputs in `results` folder are:

- **`transformed_gwas_vcf.txt.gz`**: Transformed file containing GWAS summary statistics with `ZSCORE` calculated.

- **`annotated.txt.gz`**: GWAS summary statistics post-annotation with `ANNO` annotation column present.

- **`annotated.stratified_out.txt`**: Association tests for each gene-tissue pair.

```
#CHR    POS     GENE    CLASS   SUBCLASS        NSNPS   STAT    PVAL    INFO
chr1    785910-788511   ENSG00000237491.8       eQTL    Adipose_Subcutaneous    1       0.633295        5.2654e-01      OK
chr1    785910-785910   ENSG00000237491.8       eQTL    Adipose_Visceral_Omentum        1       0.633295        5.2654e-01      OK
chr1    788439-788511   ENSG00000237491.8       eQTL    Adrenal_Gland   1       0.556380        5.7795e-01      OK
chr1    785910-788511   ENSG00000237491.8       eQTL    Artery_Aorta    1       0.633295        5.2654e-01      OK
chr1    785910-785910   ENSG00000237491.8       eQTL    Artery_Coronary 1       0.633295        5.2654e-01      OK
chr1    785910-788439   ENSG00000237491.8       eQTL    Artery_Tibial   1       0.633295        5.2654e-01      OK
chr1    785910-863579   ENSG00000237491.8       eQTL    Brain_Amygdala  1       0.633295        5.2654e-01      OK
```
- **`annotated.summary_out.txt`**:  Gene-based p-values (aggregating across all tisuues for each gene).

```
#CHR	POS	GENE	N_SNPS	N_CLASSES	TOP_CLASS	TOP_SUBCLASS	MIN_UNADJ_PVAL	NAIVE_PVAL	PVAL
chr1	785910-863579	ENSG00000237491.8	6	E=48,R=0,O=0	eQTL	Adipose_Subcutaneous,Adipose_Visceral_Omentum,Artery_Aorta,Artery_Coronary,Artery_Tibial,Brain_Amygdala,Brain_Anterior_cingulate_cortex_BA24,Brain_Caudate_basal_ganglia,Brain_Cerebellar_Hemisphere,Brain_Cerebellum,Brain_Cortex,Brain_Frontal_Cortex_BA9,Brain_Hippocampus,Brain_Hypothalamus,Brain_Nucleus_accumbens_basal_ganglia,Brain_Putamen_basal_ganglia,Brain_Spinal_cord_cervical_c-1,Breast_Mammary_Tissue,Cells_Cultured_fibroblasts,Cells_EBV-transformed_lymphocytes,Colon_Sigmoid,Colon_Transverse,Esophagus_Gastroesophageal_Junction,Esophagus_Mucosa,Esophagus_Muscularis,Heart_Atrial_Appendage,Heart_Left_Ventricle,Liver,Lung,Minor_Salivary_Gland,Muscle_Skeletal,Nerve_Tibial,Ovary,Pancreas,Pituitary,Prostate,Skin_Not_Sun_Exposed,Skin_Sun_Exposed,Small_Intestine_Terminal_Ileum,Spleen,Stomach,Thyroid,Uterus,Vagina,Whole_Blood	5.265e-01	1.000e+00	6.133e-01	OK
chr1	785910-863579	ENSG00000230092.7	17	E=35,R=0,O=0	eQTL	Adipose_Subcutaneous,Adipose_Visceral_Omentum,Adrenal_Gland,Artery_Aorta,Artery_Coronary,Artery_Tibial,Breast_Mammary_Tissue,Colon_Transverse,Esophagus_Gastroesophageal_Junction,Esophagus_Mucosa,Esophagus_Muscularis,Heart_Atrial_Appendage,Lung,Minor_Salivary_Gland,Muscle_Skeletal,Pancreas,Prostate,Skin_Not_Sun_Exposed,Skin_Sun_Exposed,Small_Intestine_Terminal_Ileum,Spleen,Stomach	5.265e-01	1.000e+00	6.126e-01	OK
chr1	785910-863579	ENSG00000228327.3	17	E=25,R=0,O=0	eQTL	Adipose_Subcutaneous,Artery_Aorta,Artery_Coronary,Cells_Cultured_fibroblasts,Esophagus_Mucosa,Heart_Left_Ventricle,Nerve_Tibial,Prostate	5.265e-01	1.000e+00	6.106e-01	OK
chr1	785910-1516000	ENSG00000177757.2	22	E=40,R=0,O=0	eQTL	Adipose_Subcutaneous,Adipose_Visceral_Omentum,Artery_Aorta,Artery_Tibial,Breast_Mammary_Tissue,Esophagus_Muscularis,Heart_Left_Ventricle,Minor_Salivary_Gland,Prostate,Small_Intestine_Terminal_Ileum,Spleen	5.265e-01	1.000e+00	6.137e-01	OK
```

# Tools used

- [TabAnno](https://github.com/zhanxw/anno): `v1.0`
- [ptwas/GAMBIT](https://github.com/corbinq/GAMBIT): `v0.2`
- [bcftools](https://samtools.github.io/bcftools/bcftools.html): `7cd83b7`

# Usage

Inside the folder [conf/](../conf) pre-curated configurations of parameters to execute the pipeline in different modes are provided.
Every configuration file can be run, from the root of the local clone of the repository, using one of the following commands.

> NOTE: Adding `-with-docker` or `-with-singularity` is required because all of the dependencies are used from the containers.

## Running with Docker

```bash
nextflow run main.nf --config conf/<any-config> -with-docker
```
Example using config only:

```bash
nextflow run main.nf --config conf/test_small_vcf.config  -with-docker
```

Example using config and overriding value supplied via `--gwas_summary_statistics` paremeter to run with different GWAS summary statistics as input:

```bash
nextflow run main.nf --config conf/test_small_vcf.config --gwas_summary_statistics s3://lifebit-featured-datasets/pipelines/prs/testdata/GCST001969_fully_harmonised_sumstats.vcf -with-docker
```

## Running with Singularity

```bash
nextflow run main.nf --config conf/<any-config> -with-singularity
```
Example:

```bash
nextflow run main.nf --config conf/test_small_vcf.config -with-singularity
```

## Example configurations for testing specific modes of the pipeline


### TWAS using PTWAS

```bash
nextflow run main.nf --config conf/test_small_vcf.config -with-docker
nextflow run main.nf --config conf/test_small_vcf.config -with-singularity
```


<details>
<summary>Expected output:</summary>


```
tree -fh results/

├── [1.9K]  results/add_annotations.log
├── [804K]  results/annotated.stratified_out.txt
├── [ 79K]  results/annotated.summary_out.txt
├── [377K]  results/annotated.txt.gz
├── [ 36K]  results/ptwas_scan.log
└── [350K]  results/transformed_gwas_vcf.txt.gz

0 directories, 6 files
```

</details>
<br>


<details>
<summary>Format of main outputs:</summary>

```
head results/annotated.stratified_out.txt
#CHR    POS     GENE    CLASS   SUBCLASS        NSNPS   STAT    PVAL    INFO
chr1    785910-788511   ENSG00000237491.8       eQTL    Adipose_Subcutaneous    1       0.633295        5.2654e-01      OK
chr1    785910-785910   ENSG00000237491.8       eQTL    Adipose_Visceral_Omentum        1       0.633295        5.2654e-01      OK
chr1    788439-788511   ENSG00000237491.8       eQTL    Adrenal_Gland   1       0.556380        5.7795e-01      OK
chr1    785910-788511   ENSG00000237491.8       eQTL    Artery_Aorta    1       0.633295        5.2654e-01      OK
chr1    785910-785910   ENSG00000237491.8       eQTL    Artery_Coronary 1       0.633295        5.2654e-01      OK
chr1    785910-788439   ENSG00000237491.8       eQTL    Artery_Tibial   1       0.633295        5.2654e-01      OK
chr1    785910-863579   ENSG00000237491.8       eQTL    Brain_Amygdala  1       0.633295        5.2654e-01      OK
chr1    785910-788511   ENSG00000237491.8       eQTL    Brain_Anterior_cingulate_cortex_BA24    1       0.633295        5.2654e-01      OK
chr1    785910-788511   ENSG00000237491.8       eQTL    Brain_Caudate_basal_ganglia     1       0.633295        5.2654e-01      OK
```


```head -n5 results/annotated.summary_out.txt
#CHR	POS	GENE	N_SNPS	N_CLASSES	TOP_CLASS	TOP_SUBCLASS	MIN_UNADJ_PVAL	NAIVE_PVAL	PVAL
chr1	785910-863579	ENSG00000237491.8	6	E=48,R=0,O=0	eQTL	Adipose_Subcutaneous,Adipose_Visceral_Omentum,Artery_Aorta,Artery_Coronary,Artery_Tibial,Brain_Amygdala,Brain_Anterior_cingulate_cortex_BA24,Brain_Caudate_basal_ganglia,Brain_Cerebellar_Hemisphere,Brain_Cerebellum,Brain_Cortex,Brain_Frontal_Cortex_BA9,Brain_Hippocampus,Brain_Hypothalamus,Brain_Nucleus_accumbens_basal_ganglia,Brain_Putamen_basal_ganglia,Brain_Spinal_cord_cervical_c-1,Breast_Mammary_Tissue,Cells_Cultured_fibroblasts,Cells_EBV-transformed_lymphocytes,Colon_Sigmoid,Colon_Transverse,Esophagus_Gastroesophageal_Junction,Esophagus_Mucosa,Esophagus_Muscularis,Heart_Atrial_Appendage,Heart_Left_Ventricle,Liver,Lung,Minor_Salivary_Gland,Muscle_Skeletal,Nerve_Tibial,Ovary,Pancreas,Pituitary,Prostate,Skin_Not_Sun_Exposed,Skin_Sun_Exposed,Small_Intestine_Terminal_Ileum,Spleen,Stomach,Thyroid,Uterus,Vagina,Whole_Blood	5.265e-01	1.000e+00	6.133e-01	OK
chr1	785910-863579	ENSG00000230092.7	17	E=35,R=0,O=0	eQTL	Adipose_Subcutaneous,Adipose_Visceral_Omentum,Adrenal_Gland,Artery_Aorta,Artery_Coronary,Artery_Tibial,Breast_Mammary_Tissue,Colon_Transverse,Esophagus_Gastroesophageal_Junction,Esophagus_Mucosa,Esophagus_Muscularis,Heart_Atrial_Appendage,Lung,Minor_Salivary_Gland,Muscle_Skeletal,Pancreas,Prostate,Skin_Not_Sun_Exposed,Skin_Sun_Exposed,Small_Intestine_Terminal_Ileum,Spleen,Stomach	5.265e-01	1.000e+00	6.126e-01	OK
chr1	785910-863579	ENSG00000228327.3	17	E=25,R=0,O=0	eQTL	Adipose_Subcutaneous,Artery_Aorta,Artery_Coronary,Cells_Cultured_fibroblasts,Esophagus_Mucosa,Heart_Left_Ventricle,Nerve_Tibial,Prostate	5.265e-01	1.000e+00	6.106e-01	OK
chr1	785910-1516000	ENSG00000177757.2	22	E=40,R=0,O=0	eQTL	Adipose_Subcutaneous,Adipose_Visceral_Omentum,Artery_Aorta,Artery_Tibial,Breast_Mammary_Tissue,Esophagus_Muscularis,Heart_Left_Ventricle,Minor_Salivary_Gland,Prostate,Small_Intestine_Terminal_Ileum,Spleen	5.265e-01	1.000e+00	6.137e-01	OK
```
</details>
<br>


# Stress testing

`twas` pipeline has been stress tested using real GWAS summary statistics that have undergone harmonisation. 

## Output:


| Test config  |  N input variants | N processes | Runtime\* | Cost\* |
| -------------- | ----------- |----------- | ----------- | ----------- | 
| `conf/stress_test/test_vcf.config` | 2429904 |   3         |   00:16:55          | $0.1278 |
| `conf/stress_test/test_large_vcf.config` | 13111837 |   3         |    00:27:21          | $0.2065 |


\* The analyses were run in parallel, and on different timepoints more than one AWS instances were utilised. This autoscaling is managed by the Nextflow executor. The runs described above were run using AWS batch executor.



