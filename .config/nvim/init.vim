" NB: see https://neovim.io/doc/user/vim_diff.html for list of nvim defaults

" {{{ BEGIN vim-plugged config
call plug#begin(stdpath('data') . '/plugged')

" Plugins that should not be loaded if using neovim inside vscode
if !exists('g:vscode')
    " color schemes
    Plug 'joshdick/onedark.vim'

    Plug 'itchyny/lightline.vim'

    Plug 'norcalli/nvim-colorizer.lua' " render color literals in nvim

    Plug 'junegunn/fzf' " the fuzzy finder to rule them all
    Plug 'junegunn/fzf.vim' " actually make the fuzzy finder integrated into vim
    Plug 'jesseleite/vim-agriculture' " allow passing args to rg fzf integration

    Plug 'editorconfig/editorconfig-vim'

    Plug 'airblade/vim-gitgutter'
    let g:gitgutter_map_keys = 0

    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-rhubarb' " github support for fugitive's Gbrowse
    Plug 'tommcdo/vim-fubitive' " bitbucket support for fugitive's Gbrowse
    Plug 'tpope/vim-dispatch' " let plugins (namely fugitive) run commands async

    Plug 'liuchengxu/vim-which-key'

    Plug 'thirtythreeforty/lessspace.vim' " trim tailing whitespace at end of files

    Plug 'ntpeters/vim-better-whitespace' " show trailing whitespace in red
    let g:show_spaces_that_precede_tabs=1

    Plug 'tmux-plugins/vim-tmux-focus-events' " make focus events work in terminal

    Plug 'tyru/capture.vim' " show command output in buffer with :Capture
endif

Plug 'gioele/vim-autoswap' " deal with vim's swap files automatically
let g:autoswap_detect_tmux = 1

Plug 'machakann/vim-highlightedyank'
let g:highlightedyank_highlight_duration = 150

Plug 'sheerun/vim-polyglot' " language packs for all the languages

" text objects
Plug 'kana/vim-textobj-user' " text object helper, used by..
Plug 'kana/vim-textobj-entire' " ae/ie for entire file
Plug 'kana/vim-textobj-indent' " a/i,i/I for indent blocks (:h textobj-indent)
Plug 'kana/vim-textobj-line' " al/il for line with/without lead/trailing spaces
Plug 'Julian/vim-textobj-variable-segment' " iv/av text objs for variable segments

Plug 'terryma/vim-expand-region' " +/- to extend/shrink selection
let g:expand_region_text_objects = {
      \ 'iw'  :0,
      \ 'iW'  :0,
      \ 'i"'  :1,
      \ 'i'''  :1,
      \ 'i{'  :1,
      \ 'i('  :1,
      \ 'i['  :1,
      \ 'a%'  :1,
      \ 'ii'  :1,
      \ 'aI'  :0,
      \ }

Plug 'tpope/vim-rsi' " readline bindings in insert mode
Plug 'tpope/vim-sleuth' " auto pick tab and shift widths
Plug 'tpope/vim-repeat' " make plugin commands repeatable with .
Plug 'tpope/vim-speeddating' " date and time incrementing
Plug 'tpope/vim-unimpaired' " misc 'backwards and forwards' commands

"As of 2022-07-26, tpope or neovim seems to have broken these plugins: they
"make vim commands appear as output when hitting Enter in insert mode while
"editing a .zshrc file
"Plug 'tpope/vim-eunuch' " unix commands
"Plug 'tpope/vim-endwise' " auto insert closing keywords (e.g. 'fi')

Plug 'machakann/vim-sandwich' " surround commands but better

Plug 'machakann/vim-swap' " commands to swap left/right
let g:swap_no_default_key_mappings = 1

Plug 'rstacruz/vim-closer' " insert closing brackets but only on enter

Plug 'arthurxavierx/vim-caser' " case changes with gs then p (pascal), c
" (camel), _ (snake), u (upper), t (title), s (sentence), space, k (kebab), K
" (title kebab), . (dot case)

