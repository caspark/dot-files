"set runtimepath^=~/.vim runtimepath+=~/.vim/after
"let &packpath = &runtimepath
"source ~/.vimrc

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
augroup myvimrc
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

echo "init.vim loaded!"

" TODO
" https://github.com/junegunn/vim-plug
" fzf and the fzf contrib
" consider https://github.com/norcalli/nvim-colorizer.lua
" https://github.com/machakann/vim-highlightedyank
" https://github.com/mg979/vim-visual-multi
" make reloading init.vim display message, but not initial load
" add editorconfig support
" https://github.com/unblevable/quick-scope
" set leader key to space and backspace to localleader
" consider https://github.com/jeffkreeftmeijer/neovim-sensible
" lsp support: https://old.reddit.com/r/vim/comments/7lnhrt/which_lsp_plugin_should_i_use/
" https://github.com/itchyny/lightline.vim instead of airline
" https://github.com/joshdick/onedark.vim/ - see https://old.reddit.com/r/neovim/comments/akg51m/comparison_of_onedark_vs_vimone_colorscheme/
" consider https://items.sjbach.com/319/configuring-vim-right.html
" consider https://github.com/liuchengxu/vim-which-key
" consider https://github.com/mhinz/neovim-remote for opening nvim from within terminal of nvim
" https://github.com/mbbill/undotree
" https://github.com/plasticboy/vim-markdown

" see also:
" https://learnvimscriptthehardway.stevelosh.com/
" https://vimawesome.com/
" mine https://github.com/SpaceVim/SpaceVim for ideas
" https://vimways.org/2018/
" https://romainl.github.io/the-patient-vimmer/1.html
" https://github.com/HugoForrat/LaTeX-Vim-User-Manual
