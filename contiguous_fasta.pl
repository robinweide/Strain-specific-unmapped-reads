#!/usr/bin/perl

# contiguous_fasta.pl -- splits fasta-formatted files into contiguous
# sequences of non-ambiguous bases

# Author: David Eccles (gringer) 2011 <david.eccles@mpi-muenster.mpg.de>

use warnings;
use strict;

my $id = "";

my $lineCount = 0;
my $goodCount = 0;

my $allSequence = "";
my @sequences = ();

my $minLength = 0;
if(@ARGV && ($ARGV[0] eq '-min')){
    shift(@ARGV);
    $minLength = shift(@ARGV);
}

print(STDERR "Splitting sequences into contiguous non-ambiguous sequences...");

while(<>){
    if(++$lineCount % 10 ** 6 == 0){
        print(STDERR " ");
    }
    chomp;
    if(substr($_,0,1) eq ">"){
        my $newID = $_;
        if($allSequence){
            @sequences = split(/N+/, $allSequence);
            $allSequence = "";
            my $seqNum = 0;
            foreach my $sequence (@sequences){
                if(++$goodCount % 10 ** 6 == 0){
                    print(STDERR ".");
                }
                if(!$minLength || (length($sequence) > $minLength)){
                    print("$id/".$seqNum++."\n$sequence\n");
                }
            }
        }
        $id = $newID;
    } else {
        $allSequence .= $_;
    }
}

if($allSequence){
    @sequences = split(/N+/, $allSequence);
    my $seqNum = 0;
    foreach my $sequence (@sequences){
        if($minLength && (length($sequence) > $minLength)){
            print("$id/".$seqNum++."\n$sequence\n");
        }
    }
}

print(STDERR " done\n");
