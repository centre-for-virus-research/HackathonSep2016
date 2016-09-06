#!/usr/bin/perl -w 

# Script written by Joseph Hughes at the University of Glasgow
# Use this script to joining multiple text tab delimited files based using the first column
# as an identifier 
# Hackathon 6th Sep 2016

use Getopt::Long; 
use strict;
use Bio::SeqIO;


# declaring global variables
my ($adaptor,$diamond,$blast,$entropy,$mapped,$contig,$help,%info,$out);
&GetOptions(
	    '-adaptor:s'  => \$adaptor,#
	    '-diamond:s' => \$diamond, #
	    '-blast:s'  => \$blast,# 
	    '-entropy:s'  => \$entropy,# 
	    '-mapped:s'  => \$mapped,# 
	    '-contig:s'  => \$contig,
	    "h|help|?"  => \$help,#the help
	    '-out=s'  => \$out,#file with coverage of for the file
           );

if (($help)||(!$adaptor&&!$diamond&&!$blast&&!$entropy&&!$mapped)){
print "   Usage : JoinTables.pl <list of arguments>\n";
print "    -adaptor <txt>   - the adaptor match file (m8 format)\n";
print "    -diamond <txt>    - the diamond protein match file (m8  format)\n";
print "    -blast <txt>    - the blastn output (m8  format)\n";
print "    -entropy <txt> - the entropy and GC metrics (text-tab with header)\n";
print "    -mapped <txt> - the file with number of mapped reads, coverage (text-tab with header)\n";
print "    -contig <txt> - the file with all the contigs\n";
print "    -out <txt> - the output prefix  name\n";
print "    -help|h|?  - Get this help\n";
exit();
 }


my $inseq = Bio::SeqIO->new(-file   => "$contig",
                            -format => "fasta", );
my $cnt=0;
while (my $seq = $inseq->next_seq) {
    $info{$seq->id}{"sequence"}=$seq->seq;
    $cnt++;
}


my $i;
my @m8_header=qw/queryId subjectId percIdentity alnLength mismatchCount gapOpenCount queryStart queryEnd subjectStart subjectEnd eVal bitScore/;
open(ADAPTOR,"<$adaptor")||die "Can't open $adaptor\n";
while(<ADAPTOR>){
  chomp($_);
  my @elements=split(/\t/,$_);
  #print "@elements\n";
  for ($i=1; $i<scalar(@elements);$i++){
    #print "adaptor_$m8_header[$i]\t$elements[$i]\n";
    $info{$elements[0]}{"adaptor_$m8_header[$i]"}=$elements[$i];
  }
}

open(DIAMOND,"<$diamond")||die "Can't open $diamond\n";
while(<DIAMOND>){
  chomp($_);
  my @elements=split(/\t/,$_);
  #print "@elements\n";
  for ($i=1; $i<scalar(@elements);$i++){
    #print "diamond_$m8_header[$i]\t$elements[$i]\n";
    $info{$elements[0]}{"diamond_$m8_header[$i]"}=$elements[$i];
  }
}

open(BLAST,"<$blast")||die "Can't open $blast\n";
while(<BLAST>){
  chomp($_);
  my @elements=split(/\t/,$_);
  #print "@elements\n";
  for ($i=1; $i<scalar(@elements);$i++){
    #print "diamond_$m8_header[$i]\t$elements[$i]\n";
    $info{$elements[0]}{"blast_$m8_header[$i]"}=$elements[$i];
  }
}

open(ENTROPY,"<$entropy")||die "Can't open $entropy\n";
my $entropy_header=<ENTROPY>;
chomp($entropy_header);
my @entropy_header=split(/\t/,$entropy_header);
while(<ENTROPY>){
  chomp($_);
  my @elements=split(/\t/,$_);
  #print "ENTROPY @elements\n";
  for ($i=1; $i<scalar(@elements);$i++){
    #print "$entropy_header[$i]\t$elements[$i]\n";
    $info{$elements[0]}{"$entropy_header[$i]"}=$elements[$i];
  }
}

open(MAPPED,"<$mapped")||die "Can't open $mapped\n";
my $mapped_header=<MAPPED>;
chomp($mapped_header);
my @mapped_header=split(/\t/,$mapped_header);
#print join("\t",@mapped_header),"\n";
while(<MAPPED>){
  chomp($_);
  my @elements=split(/\t/,$_);
  #print "MAPPED @elements\n";
  for ($i=1; $i<scalar(@elements);$i++){
    #print "$mapped_header[$i]\t$elements[$i]\n";
    $info{$elements[0]}{"$mapped_header[$i]"}=$elements[$i];
  }
}

open(OUT,">$out")||die "Can't open $out\n";
print OUT "ContigID\t";
print OUT "Sequence\t";
print OUT "adaptor_",join("\tadaptor_",@m8_header[1 .. $#m8_header]);
print OUT "\tdiamond_",join("\tdiamond_",@m8_header[1 .. $#m8_header]);
print OUT "\tblast_",join("\tblast_",@m8_header[1 .. $#m8_header]);
print OUT "\t",join("\t",@entropy_header[1 .. $#entropy_header]);
print OUT "\t",join("\t",@mapped_header[1 .. $#mapped_header]);
print OUT "\n";

foreach my $contigname (keys %info){
  print OUT $contigname;
  print OUT "\t",$info{$contigname}{"sequence"};
  for ($i=1; $i<scalar(@m8_header);$i++){
    if (exists $info{$contigname}{"adaptor_$m8_header[$i]"}){
      print OUT "\t",$info{$contigname}{"adaptor_$m8_header[$i]"};
    }else{
      print OUT "\tNULL";
    }
  }
  for ($i=1; $i<scalar(@m8_header);$i++){
    if (exists $info{$contigname}{"diamond_$m8_header[$i]"}){
      print OUT "\t",$info{$contigname}{"diamond_$m8_header[$i]"};
    }else{
      print OUT "\tNULL";
    }
  }
  for ($i=1; $i<scalar(@m8_header);$i++){
    if (exists $info{$contigname}{"blast_$m8_header[$i]"}){
      print OUT "\t",$info{$contigname}{"blast_$m8_header[$i]"};
    }else{
      print OUT "\tNULL";
    }
  }
  for ($i=1; $i<scalar(@entropy_header);$i++){
    if (exists $info{$contigname}{"$entropy_header[$i]"}){
      print OUT "\t",$info{$contigname}{"$entropy_header[$i]"};
    }else{
      print OUT "\tNULL";
    }
  }
  for ($i=1; $i<scalar(@mapped_header);$i++){
    if (exists $info{$contigname}{"$mapped_header[$i]"}){
      print OUT "\t",$info{$contigname}{"$mapped_header[$i]"};
    }else{
      print OUT "\tNULL";
    }
  }
  print OUT "\n";
}

#print "$adaptor $diamond $blast $entropy $mapped\n";  
#print "@m8_header\n@entropy_header\n@mapped_header\n"

