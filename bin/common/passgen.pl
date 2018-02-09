#!/usr/bin/env perl
use strict;
my $DEFAULT_LENGTH = 12;
my $MINIMUM_LENGTH = 4;

my $length = shift @ARGV || $DEFAULT_LENGTH;

if( $length < $MINIMUM_LENGTH ){
    print STDERR "Length $length is too short. Minimum allowed length is $MINIMUM_LENGTH.\n";
    exit(1);
}

print map { ("A" .. "Z", "a" .. "z", 0 .. 9, qw(! # % & + , - . / : ; < = > ? @ ^ _ ~))[rand 81] } 1 .. $length;
print "\n";

