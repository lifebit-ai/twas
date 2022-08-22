## Required inputs

Required inputs are:

- **gwas_summary_stats**: GWAS single-SNP z-scores in a bgzipped tab-delimited file (unheadered).

Example of input format:

```
chr1    13550   A       G       chr1:13550      80000   0.8642866907940172      Intergenic
chr1    14671   C       G       chr1:14671      80000   -0.4617594113749683     Intergenic
chr1    14677   A       G       chr1:14677      80000   0.6336196044020656      Intergenic
chr1    14933   G       A       chr1:14933      80000   0.2533470988273621      Intergenic
chr1    16141   C       T       chr1:16141      80000   -0.11694958806037906    Intergenic
chr1    16841   T       G       chr1:16841      80000   -0.2345007249035332     Intergenic
chr1    17005   G       A       chr1:17005      80000   -1.208853235961594      Intergenic
chr1    17147   A       G       chr1:17147      80000   0.1496000333131716      Intergenic
chr1    17407   A       G       chr1:17407      80000   0.9363175203120216      Intergenic
chr1    17408   G       C       chr1:17408      80000   -0.6105776381841782     Intergenic
```

- **ld_reference_panel**: consists of a set of vcf files used for computing LD information. Default = 1000 Genomes project (phase 3 version 5).


## Optional inputs

- **eqtl_weights**: used by PTWAS scan procedure to construct composite IVs, also known as the eQTL weights for burden test. Pre-computed weights file from 49 tissues in the GTEx project are used by default.


## Resources

http://sashagusev.github.io/2017-10/twas-vulnerabilities.html