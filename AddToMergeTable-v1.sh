#!/bin/bash
#
# Script for preprocessing merged contig data, blasting the dark sequence database and adding to database
#
# Usage: AddToMergeTable.sh merged_contigs.txt seqID
# 
# Author: Sreenu Vattipally
# 7th Sep, 2016
#

ARGC=$#  # Number of args, not counting $0
Usage () {
    echo "";
    echo "Usage: AddToMergeTable.sh merged_contigs.txt seqID";
    echo "";
}

# Check the command line options
if [ $# -eq 3 ]; then Usage; exit 1; fi

# Is the input file readble
if [ ! -f $1 ]; then echo "File $1 not found"; Usage; exit 1; fi


# Start processing the data

# Preprocess the data
awk 'BEGIN{SeqID=ARGV[2]; delete ARGV[2];}{print SeqID":"$0"\t"SeqID;}' $1 $2|\
awk '{for(i=1; i<=NF; i++) if(i!=1&&i!=2&&i!=3&&i!=14&&i!=25&&$i=="NULL") printf("0\t"); else printf("%s\t",$i); print ""}' |\
awk 'NR>1' |sed s/NULL//g > ~/data-$$

# Export existing dark sequences
echo "SELECT ContigID, Seq FROM MergeTable" | mysql -N -B -uhack -pHackCVR16 Hack |awk '{print ">"$1"\n"$2}' > db-$$.fasta

# Format them for blast search
formatdb -i db-$$.fasta -p F 

# Convert merged_table sequences into fasta format
awk '{print ">"$1"\n"$2}' ~/data-$$ > query-$$.fa

# Compare them with the database. Warning messages will be supressed
blastall -p blastn -i query-$$.fa -d db-$$.fasta -m 8  -o blast-$$.out > /dev/null 2>&1 

# Remove duplicate query IDs and keep first best match
awk '!x[$1]++' blast-$$.out > ~/res-$$.out

# Create a temporary KnwonDark table and add results
echo "DROP TABLE IF EXISTS KnownDark_t; create table KnownDark_t(queryID varchar(100) not null Primary key, contigID varchar(100), percIdentity float, alnLength int, mismatchCount int, gapOpenCount int, queryStart int, queryEnd int, contigStart int, contigEnd int, eVal float, bitScore float, FOREIGN KEY fk_contigID(contigID) REFERENCES MergeTable(contigID) ON UPDATE CASCADE ON DELETE RESTRICT)engine=innoDB;"| mysql -B -uhack -pHackCVR16 Hack

# Add results to the table and catch warnings
echo "load data infile \"/home1/vatt01s/res-$$.out\" into table KnownDark_t" | mysql --show-warnings -B -uhack -pHackCVR16 Hack  2>&1 >myWarning1-$$
Warnings1=$(wc -l myWarning1-$$ |awk '{print $1}');

# Create a temporary table and add results
echo "DROP TABLE IF EXISTS MergeTable_t; create table MergeTable_t(contigID varchar(100) not null primary key, Seq mediumtext, adaptor_subjectId varchar(100), adaptor_percIdentity float, adaptor_alnLength int, adaptor_mismatchCount int, adaptor_gapOpenCount int, adaptor_queryStart int, adaptor_queryEnd int, adaptor_subjectStart int, adaptor_subjectEnd int, adaptor_eVal float, adaptor_bitScore float, diamond_subjectId varchar(100), diamond_percIdentity float, diamond_alnLength int, diamond_mismatchCount int, diamond_gapOpenCoun int, diamond_queryStart int, diamond_queryEnd int, diamond_subjectStart int, diamond_subjectEnd int, diamond_eVal float, diamond_bitScore float, blast_subjectId varchar(100), blast_percIdentity float, blast_alnLength int, blast_mismatchCount int, blast_gapOpenCount int, blast_queryStart int, blast_queryEnd int, blast_subjectStart int, blast_subjectEnd int, blast_eVal float, blast_bitScore float,gc float, gcs float, cpg float, cwf float, ce float, cz float, RefLength int, MappedReads int, Breadth int, PercentCovered float, MinDepth int, MaxDepth int, AverageDepth float, seqID varchar(100), FOREIGN KEY fk_seqID(seqID) REFERENCES Sequence(seqID) ON UPDATE CASCADE ON DELETE RESTRICT)engine=innoDB;"| mysql -B -uhack -pHackCVR16 Hack


echo "load data infile \"/home1/vatt01s/data-$$\" into table MergeTable_t(@contigID, Seq, @adaptor_subjectId, adaptor_percIdentity, adaptor_alnLength, adaptor_mismatchCount, adaptor_gapOpenCount, adaptor_queryStart, adaptor_queryEnd, adaptor_subjectStart, adaptor_subjectEnd, adaptor_eVal, adaptor_bitScore, @diamond_subjectId, diamond_percIdentity, diamond_alnLength, diamond_mismatchCount, diamond_gapOpenCoun, diamond_queryStart, diamond_queryEnd, diamond_subjectStart, diamond_subjectEnd, diamond_eVal, diamond_bitScore, @blast_subjectId, blast_percIdentity, blast_alnLength, blast_mismatchCount, blast_gapOpenCount, blast_queryStart, blast_queryEnd, blast_subjectStart, blast_subjectEnd, blast_eVal, blast_bitScore,gc, gcs, cpg, cwf, ce, cz, RefLength, MappedReads, Breadth, PercentCovered, MinDepth, MaxDepth, AverageDepth, seqID) SET ContigID=nullif(@contigID,''),adaptor_subjectId=nullif(@adaptor_subjectId,''),  diamond_subjectId=nullif(@diamond_subjectId,''), blast_subjectId=nullif(@blast_subjectId,'')" | mysql --show-warnings -B -uhack -pHackCVR16 Hack  2>&1 >myWarning2-$$

Warnings2=$(wc -l myWarning2-$$ |awk '{print $1}');

# If there are any warnings, report them and abort the script
if [ $Warnings1 -ne 0 ]||[ $Warnings2 -ne 0 ]; then
	echo "Somethig is wrong";
	cat myWarning?-$$; rm myWarning?-$$;
	echo "DROP TABLE KnownDark_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack
	echo "DROP TABLE MergeTable_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack
	exit;
# If there are no warnings, merger temp table with main table 
else
	echo "So far everything is fine";
	echo "Merging tables"
	echo "INSERT IGNORE  INTO MergeTable SELECT *   FROM MergeTable_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack  2>&1 >myWarning3-$$
	echo "INSERT IGNORE  INTO KnownDark SELECT *   FROM KnownDark_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack  2>&1 >myWarning4-$$
	echo "DROP TABLE KnownDark_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack
	echo "DROP TABLE MergeTable_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack
	cat myWarning?-$$
	rm myWarning?-$$
fi


# House keeping
rm  ~/data-$$ query-$$.fa db-$$.fasta* ~/res-$$.out blast-$$.out formatdb.log
