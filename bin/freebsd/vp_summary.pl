#!/usr/bin/env perl
#
# vp_summary.pl --- summarize "vp" (view pf log) output.
#

use strict;
use vars qw($opt_d);
use Getopt::Std;

my $type;
my $pattern;
my $srcflag;
my %db;
my %hostdb;

sub usage_exit{
    print "usage: vpls [-dw] [pass|allow  | block|deny | all|any]\n";
    exit 1;
}

sub gethostname{
    my($ipaddr) = @_;
    if(exists $hostdb{$ipaddr}){
        return $hostdb{$ipaddr};
    }else{
        my $name = gethostbyaddr(pack("C4", split(/\./, $ipaddr)), 2);
        $hostdb{$ipaddr} = $name;
        return $name;
    }
}

getopts('d');
$srcflag = '%-23.23s';


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
    if(/($pattern)[^:]+(in|out) on ([^:]+): (\d+\.\d+\.\d+\.\d+)\.?(\d+)? > (\d+\.\d+\.\d+\.\d+)\.?(\d+)?: (.*)/){
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

