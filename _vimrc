set encoding=utf-8
set termencoding=utf-8
set fileencodings=utf-8,euc-jp,cp932,iso-2022-jp
set fileformats=unix,dos,mac
set t_Co=256
colorscheme railscasts
filetype plugin indent on
syntax enable
set tabstop=8
set noexpandtab
set shiftwidth=8
set softtabstop=8
set noautoindent
set nosmartindent
augroup auto_comment_off
	autocmd!
	autocmd BufEnter * setlocal formatoptions-=r
	autocmd BufEnter * setlocal formatoptions-=o
augroup END
