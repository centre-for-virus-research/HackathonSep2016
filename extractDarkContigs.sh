#!/bin/bash

##########################################################################
#This script takes two inputs 
# $1 is the prefix of the contigs file extarcted
# $2 is the prefix for the output files generated for Diamond and Blastn
##########################################################################

usage=`echo -e "\n Usage: extarctDarkContigs.sh ContigFileName Outprefix\n"`;

if [[ ! $1 ]]
then
        printf "${usage}\n\n";
exit;
fi

############################################
# Setting all variable here
###########################################
user=modh01s
passwd=alphamysql
db=Hack
date=`date +"%d%m%Y"`
diamonddb=/home3/Davison/db/
diamond=/home3/Davison/bin/
contig=$1
stub=$2


#############################################
# Extract the sequences in the tsv format
############################################
mysql --user=$user --password=$passwd $db< DarkContigs.sql > dark_contigs.txt
awk -F"\t" '{print ">"$1"\n"$2}' dark_contigs.txt |awk 'NR>2 {print}'> ${contig}_${date}.fa
rm dark_contigs.txt


##############################################################
# Re-classify the sequences against the latest versions of db
##############################################################

echo "Classifying the sequences using DIAMOND and BLASTN.... this might take a while"
mkdir ${stub}_temp_dir
${diamond}diamond blastx -d ${diamonddb}nr -q ${contig}_${date}.fa -o ${stub}_diamond.m8 -t ${stub}_temp_dir --top 1 -p 8 &
blastn -query ${contig}_${date}.fa -db nt -out ${stub}_blastn.m8  -max_target_seqs 1 -outfmt 6 -num_threads 8
