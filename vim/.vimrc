au FileType * set fo-=c fo-=r fo-=o " Remove annoying auto comment
au BufNewFile,BufRead *.tt              set filetype=html
au BufNewFile,BufRead *.tmpl            set filetype=html
au BufNewFile,BufRead *.md              set filetype=html
au BufRead,BufNewFile prod              set filetype=sh
au BufRead,BufNewFile *.func,*.f        set filetype=sh " Shell Functions
au BufRead,BufNewFile *.go              set filetype=c
au BufRead,BufNewFile basic             set filetype=sh
au BufRead,BufNewFile .interactive      set filetype=sh
au BufRead,BufNewFile *.config          set filetype=sh
" au BufRead,BufNewFile *.t               set filetype=sh " Unit Tests
au BufRead,BufNewFile *.t               set filetype=perl " Perl Unit Tests
au BufRead,BufNewFile defaults          set filetype=sh
au BufRead,BufNewFile *.profile         set filetype=sh
au BufRead,BufNewFile environ.*         set filetype=sh
au BufRead,BufNewFile .bashrc           set filetype=sh
au BufNewFile,BufRead *.ps1,*.psc1      setf ps1
au BufRead,BufNewFile *.ml              set filetype=xml
au Filetype python set
     \ tabstop=2
     \ softtabstop=2
     \ shiftwidth=2
     \ textwidth=79

set timeoutlen=1000 ttimeoutlen=0
set nocompatible
silent! syntax on
:set hlsearch

set cursorline          " Show Line where editing
set showmatch           " highlight matching [{()}]

" Tab in selected text
vmap <Tab> >gv
vmap <S-Tab> <gv

" Map Ctrl+Up/Down to Page Up/Down
map <silent> <C-Up> <PageUp>
map <silent> <C-Down> <PageDown>

" Comment out block of code with C, uncomment with c
map C :s/^/# /<CR> :nohlsearch<CR>
map c :s/^# //<CR> :nohlsearch<CR>

" Open close folding
map z za

" Replace 2 or more spaces with single space on current line ignoring any erro
" reset search
" and then jump to start of line
map X :s/ \{2,}/ /ge<cr> :let @/ = ""<cr> ^

" Toggle numbering with N
map <silent> N :set invnumber<cr>

" Map word wrapping to Ctrl+c
map <silent> <C-w> :set wrap!<cr>

" # will search for word under cursor

" Custom colours

" :colorscheme evening
silent! :colorscheme desert
:highlight Constant ctermfg=DarkGreen

:let g:netrw_dirhistmax = 0

:set modeline            " Allow per file vim settings
:set modelines=5         " Check up to 5 lines for per file vim settings

" check one time after 4s of inactivity in normal mode
set autoread
au CursorHold * checktime         

set backspace=2 
:set viminfo='0,:0,<0,@0,f0,n/var/tmp/.viminfo.$USER
:set ts=2
filetype indent on
:set shiftwidth=2
:set expandtab
:set autoread
set foldmethod=marker
set softtabstop=2 expandtab
set ruler
set number " nonumber
set ignorecase
set visualbell
set t_vb=
hi Comment    cterm=None   ctermfg=White        ctermbg=None

" autocmd VimEnter * !printf "\033&OK\033\\"

" %F(Full file path)
" %m(Shows + if modified - if not modifiable)
" %r(Shows RO if readonly)
" %<(Truncate here if necessary)
" \ (Separator)
" %=(Right align)
" %l(Line number)
" %v(Column number)
" %L(Total number of lines)
" %p(How far in file we are percentage wise)
" %%(Percent sign)
set statusline=%F%m%r%<\ %=%l,%v\ [%L]\ %p%%

" Change the highlighting so it stands out
" hi statusline ctermbg=white ctermfg=black

" Make sure it always shows
set laststatus=2

" Map ctrl+P to set paste / no paste
map <C-p> :set paste!<cr>
