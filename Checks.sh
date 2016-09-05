# Pipeline to make the checks and gather stats to put into the database
# 1) adaptor library
# 2) 30% similarity for protein (DIAMOND)
# 3) 50% similarity for nucleotide
# 4) low complexity (DUST, entropy)


#Convert the blast db to fastas

# fastacmd -d refseq_protein -p T -a T -D 1 -o allprots.faa

usage=`echo -e "\n Usage: Checks.sh ContigFile.fa Outprefix\n"`;

if [[ ! $1 ]]
then
        printf "${usage}\n\n";
exit;
fi

contig=$1
stub=$2

Step 1 Adaptor library



Step 2 DIAMOND blastx ...
diamond blastx -d $DIAMOND_DB/nr -p 8 -q $contig -a ${contig}_diamond -t ${stub}_temp_dir --top 1
