#!/bin/bash
#
# Script for getting Dark Sequences
#
# Usage: getDarkContigs.sh file1.fq file2.fq contigs.fa unique_id
# 
# Author: Sreenu Vattipally
# 7th Sep, 2016
#

Usage () {
    echo "";
    echo "Usage: getDarkContigs.sh file1.fq file2.fq contigs.fa unique_id"
    echo "";
}

# Check the command line options
if [ $# -ne 4 ]; then Usage; exit 1; fi

Complex=$(echo "$3"|sed s/.fasta//g|sed s/.fa//g);

./Preprocessing.sh $1 $2 $3 $4

./Checks-v1.sh $3 $4

perl profileComplexSeq1.pl $3

perl JoinTables.pl -adaptor $4\_adapters_out -diamond $4\_diamond.m8 -blast $4\_blastn.m8 -entropy $Complex.complex -mapped $4.txt.txt -contig $3 -out $4\_joined.txt 
