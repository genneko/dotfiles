#!/usr/bin/env perl
use strict;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use ExtUtils::Installed;

my $o_with_package;
my $o_loose_match;
my $o_orphan_only;
my $o_help;
Getopt::Long::Configure("bundling");
GetOptions(
    "with-package|p" => \$o_with_package,
    "loose-match|l" => \$o_loose_match,
    "orphan-only|o" => \$o_orphan_only,
    "help|h" => \$o_help,
);
usage_exit() if $o_help;
$o_with_package = 1 if $o_orphan_only or $o_loose_match;


my $inst = ExtUtils::Installed->new();
my @modules = $inst->modules();

my @packages = get_package_list();
my %packagemap = map_simple_to_original(@packages);
my($pkgname, @matched);

foreach my $m (@modules){
    next if $m =~ /^(Perl|install)$/;

    if($o_with_package){
        $pkgname = $m;
        $pkgname =~ s/::perl$//;
        $pkgname =~ s/Image::Magick/ImageMagick/;
        $pkgname =~ s/libintl-perl/libintl/;
        $pkgname =~ s/::/-/g;
        if($o_loose_match){
            @matched = grep { $_ =~ /\b${pkgname}/i } keys %packagemap;
        }else{
            @matched = grep { $_ =~ /\b${pkgname}$/i } keys %packagemap;
        }
        if($o_orphan_only){
            print "$m\n" if @matched == 0;
        }else{
            print "$m\t";
            print join(",", (map { $packagemap{$_} } @matched)) . "\n";
        }
    }else{
        print "$m\n";
    }
}

sub usage_exit{
    print <<EOB;
usage: $0 [OPTIONS]
shows the list of perl modules installed on a system.
available OPTIONS are:
  -p, --with-packages: also shows the package providing each module.
  -l, --loose-match: search packages more loosely. implies -p.
  -o, --orphan-only: shows only modules without related packages. implies -p.
  -h, --help: shows this help.

EOB
    exit(0);
}

sub get_package_list{
    my $output = `pkg info -q 2> /dev/null`;
    my @list = split(/\n/, $output);
    return @list;
}

sub map_simple_to_original{
    my(@origlist) = @_;
    my %list;
    my $origname;
    for(@origlist){
        $origname = $_;
        s/^.*p5-//;
        s/-[0-9,\._]+$//;
        s/-Utils$/-Util/;
        $list{$_} = $origname;
    }
    return %list;
}
