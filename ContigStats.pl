#!/usr/bin/perl -w 

# Script written by Joseph Hughes at the University of Glasgow
# Use this script to produce information on the breadth and depth of coverage
# from a BAM file. Gives the number of mapped reads. Average coverage
# Min and Max coverage
# Modified from weeSAM1.1 on 5th Sep 2016

use Getopt::Long; 
use strict;
use Bio::SeqIO;

# declaring global variables
my $cutoff=0;
my ($bamfile,$out,$help,%info,$totalunmapped,$totalmapped,%depth,$contigfile);
&GetOptions(
	    '-b:s'  => \$bamfile,#the bam file
	    '-contig:s' => \$contigfile,
	    '-c:i'  => \$cutoff,# the number of reads to use as a cut-off
	    "h|help|?"  => \$help,#the help
	    '-out=s'  => \$out,#file with coverage of for the file
           );

if (($help)||(!$bamfile&&!$contigfile)){
print "   Usage : ContigStats.pl <list of arguments>\n";
print "    -b <txt>   - the input BAM file\n";
print "    -contig <txt>    - the input contig file\n";
print "    -c <int>   - cut-off value for number of mapped reads [default = 0]\n";
print "   -out <txt> - the output file name\n";
print "    -help|h|?  - Get this help\n";
exit();
 }


if ($bamfile){
  #print "$bamfile\n";
  makeSumStats($bamfile,$contigfile);
}

sub makeSumStats{
  my (@contigIDs);
  my $bam=shift;
  my $contig=shift;
  print "$bam\n";
  print "$contig\n";
  my $inseq = Bio::SeqIO->new(-file   => "$contig",
                            -format => "fasta", );
  my $cnt=0;
  while (my $seq = $inseq->next_seq) {
    $info{$seq->id}{"reflength"}=$seq->length;
    $cnt++;
  }
  #open(NOMAPPED,">$out\_none_mapped.txt")||die "Can't open $out\_none_mapped.txt\n";
  open(OUT,">$out\.txt")||die "Can't open output\n";
  system("samtools idxstats $bam > tmp_mapped.txt");
  open(MAPPED,"<tmp_mapped.txt")||die "Can't open tmp_mapped.txt\n";
  while(<MAPPED>){
   chomp($_);
   my @cols=split(/\t/,$_);
   if ($_=~/^\*/){
      $totalunmapped+=$cols[3]; 
    }else{
      $totalmapped+=$cols[2];
      $totalunmapped+=$cols[3];
      if ($cols[2]>$cutoff){
        #print "$_","\n";
        $info{$cols[0]}{"reflength"}=$cols[1];
        $info{$cols[0]}{"mapped"}=$cols[2]; 
      } 
    }
  }
  close(MAPPED);
  system("rm tmp_mapped.txt");
  print "Total of mapped = $totalmapped\nTotal of unmapped = $totalunmapped\n";
  my $totalreads=$totalunmapped+$totalmapped;
  print "Total reads $totalreads\n";
  
  system("samtools depth $bam > tmp_depth.txt");
  open(DEPTH,"<tmp_depth.txt")||die "Can't open tmp_depth.txt\n";
  while(<DEPTH>){
    chomp($_);
    my @cols=split(/\t/,$_);
    if ($info{$cols[0]}{"reflength"}){
      $depth{$cols[0]}{$cols[1]}=$cols[2];
      $info{$cols[0]}{"breadth"}++;
      $info{$cols[0]}{"sumdepth"}+=$cols[2];
      if (!$info{$cols[0]}{"min"}){
        $info{$cols[0]}{"min"}=$cols[2];
      }elsif ($info{$cols[0]}{"min"}>$cols[2] && $info{$cols[0]}{"min"}){
        $info{$cols[0]}{"min"}=$cols[2];
      }
      if (!$info{$cols[0]}{"max"}){
        $info{$cols[0]}{"max"}=$cols[2];
      }elsif ($info{$cols[0]}{"max"}<$cols[2] && $info{$cols[0]}{"max"}){
        $info{$cols[0]}{"max"}=$cols[2];
      }
    }
  }  
  close(DEPTH);
  system("rm tmp_depth.txt");
  my $wocnt=0;
  print OUT "ReferenceID\tRefLength\tMappedReads\tBreadth\tPercentCovered\tMinDepth\tMaxDepth\tAverageDepth\n";
  #print NOMAPPED "ReferenceID\tRefLength\tMappedReads\tBreadth\tPercentCovered\tMinDepth\tMaxDepth\tAverageDepth\n";
  for my $id (keys %info){
    if ($info{$id}{"reflength"}){
      
      if ($info{$id}{"mapped"}){
        print OUT "$id\t".$info{$id}{"reflength"}."\t";
        print OUT $info{$id}{"mapped"}."\t";
        print OUT $info{$id}{"breadth"}."\t";
        print OUT $info{$id}{"breadth"}*100/$info{$id}{"reflength"}."\t";
        print OUT $info{$id}{"min"}."\t".$info{$id}{"max"}."\t";
        print OUT $info{$id}{"sumdepth"}/$info{$id}{"breadth"}."\n";
       }else{ 
         $wocnt++;
         #print NOMAPPED "$id\t".$info{$id}{"reflength"}."\t";
         #print NOMAPPED "NA\tNA\tNA\tNA\tNA\n";
         print OUT "$id\t".$info{$id}{"reflength"}."\t";
         print OUT "NULL\tNULL\tNULL\tNULL\tNULL\n";

       }
     }
  }
  print "Total without reads mapping $wocnt out of a total of $cnt contigs\n";
}

