" NB: see https://neovim.io/doc/user/vim_diff.html for list of nvim defaults 

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

" automatically scroll the window if this many lines are not visible
" vertically and to the side
set scrolloff=2
set sidescrolloff=5

" 1) show as much of current line as possible
" 2) only scroll messages (not whole screen) when messages don't fit
" 3) display unprintable chars as <xx> rather than ^C and ~C
set display+=lastline,msgsep,uhex

" render more unprintable characters in list views
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

" formatting config (:h fo-table):
" t to wrap text to textwidth
" c to wrap comments to textwidth
" q to allow formatting comments with gq
" j to remove comment chars when joining lines
set formatoptions=tcqj

" auto reload vim configuration when it gets changed
augroup AutoReloadVimConfigOnInitVimChange
  autocmd!
  autocmd BufWritePost init.vim so $MYVIMRC
augroup END

" default (anti-)tab settings
" set tab width
set tabstop=4
set softtabstop=4
" set indent
set shiftwidth=4
" enable autoindent
set autoindent
set expandtab

" line numbering (:set nu/nonu and rnu/nornu)
set number
" set relativenumber

" make substitute commands display live previews
set inccommand=nosplit

" make searches case insensitive unless they have uppercase in them
set ignorecase
set smartcase

" briefly jump the cursor to a matching bracket as visual show of which
" bracket matches the one just typed
set showmatch

" add angle brackets as pairs known by the matchit plugin
set matchpairs+=<:>

" allow buffer to be moved to background without forgetting anything about it
set hidden

" make cursor position more prominent for the active window
set cul
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

" swap ' and ` so that ' is position-based mark jumping
nnoremap ' `
nnoremap ` '

" set space as my leader key (by actually setting space to the default leader
" - this roundabout approach means that \ shows up as part of showcmd in
"   bottom right corner)
map <SPACE> <leader> 
" and set backspace as local leader
let maplocalleader = "\<BS>"

set timeoutlen=500

call plug#begin(stdpath('data') . '/plugged')

Plug 'joshdick/onedark.vim'

Plug 'itchyny/lightline.vim'

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'machakann/vim-highlightedyank'

Plug 'editorconfig/editorconfig-vim'

Plug 'unblevable/quick-scope'

Plug 'tpope/vim-surround'

Plug 'liuchengxu/vim-which-key'

call plug#end()

" configure vim-plug to install plugins on startup and init.vim save
augroup VimPlugAutoInstallOnStartup
    autocmd!
    autocmd VimEnter *
                \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
                \|   PlugInstall --sync | q
                \| endif
augroup END
augroup VimPlugAutoInstallOnInitVimWrite
    autocmd!
    autocmd BufWritePost init.vim PlugInstall --sync | q
augroup END

" configure joshdick/onedark.vim
colorscheme onedark

" configure itchyny/lightline.vim
let g:lightline = { 'colorscheme': 'one' }

" configure machakann/vim-highlightedyank
let g:highlightedyank_highlight_duration = 150

" configure liuchengxu/vim-which-key
" since space is a "fake leader", we bind to it directly as well as to our
" real leader
nnoremap <silent> <Space> :WhichKey '\'<CR>
nnoremap <silent> <leader> :WhichKey '\'<CR>
nnoremap <silent> <localleader> :WhichKey '\<BS>'<CR>

" TODO flesh out these keymappings some more
nnoremap <leader>fs :w<CR>
nnoremap <leader>qq :q<CR>
nnoremap <localleader>nn :echo "hi"<CR>


" TODO
" consider https://github.com/norcalli/nvim-colorizer.lua
" https://github.com/mg979/vim-visual-multi
" make reloading init.vim display message, but not initial load
" add editorconfig support
" consider https://github.com/jeffkreeftmeijer/neovim-sensible
" lsp support: https://old.reddit.com/r/vim/comments/7lnhrt/which_lsp_plugin_should_i_use/
" consider https://github.com/mhinz/neovim-remote for opening nvim from within terminal of nvim
" https://github.com/mbbill/undotree
" https://github.com/plasticboy/vim-markdown
" nerd commenter

" see also:
" https://learnvimscriptthehardway.stevelosh.com/
" https://vimawesome.com/
" mine https://github.com/SpaceVim/SpaceVim for ideas
" https://vimways.org/2018/
" https://romainl.github.io/the-patient-vimmer/1.html
" https://github.com/HugoForrat/LaTeX-Vim-User-Manual

echo "init.vim loaded!"