Plug 'tomtom/tcomment_vim' " commenting shortcuts

Plug 'ConradIrwin/vim-bracketed-paste' " detect pastes in terminal via magic keycode
" bracketed paste is unfortunately not supported in microsoft terminal yet:
" https://github.com/microsoft/terminal/issues/395

Plug 'lfilho/cosco.vim' " shortcut to add semicolons intelligently

Plug 'AndrewRadev/splitjoin.vim' " split and join lines with gS/gJ
let g:splitjoin_split_mapping = ''
let g:splitjoin_join_mapping  = ''

Plug 'markonm/traces.vim' " live previews of ranges, substitutes, etc

Plug 'andymass/vim-matchup' " replaces matchit, adds support for lang keywords

Plug 'matze/vim-move' " move lines and visual selections around interactively
let g:move_map_keys = 0

Plug 'svermeulen/vim-subversive' " substitute motions (bindings added later)

call plug#end()

" configure vim-plugged to install plugins and remove old plugins on startup
if !exists('g:vscode')
    augroup VimPlugAutoInstallOnStartup
        autocmd!
        autocmd VimEnter *
                    \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
                    \|   PlugInstall --sync | q | PlugClean! | q
                    \| endif
    augroup END
endif

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

" render unprintable characters nicely in list view
set listchars=tab:│·,trail:·,extends:»,precedes:«,nbsp:‡,eol:§

" formatting config (:h fo-table):
" t to wrap text to textwidth
" c to wrap comments to textwidth
" q to allow formatting comments with gq
" j to remove comment chars when joining lines
set formatoptions=tcqj

if !exists('g:vscode')
    " auto reload vim configuration when it gets changed
    augroup AutoReloadVimConfigOnInitVimChange
      autocmd!
      autocmd BufWritePost init.vim so $MYVIMRC
    augroup END
endif

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

" show 2 lines of command output (helps prevent "press enter to continue")
" (recommended by coc vim plugin)
set cmdheight=2

if !exists('g:vscode')
    " We want to show the sign colum consistently so that it doesn't jump in
    " and out of view. Options:
    " number = show the sign column such that it overwrites the line number
    " column when there's something to display in the sign colum (e.g. git diff
    " marker from git gutter)
    " yes = always show the sign column
    set signcolumn=number

    " 20% fake transparency on floating window
    set pumblend=20

    " enable cursor column and line
    set cursorline
    set cursorcolumn

    " make cursor position more prominent for the active window
    augroup VisibleCursorLineAndColumn
      autocmd!
      autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline | setlocal cursorcolumn
      autocmd WinLeave * setlocal nocursorline | setlocal nocursorcolumn
    augroup END

    augroup OpenHelpVertically
      autocmd!
      autocmd FileType help :wincmd L | :vert resize 90
    augroup END
endif

" }}} END basic vim options

" {{{ BEGIN Look and feel (theme, cursor, modeline)
if !exists('g:vscode')
    " color scheme and statusbar
    colorscheme onedark
    let g:lightline = { 'colorscheme': 'wombat' }

    " make cursor column & line highlighting more visible
    hi CursorColumn ctermbg=238 guibg=#181C24
    hi CursorLine ctermbg=238 guibg=#181C24
endif
" }}} END look and feel

" {{{ Plugin configuration

" enable vim-surround maps for sandwich (to avoid clobbering s in normal mode)
" https://github.com/machakann/vim-sandwich/wiki/Introduce-vim-surround-keymappings
runtime macros/sandwich/keymap/surround.vim

if !exists('g:vscode')
    " make nvim-colorizer actually render colors
    lua require'colorizer'.setup()
endif

" }}} END plugin configuration

