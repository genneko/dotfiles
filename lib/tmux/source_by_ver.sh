#!/bin/sh
if $(tmux -V | awk '{if($2 >= 2.4){ exit 0 }else{ exit 1 }}'); then
	tmux source-file "$HOME/$DOTFILES/lib/tmux/tmux-esc-copy-mode.conf"
fi

