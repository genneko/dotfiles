#!/usr/bin/env perl

($op=shift) || die "Usage: $0 perlexpr [filenames]\n";
if (!@ARGV){
    @ARGV = <STDIN>;
    chop (@ARGV);
}
for (@ARGV){
    $was = $_;
    eval $op;
    die $@ if $@;
    rename($was,$_) unless $was eq $_;
}

