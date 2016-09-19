#!/bin/bash

##########################################################
# Script for cluster analysis
# 1) Run cd-hit with user-defined identity criteria
# 2) Remove clusters with only one members
# 3) Convert cd-hit output to XML and JSON outputs
# This script takes 3 parameters
# $1 File with dark contigs in fasta format
# $2 Identity cutoff for cd-hit
# $3 Output prefix
###########################################################
usage=`echo -e "\n Usage: clustering.sh DarkContigFile.fa IdentityThreshold(e.g. 0.9) Outprefix\n"`;

if [[ ! $1 ]]
then
        printf "${usage}\n\n";
exit;
fi

if [[ ! -f $1 ]]
then
		pwd=`pwd`
		echo Input file $1 not found, please ensure that the input file exists in $pwd;
		exit;
fi

contigs=$1
identity=$2
output=$2

cd-hit -i $contigs -o ${output}_cdhit_$identity -c $identity -d 150 -t 1
clstr2xml.pl -size ${output}_cdhit_${identity}.clstr |sed -e '/SequenceNo="1"/,+2d' > ${output}_cdhit_${identity}.xml
perl -MJSON::Any -MXML::Simple -le'print JSON::Any->new()->objToJson(XMLin())'|python -m json.tool |sed -e 's/\\n//g' > ${output}_cdhit_${identity}.json
