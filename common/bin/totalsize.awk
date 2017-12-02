#!/usr/bin/awk -f
#
# totalsize.awk [f=fieldnum] [quiet=1]
#   fieldnum defaults to 1.
#

BEGIN {
	B = 1024 ** 0;
	K = 1024 ** 1;
	M = 1024 ** 2;
	G = 1024 ** 3;
	T = 1024 ** 4;
	P = 1024 ** 5;
}
{
	if(f >= 1){
		if(f <= NF){
			val = $(f);
		}else{
			val = 0;
		}
	}else{
		val = $1
	}
	if(! (noprint || quiet)){
		print;
	}
}
val ~ /^[0-9.]+ *$/  { sum += val * B }
val ~ /^[0-9.]+ *[kK]$/ { sum += val * K }
val ~ /^[0-9.]+ *[mM]$/ { sum += val * M }
val ~ /^[0-9.]+ *[gG]$/ { sum += val * G }
val ~ /^[0-9.]+ *[tT]$/ { sum += val * T }
val ~ /^[0-9.]+ *[pP]$/ { sum += val * P }
END {
	if(sum < K){
		printf("%.2f B in total\n", sum / B);
	}else if(sum < M){
		printf("%.2f KB in total\n", sum / K);
	}else if(sum < G){
		printf("%.2f MB in total\n", sum / M);
	}else if(sum < T){
		printf("%.2f GB in total\n", sum / G);
	}else if(sum < P){
		printf("%.2f TB in total\n", sum / T);
	}else{
		printf("%.2f PB in total\n", sum / P);
	}
}
