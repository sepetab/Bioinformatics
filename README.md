# Bioinformatics

More detail for all projects in their respective specification.pdf file

## ORFinder

Perl script that takes as input a bacterial genome sequence in fasta format, searches it for ORFs (minimum size 150bp/50aa) then searches the NCBI swissprot database for proteins similar to each ORF. The output is of CSV format.

### Usage Example
```
perl geneannot.pl input.fasta > output.csv

```

## EvolutionSim

Python script that simulates the evolution of a protein sequence using an amino acid mutation matrix. Takes protein sequence as input in fasta format and outputs mutated sequences in fasta format for 500 generations.

### Usage Example
```
python3 evolve.py < input.fasta > output.fasta

```
## Protein Modelling 

The aim is to build a model of a protein from its sequence and validate it. The model is built from the sequence of a DNA-binding protein from Pseudomonas.

### Sequence
```
>pf4mutant
MSTPADRARLLIKKIGPKKVSLHGGDYERWKSVSKGAIRVSTEEIDVLVKIFPNYALWIASGSIAPEVGQTS
PDYDEANLNLSNQNAG
```


