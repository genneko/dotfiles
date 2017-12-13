#!/usr/bin/env perl
#
# vhd_summary.pl --- summarize "vhd" (view hosts denied) output.
#
use strict;
use Getopt::Std;
use Time::Piece;
use Time::Local;
use vars qw($opt_f $opt_h);

if(!getopts('fh:')){
    print STDERR <<EOB;
usage: $0 [-f] [h HOSTNAME]
    -f: full-mode. shows all entries.
    -h HOSTNAME: specify hostname (default: hostname -s)
EOB
    exit 1;
}

my $MYHOST = `hostname -s`;
chomp($MYHOST);
$MYHOST = $opt_h if $opt_h;
my $MYDOMAIN = `/usr/local/sbin/postconf -h mydomain`;
chomp($MYDOMAIN);
print "[${MYHOST}.${MYDOMAIN}]\n" unless $opt_f;

my $now = localtime;
my $curyear = $now->year;

my @bstat = stat($ENV{'HOME'} . "/etc/bandits");
my $bage = $bstat[9];
my $bt = localtime($bage);
print "bandits age = $bage (" . $bt->ymd . " " . $bt->hms . ")\n" unless $opt_f;
print "current time= " . $now->epoch . " (" . $now->ymd . " " . $now->hms . ")\n" unless $opt_f;

my %MON = qw(JAN 1 FEB 2 MAR 3 APR 4 MAY 5 JUN 6 JUL 7 AUG 8 SEP 9 OCT 10 NOV 11 DEC 12);
my $curmonth = $now->month;
$curmonth =~ tr/a-z/A-Z/;

while(<>){
    if($opt_f){
        print;
        next;
    }
    if(/^(\w+\s+\d+\s+\d+:\d+:\d+) sshd (\S+) \((\S+)\)/){
        my $falsep;
        my($date,$host,$addr) = ($1,$2,$3);
        my $month = $date;
        $month =~ s/\s+.*//;
        $month =~ tr/a-z/A-Z/;
        my $year = $curyear;
        if($MON{$month} > $MON{$curmonth}){
            $year--;
        }
        my $t = Time::Piece->strptime($date . " " . $year, "%b %d %T %Y");
        my $tage = $t->epoch - 3600*9;
        my $op;
        if($tage < $bage){
            $op = "<";
        }elsif($tage == $bage){
            $op = "=";
        }else{
            $op = "<";
        }
        next if(!$opt_f && $tage < $bage);
        my $iffstatus = "unknown";
        my $iff = `echo $addr | excl_friendip`;
        if($iff =~ /$addr/){
            $iffstatus = "e";
        }else{
            $iffstatus = "F";
        }
        if($host =~ /\.jp$/i || $host =~ /wakwak\.com$/i){
            $falsep = 1;
        }else{
            $falsep = 0;
        }
        printf("%s%s %s", ($falsep ? "!" : " "), ($iffstatus eq "F" ? $iffstatus : " "), $_);
    }
}
