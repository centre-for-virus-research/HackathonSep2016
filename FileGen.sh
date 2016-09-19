#!/bin/bash

echo ""
echo "---Creating a sample table---";
echo ""

echo "Data owner's name:"
read owner

echo "Date of collection (yyyy-mm-dd: if unknown, enter:0000-00-00):"
read date

echo "Is this a metagenomics sample (if yes, enter 1, else enter 0):"
read meta

echo "What is the sample source (serun, saliva...etc):"
read sour

echo "What is the host:"
read host

echo -e $owner"\t"$date"\t"$meta"\t"$sour"\t"$host; > sample-$$

echo ""
echo "---Creating a sequence table---";
echo ""

echo "Give a unique sequence ID:"
read seqID

echo "What is the sequencing technology (Illumina, Ion torrent...):"
read tech

echo "Is this a paired-end or single-end data(enter 1 for single-end, enter 2  for paired end):"
read seqType

echo "Tell about library prep:"
read libPrep

echo -e $seqID"\t"$tech"\t"$seqType"\t"$libPrep > seq-$$


echo ""
echo "---Creating a analysis table---";
echo ""

echo "Who did the analysis:"
read res

echo "When was the  analysis done:"
read adate

echo "De novo program used:"
read den

echo "De novo program options:"
read denOp

echo "NT version:"
read nt

echo "NT comparison program and options:"
read ntOp

echo "NR version:"
read nr

echo "NR comparison program and options:"
read nrOp

echo "Are there any known viruses:"
read knownVir

echo "Any other notess:"
read notes

echo -e $seqID"\t"$res"\t"$adate"\t"$den"\t"$denOp"\t"$nt"\t"$ntOp"\t"$nr"\t"$nrOp"\t"$knownVir"\t"$notes > analysis-$$

exit 0
