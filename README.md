# Hackathon using September 2016

## Datasets
**Zika sample**: sequenced with Nextseq and Miseq. Contigs generated using IDBA and spades and 
consolodiated using GARM. 




## Scripts
**contigs.php**: a web-based script to retrieves a contig, given its id in the URL, from the database and display it in a fasta format
e.g.:
```
/URL/contigs.php?id=<contigID>
```

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
**Checks-v1.sh**: bash script to check for sequencing adapters and carry out classification of the reads using DIAMOND and BLASTN 
e.g.:
```
Checks-v1.sh ContigFile.fa Outprefix
```

**JoinTables.pl**: perl script to join the mapped read table, entropy/GC table, 
diamond table, blast table, adaptor match table
e.g.:
```
perl JoinTables.pl -adaptor checks_adapters_out -diamond checks_diamond.m8 -blast checks_blastn.m8 -entropy contigs.complex -mapped mapping.txt -out output.txt
```

**profileComplexSeq1.pl** perl script to calculate the complexity of the contigs
e.g.:
```
perl profileComplexSeq1.pl <filename.fa>
```
The output is filename.complex where columns are tab delimited in the order of:
 
seq is the header of the contigs/sequence;

gc is the complexity as measured by the GC content of the sequence;

gcs is the complexity as measured by the GC-skew of the sequence;

cpg is  the complexity as measured by CpG island content of the sequence;

cwf is the complexity as measured by Woottoon and Federhen value;

ce is  the complexity as measured by Shannon Entropy;

cz is  the complexity as measured by compression factor using Gzip;

**RandomDark.jar** Java program to randomly generate paired end DNA sequences in FASTQ format. User supplies the read length and number of reads to output. The default behaviour is to use equal probabilities (25%) for the ACGT bases and 0 probability for N bases, but the user can override these. An output stub filename needs to be provided, and stub_1.fastq and stub_2.fastq files will be written. The source code is in RandomDark.java
```
java -jar RandomDark.jar NumberOfReads[int] ReadLength[int] OutputFilenameStub[string]
java -jar RandomDark.jar NumberOfReads[int] ReadLength[int] OutputFilenameStub[string] Aprob[double] Cprob[double] Gprob[double] Tprob[double] Nprob[double]
```

**RandomVirus.jar** Java program to generate paired end DNA sequences in FASTQ format, randomly generated from a given sequence file containing host and/or viral genome(s). The input sequence file must be in FASTA single sequence line format. User supplies the read length and number of reads to output. Reads can be generated from the input sequences with equal probability (each input sequence has equal weight: eqProb=Y) or by scaling the probability to reflect sequence length (eqProb=N). An output stub filename needs to be provided, and stub_1.fastq and stub_2.fastq files will be written. The source code is in RandomVirus.java
```
java -jar RandomVirus.jar InputSequenFileName[string] NumberOfReads[int] ReadLength[int] EqualProbability[y/n] OutputFilenameStub[string]

```
**extarctDarkContigs.sh** and **DarkContigs.sql** Bash and SQL script to extract current dark sequences from the database and re-run classification using latest version of the nt and nr DB using BLASTN and DIAMOND respectively.
```
extarctDarkContigs.sh ContigFileName Outprefix
```

**Scripts to process and add data to the database**

To add to Sample table 
```
AddToSample-v1.sh sample-1.txt
```

To add to Sequence table 
```
AddToSequence-v1.sh sequence-1.txt
```

To add to Analysis table 
```
AddToAnalysis-v1.sh analysis-1.txt
```

To add to MergeContigs and KnownDark tables 
```
AddToMergeTable-v1.sh midge1_join.txt midge1-0167e2
```


**MLlearning.r**  is the R script to predict the class of the input contigs (e.g. dark or light)  based on machine learning (here SVM is used).
```
Rscript MLlearning.r
```
The run this R script, we need two inputs files in the same directory.

(1) testdata.complex :
The Output file of profileComplexSeq1.pl with the complexity (e.g. GC content, entropy, etc.) of contigs for testing.
The header of the file: "ContigID gc gcs cpg cwf ce cz"

(2)traindata.txt :
The gold standard TXT file for training the prediction engine with the complexity (e.g. GC content, entropy, etc.) of contigs.
The format is almost same with testdata.complex but just with an extra column containing the class of contigs (i.e. dark or light).
The header of the file: "ContigID darklight gc gcs cpg cwf ce cz".

There are two output files:

(1)model_SV.csv
The key contigs with their corresponding attributes values (e.g. GC content, entropy, etc.) , which are support vectors for the machine learning and prediction.

(2)predict_result.csv
The prediction results with the contig ID and the corresponding predicted class of contigs (dark or light).

