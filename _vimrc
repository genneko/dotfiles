set encoding=utf-8
set termencoding=utf-8
set fileencodings=utf-8,euc-jp,cp932,iso-2022-jp
set fileformats=unix,dos,mac
set t_Co=256
set ambiwidth=double
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
augroup freebsd_source_specific
	autocmd!
	autocmd BufNew,BufReadPre /usr/src/*
		\ if filereadable("/usr/src/tools/tools/editing/freebsd.vim")
		\ | filetype plugin indent off
		\ | source /usr/src/tools/tools/editing/freebsd.vim
		\ | set autoindent
		\ | set smartindent
		\ | endif
augroup END
" https://qiita.com/unosk/items/43989b61eff48e0665f3
" https://vim-jp.org/vimdoc-en/eval.html
augroup vimrc_local_override
	autocmd!
	autocmd BufNewFile,BufRead * call s:vimrc_local(expand('<afile>:p:h'))
augroup END
function! s:vimrc_local(loc)
	let files = findfile('.vimrc.local', escape(a:loc, ' ') . ';', -1)
	for i in reverse(filter(files, 'filereadable(v:val)'))
		source `=i`
	endfor
endfunction
if filereadable($HOME . "/local/dotfiles/vimrc")
	source $HOME/local/dotfiles/vimrc
endif