" {{{ Clipboard tweaking for vscode + WSL
" Requires https://github.com/equalsraf/win32yank to be on BOTH the WSL and
" Windows PATH
" Found via https://github.com/asvetliakov/vscode-neovim/issues/103#issuecomment-769405275
if exists('g:vscode')
    set clipboard^=unnamed

    if has('nvim') && exists('$WSLENV')
        let g:clipboard = {
            \ 'name': 'win32yank-wsl',
            \ 'copy': {
            \    '+': 'win32yank.exe -i --crlf',
            \    '*': 'win32yank.exe -i --crlf',
            \  },
            \ 'paste': {
            \    '+': 'win32yank.exe -o --lf',
            \    '*': 'win32yank.exe -o --lf',
            \ },
            \ 'cache_enabled': 0,
        \ }
    endif
endif

" }}} END Clipboard tweaking for vscode + WSL

" {{{ BEGIN Key bindings

" swap ' and ` so that ' is position-based mark jumping
nnoremap ' `
nnoremap ` '
xnoremap ' `
xnoremap ` '

" set space as my leader key
let mapleader = "\<Space>"
" and set comma as local leader
let maplocalleader = ","

if !exists('g:vscode')
    " save and quit with double ctrl-c
    nnoremap <C-C><C-C> :x<CR>

    " swap arguments with alt+left/right
    nmap <A-Left> <Plug>(swap-prev)
    nmap <A-Right> <Plug>(swap-next)

    " move lines down/up with alt+down/up
    nmap <A-Up> <Plug>MoveLineUp
    nmap <A-Down> <Plug>MoveLineDown
    " move lines down/up with alt+left/down/up/right in visual mode
    xmap <A-Left> <Plug>MoveBlockLeft
    xmap <A-Down> <Plug>MoveBlockDown
    xmap <A-Up> <Plug>MoveBlockUp
    xmap <A-Right> <Plug>MoveBlockRight

    " move through hunks with ctrl+down/up
    nmap <C-Down> <Plug>(GitGutterNextHunk)
    nmap <C-Up> <Plug>(GitGutterPrevHunk)
endif

" bind s to subversive's substitute motion
nmap s <plug>(SubversiveSubstitute)
nmap ss <plug>(SubversiveSubstituteLine)
nmap S <plug>(SubversiveSubstituteToEndOfLine)

if !exists('g:vscode')
    " allow positioning windows with Shift-Arrow (see also leader mappings)
    nnoremap <C-W><S-Left> <C-W>H
    nnoremap <C-W><S-Down> <C-W>J
    nnoremap <C-W><S-Up> <C-W>L
    nnoremap <C-W><S-Right> <C-W>L

    " text objects
    omap ih <Plug>(GitGutterTextObjectInnerPending)
    omap ah <Plug>(GitGutterTextObjectOuterPending)
    xmap ih <Plug>(GitGutterTextObjectInnerVisual)
    xmap ah <Plug>(GitGutterTextObjectOuterVisual)

    " liuchengxu/vim-which-key
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

    nnoremap <leader>w <C-W>
    nnoremap <leader>ww :Windows<CR>
    nnoremap <leader>w<S-Left> <C-W>H
    nnoremap <leader>w<S-Down> <C-W>J
    nnoremap <leader>w<S-Up> <C-W>L
    nnoremap <leader>w<S-Right> <C-W>L

    nnoremap <leader>ff :Files<CR>
    nnoremap <leader>fr :History<CR>
    nnoremap <leader>fl :Locate ''<Left>
    nnoremap <leader>fs :w<CR>
    nnoremap <leader>fR :let @+=expand("%") \| echo "yanked relative path into \" register: " . getreg('+')<CR>
    nnoremap <leader>fF :let @+=expand("%:p") \| echo "yanked absolute path into \" register: " . getreg('+')<CR>
    nnoremap <leader>fT :let @+=expand("%:t") \| echo "yanked filename into \" register:" . getreg('+')<CR>
    nnoremap <leader>fD :let @+=expand("%:p:h") \| echo "yanked directory name into \" register: " . getreg('+')<CR>
endif

nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

if !exists('g:vscode')
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

    nnoremap <leader>rs :exec '!'.getline('.')

    nnoremap <leader>ss :Rg<Space>
    nnoremap <leader>sS :RgRaw ''<Left>
    nnoremap <leader>st :RgRaw '<C-R><C-W>'<CR>
    nnoremap <leader>sT :RgRaw '<C-R><C-A>'<CR>
    nnoremap <leader>sc :cdo s///gc<Left><Left><Left><Left>
    nnoremap <leader>sC :cfdo %s///gc<Left><Left><Left><Left>
    nnoremap <leader>8 :RgRaw '<C-R><C-W>' %<CR>
    nnoremap <leader>* :RgRaw '<C-R><C-A>' %<CR>

    nnoremap <leader>tt :Buffers<CR>
    nnoremap <leader>tm :Marks<CR>
    nnoremap <leader>tc :bwipeout<CR>

    nnoremap <leader>gw :Gwrite<CR>
    nnoremap <leader>ga :Git commit --verbose --amend<CR>
    nmap <leader>gs <Plug>(GitGutterStageHunk)
    nnoremap <leader>gS :Gwrite<CR>
    nnoremap <leader>gp :Git pull<CR>
    nnoremap <leader>gP :Git push<CR>
    nnoremap <leader>gPF :Git push<CR>
    nmap <leader>gv <Plug>(GitGutterPreviewHunk)
    nnoremap <leader>gg :Gstatus<CR>
    nnoremap <leader>gr :Gread<CR>
    nnoremap <leader>gX :GDelete<CR>
    nnoremap <leader>gc :Git commit --verbose<CR>
    nnoremap <leader>gCc :Commits<CR>
    nnoremap <leader>gCb :BCommits<CR>
    nnoremap <leader>gd :Gdiffsplit<CR>
    nnoremap <leader>gb :Git blame<CR>
    nnoremap <leader>gl :Glog<CR>
    nmap <leader>gu <Plug>(GitGutterUndoHunk)
    nnoremap <leader>ge :Ggrep<CR>
    nnoremap <leader>gm :GMove<CR>
    nnoremap <leader>gh :GBrowse<CR>

    nnoremap <leader>ud :Delete %
    nnoremap <leader>uD :Unlink %
    nnoremap <leader>um :Move %
    nnoremap <leader>ur :Rename %
    nnoremap <leader>uc :Chmod u+x %
    nnoremap <leader>um :Mkdir
    nnoremap <leader>uf :Cfind
    nnoremap <leader>ua :Wall
    nnoremap <leader>usw :SudoWrite
    nnoremap <leader>use :SudoEdit
endif

nnoremap <leader>Y "+yg_
nnoremap <leader>y "+y
vnoremap <leader>Y "+yg_
vnoremap <leader>y "+y

" }}} END leader key mappings

" {{{ localleader mappings
nmap <silent> <localleader>o <Plug>(cosco-commaOrSemiColon)
imap <silent> <localleader>o <c-o><Plug>(cosco-commaOrSemiColon)
nmap <localleader>j :SplitjoinJoin<cr>
nmap <localleader>s :SplitjoinSplit<cr>
" }}} localleader mappings

" }}} END Key bindings

" {{{ BEGIN Todos
" TODO
" https://github.com/mg979/vim-visual-multi
" lsp support: https://old.reddit.com/r/vim/comments/7lnhrt/which_lsp_plugin_should_i_use/
" consider https://github.com/mhinz/neovim-remote for opening nvim from within terminal of nvim
" https://github.com/dyng/ctrlsf.vim for search and replace across files?
" set up https://github.com/bronson/vim-visual-star-search and use it for Rg/RgRaw too

" see also:
" https://learnvimscriptthehardway.stevelosh.com/
" https://vimawesome.com/
" mine https://github.com/SpaceVim/SpaceVim for ideas
" https://vimways.org/2018/
" https://romainl.github.io/the-patient-vimmer/1.html
" https://github.com/HugoForrat/LaTeX-Vim-User-Manual
" }}} END Todos

" vim: filetype=vim foldmethod=marker foldlevel=10 foldcolumn=3 textwidth=0
