#!/bin/sh
#
# install.sh - backup and symlink dot files to the home directory.
#
progname=$(basename $0)
basedir=$(dirname $(readlink -f $0))
DOTFILES=$(basename $basedir)
DOTBASE="$HOME/$DOTFILES"
BACKDIR="$HOME/.${DOTFILES}.bak/$(date '+%Y-%m-%d-%H%M%S')"

if [ "$DOTBASE" != "$basedir" ]; then
	echo "Error: '$DOTFILES' must be in the root of your home directory"
	echo "       ($HOME/$DOTFILES)."
	exit 1
fi

_mkcopy(){
	cp -vpr "$1" "$2"
}

_mklink(){
	ln -sf "$1" "$2" && echo "'$2' -> '$1'"
}

dot_install(){
	local realname=$1
	local origname=$(echo "$realname" | sed -r 's/^\./_/')
	local operation=$2

	cd $HOME 
	if [ -e "$realname" ]; then
		rm -fr "$realname"
	fi

	if [ "$operation" = "copy" ]; then
		_mkcopy "$DOTFILES/$origname" "$realname" |
			xargs -I OUTPUT echo "INSTALL(cp): OUTPUT"
	else
		_mklink "$DOTFILES/$origname" "$realname" |
			xargs -I OUTPUT echo "INSTALL(ln): OUTPUT"
	fi

	cd $DOTBASE
}

dot_backup(){
	local realname=$1
	local backname=$(echo "$realname" | sed -r 's/^\./_/')

	if [ -e "$HOME/$realname" -a ! -L "$HOME/$realname" ]; then
		if [ ! -e "$BACKDIR" ]; then
			echo "Creating backup directory..."
			mkdir -p "$BACKDIR"
		fi
		cp -vpr "$HOME/$realname" "$BACKDIR/$backname" |
			xargs -I OUTPUT echo "BACKUP(cp): OUTPUT"
	else
		:
	fi
}

usage_exit(){
	echo "usage: $progname [-ch]"
	echo "       -c: install dot files by copying instead of symlinking."
	echo "       -h: show this message."
	exit 1
}

op="link"
while getopts "ch" opt
do
	case "$opt" in
		c) op="copy" ;;
		h) usage_exit ;;
		*) usage_exit ;;
	esac
done
shift $(( $OPTIND - 1 ))

if [ -d "$DOTBASE" ]; then
	origdir=$(pwd)
	cd "$DOTBASE"

	#	git submodule update -i

	for f in _*; do
		realname=$(echo "$f" | sed -r 's/^_/\./')
		if dot_backup "$realname"; then
			dot_install "$realname" $op
		else
			echo "backup failed."
		fi
	done

	cd "$origdir"
fi
