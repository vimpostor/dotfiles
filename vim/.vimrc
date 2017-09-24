"vim-plug, automatically enables filetype plugin indent and syntax
call plug#begin('~/.vim/plugged')
Plug 'tyrannicaltoucan/vim-quantum' "color scheme
"Plug 'scrooloose/syntastic' "syntax checking
Plug 'bling/vim-airline' "status line
Plug 'scrooloose/nerdcommenter' "easier commenting
Plug 'airblade/vim-gitgutter' "view git changes
Plug 'terryma/vim-multiple-cursors' "multiple cursors
Plug 'sirver/ultisnips' "code snippets
Plug 'honza/vim-snippets' "snippet collection
Plug 'lervag/vimtex' "LaTeX
Plug 'tpope/vim-surround' "surround commands
"Plug 'shougo/neocomplete.vim' "autocomplete
Plug 'vim-scripts/delimitMate.vim' "automatically close brackets
call plug#end()

set clipboard=unnamedplus "use X clipboard
set confirm " Ask to confirm instead of failing
set ignorecase "case insensitive search
set smartcase " case sensitive if search term contains capitals
set scrolloff=2 " start scrolling a few lines from the border
set display+=lastline " always display the last line of the screen
set showmatch " when inserting brackets, highlight the matching one
set background=dark
" quantum color scheme
let g:quantum_black=1
let g:quantum_italics=1
colorscheme quantum
"better tab completion
set wildmenu
set wildmode=longest:full,full
set ttyfast "fast terminal connection
set gdefault "replace globally by default
set encoding=utf-8 "latin1? what year is it? fuckin 1991?
map j gj
map k gk
"indentation
set autoindent
set smartindent
set noexpandtab
set shiftwidth=2
set tabstop=2
"trailing spaces
set listchars=trail:·,tab:▸\ 
set list
set hlsearch "highlight search
set incsearch "highlight while you type
set laststatus=2 "always show status line
set noshowmode "airline already shows the mode
set number "show line numbers
set mouse=a "enable mouse input

"mutt
au BufRead /tmp/mutt-* set tw=72

"syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 0
"let g:syntastic_check_on_wq = 0
"let g:syntastic_enable_balloons = 1
"airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#syntastic#enabled = 1
"snippets
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

"neocomplete
"let g:neocomplete#enable_at_startup = 1
"if !exists('g:neocomplete#sources#omni#input_patterns')
""	let g:neocomplete#sources#omni#input_patterns = {}
"endif
"let g:neocomplete#sources#omni#input_patterns.tex =
        \ '\v\\%('
        \ . '\a*cite\a*%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
        \ . '|\a*ref%(\s*\{[^}]*|range\s*\{[^,}]*%(}\{)?)'
        \ . '|hyperref\s*\[[^]]*'
        \ . '|includegraphics\*?%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
        \ . '|%(include%(only)?|input)\s*\{[^}]*'
        \ . '|\a*(gls|Gls|GLS)(pl)?\a*%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
        \ . '|includepdf%(\s*\[[^]]*\])?\s*\{[^}]*'
        \ . '|includestandalone%(\s*\[[^]]*\])?\s*\{[^}]*'
        \ . '|usepackage%(\s*\[[^]]*\])?\s*\{[^}]*'
        \ . '|documentclass%(\s*\[[^]]*\])?\s*\{[^}]*'
        \ . '|\a*'
        \ . ')'

" <TAB>: completion.
"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"
"true colors
if has('termguicolors')
	set termguicolors
	let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
