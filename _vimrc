set encoding=utf-8
set termencoding=utf-8
set fileencodings=utf-8,euc-jp,cp932,iso-2022-jp
set fileformats=unix,dos,mac
set t_Co=256
set ambiwidth=double

" Color Chart
" http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
augroup customize_colorscheme
	autocmd!
	" Make Markdown Code Delimiter more readable
	" autocmd ColorScheme * highlight markdownCodeDelimiter guifg=#00ff00 ctermfg=46 cterm=bold gui=bold
	" Make a global color 'Special' more readable
	autocmd ColorScheme * highlight Special guifg=#afff87 ctermfg=156 cterm=bold gui=bold
augroup END
"set background=light
colorscheme railscasts

filetype plugin indent on
syntax enable
set tabstop=8
set noexpandtab
set shiftwidth=8
set softtabstop=8
set noautoindent
set nosmartindent

" Prevent xfce4-terminal title gets longer and longer
set notitle

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

"
" :SyntaxInfo utility function by cohama
" http://cohama.hateblo.jp/entry/2013/08/11/020849
"
function! s:get_syn_id(transparent)
	let synid = synID(line("."), col("."), 1)
	if a:transparent
		return synIDtrans(synid)
	else
		return synid
	endif
endfunction
function! s:get_syn_attr(synid)
	let name = synIDattr(a:synid, "name")
	let ctermfg = synIDattr(a:synid, "fg", "cterm")
	let ctermbg = synIDattr(a:synid, "bg", "cterm")
	let guifg = synIDattr(a:synid, "fg", "gui")
	let guibg = synIDattr(a:synid, "bg", "gui")
	return {
				\ "name": name,
				\ "ctermfg": ctermfg,
				\ "ctermbg": ctermbg,
				\ "guifg": guifg,
				\ "guibg": guibg}
endfunction
function! s:get_syn_info()
	let baseSyn = s:get_syn_attr(s:get_syn_id(0))
	echo "name: " . baseSyn.name .
				\ " ctermfg: " . baseSyn.ctermfg .
				\ " ctermbg: " . baseSyn.ctermbg .
				\ " guifg: " . baseSyn.guifg .
				\ " guibg: " . baseSyn.guibg
	let linkedSyn = s:get_syn_attr(s:get_syn_id(1))
	echo "link to"
	echo "name: " . linkedSyn.name .
				\ " ctermfg: " . linkedSyn.ctermfg .
				\ " ctermbg: " . linkedSyn.ctermbg .
				\ " guifg: " . linkedSyn.guifg .
				\ " guibg: " . linkedSyn.guibg
endfunction
command! SyntaxInfo call s:get_syn_info()

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
