#!/usr/bin/env perl
#
# vp_summary.pl --- summarize "vp" (view pf log) output.
#

use strict;
use vars qw($opt_d $opt_p $opt_P);
use Getopt::Std;
use Socket qw(getaddrinfo getnameinfo);

my $type;
my $pattern;
my $srcflag;
my %db;
my %hostdb;

sub usage_exit{
    print "usage: vp_summary.pl [-d] [-p dstport] [-P srcport] [pass|allow  | block|deny | all|any]\n";
    exit 1;
}

sub gethostname{
    my($ipaddr) = @_;
    if(exists $hostdb{$ipaddr}){
        return $hostdb{$ipaddr};
    }else{
        my($e1, @r) = getaddrinfo($ipaddr);
        return $ipaddr if $e1 or scalar(@r) < 1;
        my($e2, $name) = getnameinfo($r[0]{addr});
        return $ipaddr if $e2;
        $hostdb{$ipaddr} = $name;
        return $name;
    }
}

getopts('dp:P:');
$srcflag = '%-23s';


$type = $ARGV[0] ? $ARGV[0] : "block";

if($type =~ /^(all|any)$/i){
    $pattern="pass|rdr|block";
}elsif($type =~ /^(pass|allow)$/i){
    $pattern="pass|rdr";
}elsif($type =~ /^(block|deny)$/i){
    $pattern="block";
}else{
    usage_exit;
}

while(<STDIN>){
    chomp;
    if(/($pattern)[^:]+(in|out) on ([^:]+): (\d+\.\d+\.\d+\.\d+|[0-9a-f:]+)\.?(\d+)? > (\d+\.\d+\.\d+\.\d+|[0-9a-f:]+)\.?(\d+)?: (.*)/){
        my($action, $dir, $if, $srcip, $srcport, $dstip, $dstport, $extra) = ($1,$2,$3,$4,$5,$6,$7,$8);
        my($service, $srchost, $proto);
        $action = substr($action, 0, 1);
        $action =~ tr/a-z/A-Z/;
        $dir = substr($dir, 0, 1);

        if($extra =~ /(tcp|udp|esp|ah|icmp|igmp|vrrp)/i){
            $proto = $1;
        }elsif($extra =~ /(flags|sip)/i){
            $proto = "tcp";
        }elsif($extra =~ /(l2tp|smb|bootp|getrequest|setrequest|getnextrequest|getbulkrequest|response|trap|informrequest|ntp)/i){
            $proto = "udp";
        }else{
            $proto = $extra;
            $proto =~ s/\[\|//;
            $proto =~ s/\]//;
        }
        $proto =~ tr/A-Z/a-z/;

        if($dstport > 0){
            $dstip = "$dstip:$dstport";
            $service = getservbyport($dstport,$proto);
        }
        $proto =~ tr/a-z/A-Z/;

        if($opt_p){
            next unless $opt_p == $dstport;
        }
        if($opt_P){
            next unless $opt_P == $srcport;
        }

        if($opt_d){
            $srchost = gethostname($srcip);
            $srchost = $srcip unless $srchost;
            $db{"$action,$dir,$if,$srchost,$dstip,$proto,$service"}++;
        }else{
            $db{"$action,$dir,$if,$srcip,$dstip,$proto,$service"}++;
        }
    }
}

foreach my $entry (sort {$db{$b} <=> $db{$a}} keys %db){
    printf("%4d %1s%1s $srcflag\t> %-21s\t%s\t%s\n", $db{$entry}, (split(/,/, $entry))[0,1,3,4,5,6]);
}

