# Bioinformatics

Specifications for all projects in their respective specification.pdf file

## ORFinder

Python script that takes as input a bacterial genome sequence in fasta format, searches it for ORFs (minimum size 150bp/50aa) then searches the NCBI swissprot database for proteins similar to each ORF. The output can be redirected to a CSV file.

### Usage Example
```
perl geneannot.pl geobacter.fasta > result.csv

```
