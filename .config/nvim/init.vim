" NB: see https://neovim.io/doc/user/vim_diff.html for list of nvim defaults

" {{{ BEGIN vim-plugged config
call plug#begin(stdpath('data') . '/plugged')

" color schemes
Plug 'joshdick/onedark.vim'

Plug 'itchyny/lightline.vim'

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'machakann/vim-highlightedyank'

Plug 'editorconfig/editorconfig-vim'

Plug 'unblevable/quick-scope'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-unimpaired'

Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb' " github support for fugitive's Gbrowse
Plug 'tommcdo/vim-fubitive' " bitbucket support for fugitive's Gbrowse

Plug 'liuchengxu/vim-which-key'

Plug 'thirtythreeforty/lessspace.vim' " trim tailing whitespace at end of files
Plug 'ntpeters/vim-better-whitespace' " show trailing whitespace in red

Plug 'arthurxavierx/vim-caser' " case changes with gs then p (pascal), c
" (camel), _ (snake), u (upper), t (title), s (sentence), space, k (kebab), K
" (title kebab), . (dot case)

Plug 'tmux-plugins/vim-tmux-focus-events' " make focus events work in terminal

call plug#end()

" configure vim-plugged to install plugins and remove old plugins on startup
augroup VimPlugAutoInstallOnStartup
    autocmd!
    autocmd VimEnter *
                \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
                \|   PlugInstall --sync | q | PlugClean! | q
                \| endif
augroup END

" }}} END vim-plugged config

" {{{ BEGIN Basic vim options
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

" expect keystrokes for a mapped sequence to complete a bit faster
set timeoutlen=500

" turn on fancy color scheme support
set termguicolors

" turn off showing insert/visual/normal mode (expect statusline to show that)
set noshowmode

" enable undo history that persists after exiting
set undofile

" ms before saving swap and firing cursor hold autocmd (also used by various
" plugins to do things while user is idle)
set updatetime=100

" }}} END basic vim options

" {{{ BEGIN Look and feel (theme, cursor, modeline)
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

" color scheme and statusbar
colorscheme onedark
let g:lightline = { 'colorscheme': 'wombat' }

" }}} END look and feel

" {{{ Plugin configuration

" machakann/vim-highlightedyank
let g:highlightedyank_highlight_duration = 150

" ntpeters/vim-better-whitespace
let g:show_spaces_that_precede_tabs=1

" }}} END plugin configuration

" {{{ BEGIN Key bindings

" swap ' and ` so that ' is position-based mark jumping
nnoremap ' `
nnoremap ` '

" set space as my leader key
let mapleader = "\<Space>"
" and set comma as local leader
let maplocalleader = ","

" move lines up/down with alt+up/down
nnoremap <A-Up> :m .-2<CR>==
nnoremap <A-Down> :m .+1<CR>==

" liuchengxu/vim-which-key
" since space is a "fake leader", we bind to it directly as well as to our
" real leader
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :WhichKey ','<CR>
" also explain some other common "leader-like" keys
nnoremap <silent> [ :WhichKey '['<CR>
nnoremap <silent> ] :WhichKey ']'<CR>

" {{{ actual leader key mappings
nnoremap <leader><Space> :GFiles<CR>
nnoremap <leader>: :History:<CR>
nnoremap <leader>; :Commands<CR>
nnoremap <leader>/ :History/<CR>

nnoremap <leader>qq :q<CR>
nnoremap <leader>qQ :q!<CR>
nnoremap <leader>qs :x<CR>

nnoremap <leader>ww :Windows<CR>

nnoremap <leader>ff :Files<CR>
nnoremap <leader>fr :History<CR>
nnoremap <leader>fl :Locate ''<Left>
nnoremap <leader>fs :w<CR>

nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

nnoremap <leader>vv :e $MYVIMRC<CR>
nnoremap <leader>vm :Maps<CR>
nnoremap <leader>vf :Filetypes<CR>
nnoremap <leader>vh :Helptags<CR>
nnoremap <leader>vpi :PlugInstall<CR>
nnoremap <leader>vpu :PlugUpdate<CR>
nnoremap <leader>vpg :PlugUpgrade<CR>
nnoremap <leader>vps :PlugStatus<CR>
nnoremap <leader>vpd :PlugDiff<CR>
nnoremap <leader>vpc :PlugClean!<CR>

nnoremap <leader>tt :Buffers<CR>
nnoremap <leader>tm :Marks<CR>
nnoremap <leader>tc :bwipeout<CR>

nnoremap <leader>gw :Gwrite<CR>
nnoremap <leader>gS :Gwrite<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gg :Gstatus<CR>
nnoremap <leader>gr :Gread<CR>
nnoremap <leader>gx :GDelete<CR>
nnoremap <leader>gcc :Commits<CR>
nnoremap <leader>gcb :BCommits<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gl :Glog<CR>
nnoremap <leader>gu :Git pull<CR>
nnoremap <leader>ge :Ggrep<CR>
nnoremap <leader>gm :GMove<CR>
nnoremap <leader>gh :GBrowse<CR>

vnoremap <leader>y "+y
nnoremap <leader>Y "+yg_
nnoremap <leader>y "+y
nnoremap <leader>yy "+yy

" }}} END leader key mappings

" {{{ localleader mappings
nnoremap <localleader>nn :echo "hi"<CR>
" }}} localleader mappings

" }}} END Key bindings

" {{{ BEGIN Todos
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
" https://github.com/dyng/ctrlsf.vim for search and replace across files?
" set up maps for gitgutter - https://github.com/airblade/vim-gitgutter
" set up statusline - gitgutter and fugitive should contribute

" see also:
" https://learnvimscriptthehardway.stevelosh.com/
" https://vimawesome.com/
" mine https://github.com/SpaceVim/SpaceVim for ideas
" https://vimways.org/2018/
" https://romainl.github.io/the-patient-vimmer/1.html
" https://github.com/HugoForrat/LaTeX-Vim-User-Manual
" }}} END Todos

echo "init.vim loaded!"
" vim: filetype=vim foldmethod=marker foldlevel=10 foldcolumn=3
