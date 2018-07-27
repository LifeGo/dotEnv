set nocompatible
set number
set tabstop=4
set shiftwidth=4
set history=50
set autoindent
set smartindent
set showmatch
set incsearch
set hlsearch
set nowrap
set background=dark

set cursorline
highlight CursorLine   cterm=NONE ctermbg=darkgray ctermfg=NONE "guibg=lightgrey guifg=white
"highlight LineNr ctermfg=grey

syntax enable
syntax on
"color dracula

let Tlist_Ctags_Cmd = "/usr/bin/ctags"
let Tlist_Use_Right_Window=1

map <C-P> : cp <CR>
map <C-N> : cn <CR>

map <F8> : TlistToggle <CR>
map <F9> : BufExplorer <CR>

if has("cscope")
	set csprg=/usr/bin/cscope
	set csto=0
	set cst
	set nocsverb

	" add any database in current directory
	if filereadable("cscope.out")
		cs add cscope.out
		" else add database pointed to by environment
		elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif
	set csverb
	set cscopetag
	set cscopequickfix=s-,g-,c-,d-,t-,e-,f-,i-
endif
