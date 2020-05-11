au BufNewFile,BufRead *.tt             set filetype=html
au BufRead,BufNewFile .interactive     set filetype=sh
au BufRead,BufNewFile defaults         set filetype=sh
au BufRead,BufNewFile *.profile        set filetype=sh
set nocompatible
set laststatus=2
syntax on
set backspace=2
:set viminfo='0,:0,<0,@0,f0,n/var/tmp/.viminfo.$USER
:set ts=4
filetype indent on
:set shiftwidth=4
:set expandtab
set foldmethod=marker
set softtabstop=4 expandtab
set ruler
set number
set ignorecase
set visualbell
set t_vb=

" Comment out code with C, uncomment with c
map C :s/^/# /<CR> :nohlsearch<CR>
map c :s/^# //<CR> :nohlsearch<CR>

" Toggle numbering with N
map <silent> N :set invnumber<CR>

hi Comment    cterm=None   ctermfg=White        ctermbg=None
