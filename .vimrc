" BEGIN Inlined vim-sensible: https://github.com/tpope/vim-sensible/blob/master/plugin/sensible.vim
if has('autocmd')
  filetype plugin indent on
endif
if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif

set autoindent
set backspace=indent,eol,start
set complete-=i
set smarttab

set nrformats-=octal

if !has('nvim') && &ttimeoutlen == -1
    set ttimeout
    set ttimeoutlen=100
endif

set incsearch
" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

set laststatus=2
set ruler
set wildmenu

if !&scrolloff
  set scrolloff=1
endif
if !&sidescrolloff
  set sidescrolloff=5
endif
set display+=lastline

if &encoding ==# 'latin1' && has('gui_running')
  set encoding=utf-8
endif

if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j " Delete comment character when joining commented lines
endif

if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif

if &shell =~# 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
  set shell=/usr/bin/env\ bash
endif

set autoread

if &history < 1000
  set history=1000
endif
if &tabpagemax < 50
  set tabpagemax=50
endif
if !empty(&viminfo)
  set viminfo^=!
endif
set sessionoptions-=options
set viewoptions-=options

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^Eterm'
  set t_Co=16
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

if empty(mapcheck('<C-U>', 'i'))
  inoremap <C-U> <C-G>u<C-U>
endif
if empty(mapcheck('<C-W>', 'i'))
  inoremap <C-W> <C-G>u<C-W>
endif

" END of inlined vim-sensible

" auto reload vim configuration when it gets changed
augroup myvimrc
  au!
  au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

"enable syntax highlighting
syntax on

"set tab width
set tabstop=4
set softtabstop=4
"set indent
set shiftwidth=4
"enable autoindent
set autoindent
set expandtab

"show the line number"
set number 

" case insensitive search
set ignorecase

" show matching brackets
" set showmatch

" recognise angle brackets as matching pairs
set matchpairs+=<:>

try
  if has('gui_running')
    set background=light
    colorscheme solarized
  else
    set background=dark
    colorscheme solarized
  endif
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme desert
endtry

"apparently necessary for lots of cool vim things
set nocompatible

"shows what you are typing as a command
set showcmd

"highlight things we find with search
set hlsearch
" allow current search results to be cleared with :C
:command! C let @/=""

" when i close a tab, remove the buffer
"set nohidden
" actually, let's use hidden buffers
set hidden

" make backups not go into the directory the files are in
function! Mkdir(name)
  let l:expanded = expand(a:name)
  if "" == getftype(l:expanded)
    call mkdir(l:expanded, "p")
  endif
  return "dir" == getftype(l:expanded)
endfunction

if Mkdir("~/tmp/.vim/backup")
  set backupdir=~/tmp/.vim/backup//
  set backup
else
  echoerr "Cannot make backup directory - backups are off"
endif
if Mkdir("~/tmp/.vim/swap")
  set directory=~/tmp/.vim/swap//
else
  echoerr "Cannot make swap directory - swap is off"
endif
if v:version >= 703
  if Mkdir("~/tmp/.vim/undo")
    set undodir=~/tmp/.vim/undo//
    set undofile
  else
    echoerr "Cannot make undo directory - persistent undo is off"
  endif
endif

" highlight current line and adjust the color
" set cul
" hi CursorLine term=none cterm=none ctermbg=1

" keep at least 5 lines above/below and to the side
set scrolloff=5
set sidescrolloff=5

" menu has tab completion
set wildmode=longest:full
set wildmenu

let g:netrw_list_hide='.*\.pyc$'
let g:netrw_liststyle=3

let g:miniBufExplMapCTabSwitchBufs = 1

" Fast window resizing with +/- keys (horizontal); / and * keys (vertical)
if bufwinnr(1)
  map <kPlus> <C-W>+
  map <kMinus> <C-W>-
  map <kDivide> <c-w><
  map <kMultiply> <c-w>>
endif

" vim-markdown: https://github.com/plasticboy/vim-markdown
" disable folding
let g:vim_markdown_folding_disabled=1

" make cursor position more prominent for the active window
augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END
augroup CursorColumn
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorcolumn
  au WinLeave * setlocal nocursorcolumn
augroup END
" make cursor column & line highlightting more visible
hi CursorColumn ctermbg=235
hi CursorLine ctermbg=235
