#!/bin/sh
if [ -f "$HOME/$DOTLOCAL/tmux.conf" ]; then
	tmux source-file "$HOME/$DOTLOCAL/tmux.conf"
fi

