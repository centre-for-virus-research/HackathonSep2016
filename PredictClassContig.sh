# Pipeline written by Quan to predict the class (i.e. dark or light) of the contigs from their complexity based on the machine learning. Here support vector machine (SVM) algorithm


usage=`echo -e "\n Usage: PredictClassContig ContigFile.fa\n"`;

if [[ ! $1 ]]
then
        printf "${usage}\n\n";
exit;
fi

fafile=$1
cp $fafile InputCotigs.fa
perl profileComplexSeq1.pl InputCotigs.fa

echo "select contigID, gc, gcs, cpg, cwf, ce, cz from MergeTable where diamond_subjectID is null and blast_subjectID is null"| mysql --show-warnings -B -uhack -pHackCVR16 Hack |awk 'NR>1 {print $0"\tdark"}'> dark.txt
echo "select contigID, gc, gcs, cpg, cwf, ce, cz from MergeTable where diamond_subjectID is not null or blast_subjectID is not null"| mysql --show-warnings -B -uhack -pHackCVR16 Hack |awk 'NR>1 {print $0"\tlight"}'> light.txt
cat dark.txt light.txt > darklight.txt
sed -i '1s/^/contigID gc gcs cpg cwf ce cz darklight\n/'  darklight.txt
mv darklight.txt traindata.txt
rm dark.txt light.txt
Rscript MLlearning.r

