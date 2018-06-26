#!/bin/sh
#
# mul.sh - multiple shell
#
# Inspired by:
# http://tech.naviplus.co.jp/2014/01/09/tmux%E3%81%A7%E8%A4%87%E6%95%B0%E3%82%B5%E3%83%BC%E3%83%90%E3%81%AE%E5%90%8C%E6%99%82%E3%82%AA%E3%83%9A%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3/
#
prog=$(basename $0)

version_exit() {
	echo "$prog version 0.30"
	exit 0
}

usage_exit() {
	echo "usage: $prog [-gtis] [-VTH] [-o options] host..."
	echo "       $prog [-hv]"
	echo "       -g: use vagrant instead of ssh."
	echo "       -t: use telnet instead of ssh."
	echo "       -i: use ipmitool instead of ssh."
	echo "       -s: use ssh (default)."
	echo "       -V: vertical layout (default)."
	echo "       -T: tiled instead of vertical layout."
	echo "       -H: horizontal instead of vertical layout."
	echo "       -o: options to ssh/telnet in quotes."
	echo "       -h: show this help and exit."
	echo "       -v: show version and exit."
	exit 1
}

vagrant() {
	echo "vagrant ssh $1 $2"
}

telnet() {
	echo "telnet $1 $2"
}

ipmitool() {
	echo "ipmitool $1 -I lanplus -H $2 -U root sol activate"
}

ssh() {
	echo "ssh $1 $2"
}

exit_if_na() {
	if [ -n "$1" ]; then
		if ! which $1 > /dev/null 2>&1; then
			echo "Sorry. $1 is not available on this host."
			exit 1
		fi
	fi
}

rsh="ssh"
layout="vertical"
while getopts "gtisVTHo:hv" opt
do
	case "${opt}" in
		g)
			rsh="vagrant"
			exit_if_na $rsh
			;;
		t)
			rsh="telnet"
			exit_if_na $rsh
			;;
		i)
			rsh="ipmitool"
			exit_if_na $rsh
			;;
		s)
			rsh="ssh"
			exit_if_na $rsh
			;;
		V) layout="vertical" ;; 
		T) layout="tiled" ;; 
		H) layout="horizontal" ;; 
		o) options="$OPTARG" ;;
		h) usage_exit ;;
		v) version_exit ;;
		*) usage_exit ;;
	esac
done
shift $(( $OPTIND - 1 ))

if [ $# -lt 1 ]; then
	usage_exit
fi

workdir=$(pwd)

if [ -n "$SESSION_NAME" ];then
	session=$SESSION_NAME
else
	session=ms`date +%H%M`
fi
window=$prog

tmux new-session -d -n $window -s $session

tmux send-keys "cd $workdir" C-m
tmux send-keys "`$rsh \"$options\" $1`" C-m
shift

for i in $*
do
	tmux split-window
	if [ "$layout" = "tiled" ]; then
		tmux select-layout tiled
	elif [ "$layout" = "vertical" ]; then
		tmux select-layout even-vertical
	else
		tmux select-layout even-horizontal
	fi
	tmux send-keys "cd $workdir" C-m
	tmux send-keys "`$rsh \"$options\" $i`" C-m
done

tmux select-pane -t 0
tmux set-window-option synchronize-panes on
tmux attach-session -t $session

