# Hackathon using September 2016

## Datasets
**Zika sample**: sequenced with Nextseq and Miseq. Contigs generated using IDBA and spades and 
consolodiated using GARM. 



## Scripts
**ContigStats.pl**: perl script to process a bam file, provides sttistics about number 
of reads mapping, coverage of contig, depth etc...
e.g.: 
```
./ContigStats.pl -b input_bowtie2.bam -contig contig.fa -out stats.txt
```

**Preprocessing.sh**: bash script to carry out bowtie2 mapping of reads of contigs and 
preprocessing stats
e.g.:
```
Preprocessing.sh file_R1.fastq file_R2.fastq contig.fa Outprefix
```
**Checks.sh**: bash script to check for sequencing adapters and carry out classification of the reads using DIAMOND and BLASTN 
e.g.:
```
Checks.sh ContigFile.fa Outprefix
```

**JoinTables.pl**: perl script to join the mapped read table, entropy/GC table, 
diamond table, blast table, adaptor match table
e.g.:
```
perl JoinTables.pl -adaptor checks_adapters_out -diamond checks_diamond.m8 -blast checks_blastn.m8 -entropy contigs.complex -mapped mapping.txt -out output.txt
```

**profileComplexSeq1.pl**
e.g.:
```
perl profileComplexSeq1.pl <filename.fa>
```
The output is filename.complex where columns are tab delimited in the order of 
seq is the header of the contigs/sequence
gc is the complexity of GC content of the sequence
gcs is the complexity of GC-skew of the sequence
cpg is the complexity of CpG island content of the sequence
cwf is the complexity of Woottoon and Federhen value
ce is the complexity of Shannon Entropy
cz is the complexity of compression factor using Gzip


