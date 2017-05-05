"vim-plug, automatically enables filetype plugin indent and syntax
call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized' "color scheme
Plug 'scrooloose/syntastic' "syntax checking
Plug 'bling/vim-airline' "status line
Plug 'scrooloose/nerdcommenter' "easier commenting
Plug 'airblade/vim-gitgutter' "view git changes
"Plug 'valloric/youcompleteme' "autocompletions
Plug 'terryma/vim-multiple-cursors' "multiple cursors
Plug 'sirver/ultisnips' "code snippets
Plug 'honza/vim-snippets' "snippet collection
Plug 'lervag/vimtex' "LaTeX
Plug 'tpope/vim-surround' "surround commands
call plug#end()

set clipboard=unnamedplus "use X clipboard
set background=dark
colorscheme solarized
"better tab completion
set wildmenu
set wildmode=longest:full,full
set ttyfast "fast terminal connection
set gdefault "replace globally by default
set encoding=utf-8 "latin1? what year is it? fuckin 1991?
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

"syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_balloons = 1
"airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#syntastic#enabled = 1
"snippets
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwwardTrigger="<c-z>"