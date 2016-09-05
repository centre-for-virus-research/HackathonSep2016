# Pipeline to make the checks and gather stats to put into the database
# 1) adaptor library
# 2) 30% similarity for protein (DIAMOND)
# 3) 50% similarity for nucleotide
# 4) low complexity (DUST, entropy)


#Convert the blast db to fastas

# fastacmd -d nr -p T -a T -D 1 -o nr.faa
# blastdbcmd -db nr -dbtype prot -get_dups -outfmt %f -out nr_blastdbcmd.faa

usage=`echo -e "\n Usage: Checks.sh ContigFile.fa Outprefix\n"`;

if [[ ! $1 ]]
then
        printf "${usage}\n\n";
exit;
fi

contig=$1
stub=$2
adapters=/home3/Davison/adapters.fasta
diamonddb=/home3/Davison/db/

#Step 1 Adaptor library
#to format the adapter file to blast db format

echo "Mapping the sequences to adapter library"
makeblastdb -in $adapters -dbtype 'nucl'

blastn -db adapters.fasta -query $contig -out ${contig}_adapters_out -perc_identity 100 -outfmt 6 -num_threads 8
cat ${contig}_adapters_out |cut -f1,2 > ${contig}_adapters_out_trimmed 

#Step 2 DIAMOND blastx and blastn classification of contigs

echo "Classifying the sequences using DIAMOND and BLASTN.... this might take a while"
mkdir ${stub}_temp_dir
diamond blastx -d $diamonddb/nr -p 8 -q $contig -a ${contig}_diamond -t ${stub}_temp_dir --top 1 &

blastn -query $contig -db nt -out ${contig}_blastn.txt -evalue 0.0001 -max_target_seqs 1 -outfmt 6 -num_threads 8

diamond view -a ${contig}_diamond.daa -o ${contig}_diamond.m8

#Step 3 filter blast and diamond output 
echo "Filtering the classification output"
awk -F"\t" '{if($3<=50) print}' ${contig}_blastn.txt > ${contig}_blastn_filtered.txt
awk -F"\t" '{if($3<=30) print}' ${contig}_diamond.m8 > ${contig}_diamond_filtered.txt
