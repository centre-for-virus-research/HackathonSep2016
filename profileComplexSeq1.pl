#!/usr/bin/perl -w
use strict;
use SeqComplex1;

=head1 NAME

profileComplexSeq.pl FASTA

=head1 DESCRIPTION

Script to calculate complexities and compositions for each sequence
in a fasta file.

=cut

my @methods = qw/gc gcs cpg cwf ce cz/;

# Load fasta file
$ARGV[0] or die "Usage: profileComplexSeq.pl FASTA\n";
my $fasta = shift @ARGV;
my %seqs  = ();
readFasta( $fasta );
my $tot   = 0;
foreach my $k (keys %seqs) { $tot++; }
print "$tot sequences readed\n";

# Create output file
my $complex = $fasta;
$complex =~ s/.gz$//;
$complex =~ s/.bz2$//;
$complex =~ s/f[na].*$/complex/;

# If input has unusual ext, ensure original file isn't overwritten
$complex ne $fasta or $complex = $fasta . ".complex";
open O, ">$complex" or die "cannot open $complex\n";

# Print header
print O "seq";
foreach my $m (@methods) { print O "\t$m"; }
print O "\n";

# Main process
my $cnt  = 0;
my $step = int($tot / 10) + 1;
print "Processing data: ";
foreach my $sid (keys %seqs) {
	$cnt++;
	print "." if($cnt % $step == 0);
	my %results = runAllMethods($seqs{$sid});
	print O "$sid";
	foreach my $m (@methods) {
		my $val = shift @{ $results{$m} };
		print O "\t$val";
	}
	print O "\n";
}
print "\nDone.\n";

=head1 SUBROUTINES

=cut

sub readFasta {
    my $file = shift @_;
    my $fh   = $file;
    $fh = "gunzip  -c $file | " if ($file =~ m/.gz$/);
    $fh = "bunzip2 -c $file | " if ($file =~ m/.bz2$/);
	open F, "$fh" or die "cannot open $file\n";
	my $id = '';
	while (<F>) {
		chomp;
		if (/>/) { s/>//; $id = $_;     }
		else     { $seqs{$id} .= uc $_; }
	}
	close F;
}

=head1 AUTHOR

Juan Caballero
Institute for Systems Biology @ 2008

=head1 CONTACT

jcaballero@systemsbiology.org

=head1 LICENSE

<PUT LICENSE HERE>

=cut
