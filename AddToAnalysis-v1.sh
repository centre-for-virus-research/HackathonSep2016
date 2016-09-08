#!/bin/bash
#
# Script for preprocessing merged contig data, blasting the dark sequence database and adding to database
#
# Usage: AddToAnalysis.sh table.txt
# 
# Author: Sreenu Vattipally
# 7th Sep, 2016
#

ARGC=$#  # Number of args, not counting $0
Usage () {
    echo "";
    echo "Usage: AddToAnalysis.sh table.txt";
    echo "";
}

# Check the command line options
if [ $# -eq 2 ]; then Usage; exit 1; fi

# Is the input file readble
if [ ! -f $1 ]; then echo "File $1 not found"; Usage; exit 1; fi


cp $1 ~/data-$$.txt

# Create a temporary KnwonDark table and add results
echo "DROP TABLE IF EXISTS Analysis_t; CREATE TABLE Analysis_t(seqID varchar(100) not null primary key, researcher varchar(100), analysisDate date, denovoProgram varchar(100), denovoOptions varchar(100), ntVerstion varchar(50), progAndOptionsforNtSearch varchar(100), nrVersion varchar(50), progAndOptionsforNrSearch varchar(100), knonwGenomesInTheSample text, notes text, FOREIGN KEY fk_seqID(seqID) REFERENCES Sequence(seqID) ON UPDATE CASCADE ON DELETE RESTRICT ) engine=innoDB;"| mysql -B -uhack -pHackCVR16 Hack

# Add results to the table and catch warnings
echo "load data infile \"/home1/vatt01s/data-$$.txt\" into table Analysis_t" | mysql --show-warnings -B -uhack -pHackCVR16 Hack  2>&1 >myWarning1-$$
Warnings1=$(wc -l myWarning1-$$ |awk '{print $1}');

# If there are any warnings, report them and abort the script
if [ $Warnings1 -ne 0 ]; then
	echo "Somethig is wrong";
	cat myWarning1-$$; rm myWarning1-$$;
	echo "DROP TABLE Analysis_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack 
	exit;
# If there are no warnings, merger temp table with main table 
else
	echo "So far everything is fine";
	echo "Merging tables"
	echo "INSERT IGNORE  INTO Analysis SELECT *   FROM Analysis_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack  2>&1 >myWarning2-$$
	echo "DROP TABLE Analysis_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack  2>&1 >>myWarning2-$$
	cat myWarning2-$$
	rm myWarning?-$$
fi

# House keeping
rm  ~/data-$$.txt 
