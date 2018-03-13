#!/usr/bin/env perl
use strict;
use Getopt::Std;
use vars qw($opt_c $opt_l $opt_t $opt_v $opt_u);

my $DEFAULT_LENGTH = 12;
my $MINIMUM_LENGTH = 4;

my @CLASS_UPPER = ("A" .. "Z");
my @CLASS_LOWER = ("a" .. "z");
my @CLASS_DIGIT = ("0" .. "9");
my @CLASS_SYMBOL = qw(! # % & + , . / : ; < = > ? @ ^ ~);
my @CLASS_SYMBOL_MIN = qw(- _);

sub rmarrayelem;
sub tweakclasses;
sub classes2chars;
sub uniq;
sub checkclasses;

if(! getopts("l:t:c:vu")){
    print STDERR "usage: $0 [-v] [-u] [-l length] [-t type] [-c optchars]\n";
    print STDERR "       type can be alnum, word or full(default).\n";
    exit(0);
}

my $length = $opt_l || $DEFAULT_LENGTH;
if( $length < $MINIMUM_LENGTH ){
    print STDERR "Length $length is too short. Minimum allowed length is $MINIMUM_LENGTH.\n";
    exit(1);
}

my @classes;
if($opt_t =~ /^alnum/i){
    @classes = (\@CLASS_UPPER, \@CLASS_LOWER, \@CLASS_DIGIT);
}elsif($opt_t =~ /^word/i){
    @classes = (\@CLASS_UPPER, \@CLASS_LOWER, \@CLASS_DIGIT, \@CLASS_SYMBOL_MIN);
}else{
    @classes = (\@CLASS_UPPER, \@CLASS_LOWER, \@CLASS_DIGIT, \@CLASS_SYMBOL);
}
if($opt_u){
    tweakclasses("O01l", @classes);
}
my @chars = classes2chars(@classes);

my @addchars = ();
if($opt_c){
    my $tmplen = scalar(@chars);
    @addchars = split(//, $opt_c);
    @chars = (uniq(@chars, @addchars));
    my @tmpchars = @chars;
    splice(@tmpchars, 0, $tmplen);
    if($opt_t =~ /^alnum/i){
        push(@classes, \@tmpchars);
    }else{
        push(@{$classes[-1]}, @tmpchars);
    }
}

if($opt_v){
    printf STDERR ("Using %d chars: %s\n", scalar(@chars), join(" ", @chars));
    printf STDERR ("Char classes:\n");
    foreach my $class (@classes){
        printf STDERR ("  %s\n", join(" ", @$class));
    }
    printf STDERR ("Password Length: %d\n", $length);
}

my $iter = 0;
my $password = "";
do{
    $iter++;
    $password = join "", map { @chars[rand scalar(@chars)] } 1 .. $length;
    printf STDERR ("%03d: Trying %s ...\n", $iter, $password) if $opt_v;
}until(checkclasses($password, @classes));
print "$password\n";

sub classes2chars{
    my(@classes) = @_;
    my @chars;
    foreach my $class (@classes){
        push(@chars, @$class);
    }
    return @chars;
}

sub uniq{
    my @orig = @_;
    my %hash;
    my @new;
    foreach my $c (@orig){
        next if($hash{$c});
        $hash{$c}++;
        push(@new, $c);
    }
    return @new;
}

sub rmarrayelem{
    my($elem, $arrayref) = @_;
    if(ref($arrayref) eq "ARRAY"){
        for(my $i = 0; $i < @$arrayref; $i++){
            if($arrayref->[$i] eq $elem){
                splice(@$arrayref, $i, 1);
                return 1;
            }
        }
    }
    return 0;
}

sub tweakclasses{
    my($chars, @classes) = @_;
    my $count;
    foreach my $class (@classes){
        foreach my $char (split(//, $chars)){
            $count = $count + rmarrayelem($char, $class);
        }
    }
    return $count;
}

sub checkclasses{
    my($text, @classes) = @_;
    my $count;
    foreach my $class (@classes){
        $count = grep { index($text, $_) >= 0 } @$class;
        if($opt_v){
            printf STDERR ("  count=%d: %s\n", $count, join(" ", @$class));
        }
        return 0 if $count == 0;
    }
    return 1;
}

