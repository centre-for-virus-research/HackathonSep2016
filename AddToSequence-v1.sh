#!/bin/bash
#
# Script for preprocessing merged contig data, blasting the dark sequence database and adding to database
#
# Usage: AddToSequence.sh table.txt
# 
# Author: Sreenu Vattipally
# 7th Sep, 2016
#

Usage () {
    echo "";
    echo "Usage: AddToSequence.sh table.txt";
    echo "";
}

# Check the command line options
if [ $# -ne 1 ]; then Usage; exit 1; fi

# Is the input file readble
if [ ! -f $1 ]; then echo "File $1 not found"; Usage; exit 1; fi

cp $1 ~/data-$$.txt

# Create a temporary KnwonDark table and add results
echo "DROP TABLE IF EXISTS Sequence_t; CREATE TABLE Sequence_t(smpID int, seqID varchar(100) not null primary key, technology varchar(100), seqType tinyint, libPrep text, FOREIGN KEY fk_smpID(smpID) REFERENCES Sample(smpID) ON UPDATE CASCADE ON DELETE RESTRICT) engine=innoDB;"| mysql -B -uhack -pHackCVR16 Hack

# Add results to the table and catch warnings
echo "load data infile \"/home1/vatt01s/data-$$.txt\" into table Sequence_t" | mysql --show-warnings -B -uhack -pHackCVR16 Hack  2>&1 >myWarning1-$$
Warnings1=$(wc -l myWarning1-$$ |awk '{print $1}');

# If there are any warnings, report them and abort the script
if [ $Warnings1 -ne 0 ]; then
	echo "Somethig is wrong";
	cat myWarning1-$$; rm myWarning1-$$;
	echo "DROP TABLE Sequence_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack 
	exit;
# If there are no warnings, merger temp table with main table 
else
	echo "So far everything is fine";
	echo "Merging tables"
	echo "INSERT IGNORE  INTO Sequence SELECT *   FROM Sequence_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack  2>&1 >myWarning2-$$
	echo "DROP TABLE Sequence_t"|mysql --show-warnings -B -uhack -pHackCVR16 Hack  2>&1 >>myWarning2-$$
	cat myWarning2-$$
	rm myWarning?-$$
fi

# House keeping
rm  ~/data-$$.txt 
