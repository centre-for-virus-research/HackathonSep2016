# Pipeline to make the checks and gather stats to put into the database
# 1) adaptor library
# 2) 30% similarity for protein (DIAMOND)
# 3) 50% similarity for nucleotide
# 4) low complexity (DUST, entropy)

usage=`echo -e "\n Usage: Checks.sh file_R1.fastq file_R2.fastq ContigFile.fa Outprefix\n"`;

if [[ ! $1 ]]
then
        printf "${usage}\n\n";
exit;
fi

read1=$1
read2=$2
echo "Checking files" $read1 $read2
contig=$3
stub=$4

Step 2 DIAMOND blastx ...
diamond blastx -d $DIAMOND_DB/nr -p 8 -q $contig -a ${contig}_diamond -t ${stub}_temp_dir --top 1
