#!/usr/bin/env perl

while($numstr = shift @ARGV){
    $num = eval($numstr);
    printf("%d (0x%x : 0%o)\n", $num, $num, $num);
}

