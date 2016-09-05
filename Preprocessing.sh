# Pipeline to check the number of reads mapping to contigs
# get the length of the contigs and the number of reads mappingo

usage=`echo -e "\n Usage: Preprocessing.sh file_R1.fastq file_R2.fastq ContigFile.fa Outprefix\n"`;

if [[ ! $1 ]]
then
        printf "${usage}\n\n";
exit;
fi

read1=$1
read2=$2
echo "Processing Input files" $read1 $read2
contig=$3
stub=$4

bowtie2-build $contig $stub
bowtie2 -x $stub -1 $read1 -2 $read2 -S ${stub}_bowtie2.sam
samtools view -bS ${stub}_bowtie2.sam | samtools sort -o ${stub}_bowtie2.bam
samtools index ${stub}_bowtie2.bam
weeSAMv1.1 -b ${stub}_bowtie2.bam -out $stub