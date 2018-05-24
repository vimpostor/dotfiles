"vim-plug, automatically enables filetype plugin indent and syntax
call plug#begin('~/.vim/plugged')
Plug 'bling/vim-airline' "status line
Plug 'scrooloose/nerdcommenter' "easier commenting
Plug 'terryma/vim-multiple-cursors' "multiple cursors
Plug 'honza/vim-snippets' "snippet collection
Plug 'lervag/vimtex' "LaTeX
Plug 'tpope/vim-surround' "surround commands
Plug 'vim-scripts/delimitMate.vim' "automatically close brackets
Plug 'Shougo/neocomplete' " autocompletion
Plug 'Shougo/neosnippet' " snippets
Plug 'Shougo/neosnippet-snippets' " more snippets
Plug 'scrooloose/nerdtree' " file system tree
Plug 'easymotion/vim-easymotion' " even faster movement
Plug 'petrushka/vim-gap'
Plug 'tpope/vim-fugitive' " handy git tools
Plug 'rust-lang/rust.vim' " rust support
Plug 'racer-rust/vim-racer' " rust autocompletion
Plug 'junegunn/limelight.vim' "limelight
Plug 'junegunn/goyo.vim' "distraction free editing
Plug 'morhetz/gruvbox' "gruvbox colorscheme
call plug#end()

set clipboard=unnamedplus "use X clipboard
set confirm " Ask to confirm instead of failing
set ignorecase "case insensitive search
set smartcase " case sensitive if search term contains capitals
set scrolloff=4 " start scrolling a few lines from the border
set display+=lastline " always display the last line of the screen
set showmatch " when inserting brackets, highlight the matching one
syntax enable
colorscheme gruvbox
set background=light
"highlight Comment cterm=italic
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
set hlsearch "highlight search
set incsearch "highlight while you type
set laststatus=2 "always show status line
set noshowmode "airline already shows the mode
set number "show line numbers
set mouse=a "enable mouse input
set t_ut=''

"file types
autocmd Filetype tex setlocal tw=80

"mutt
au BufRead /tmp/mutt-* set tw=72

"airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#syntastic#enabled = 1
"snippets
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

"neocomplete
let g:neocomplete#enable_at_startup = 1
if !exists('g:neocomplete#sources#omni#input_patterns')
	let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.tex =
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
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"
"true colors
if has('termguicolors')
	let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
	set termguicolors
endif

" nerd tree
map <C-t> :NERDTreeToggle<CR>

let mapleader = "-"
let maplocalleader = "ö"
" easy motion
nmap s <Plug>(easymotion-s2)
nmap t <Plug>(easymotion-t2)
map <Leader> <Plug>(easymotion-prefix)
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)
let g:EasyMotion_startofline = 0 " keep cursor column when JK motion
hi link EasyMotionTarget2First Search
hi link EasyMotionTarget2Second ErrorMsg
let g:EasyMotion_keys = "asdghklqwertyuiopzxcvbnmfj,"

" vimtex
let g:vimtex_view_method = "zathura"
let g:vimtex_quickfix_mode = 0
" rust.vim
let g:rust_recommended_style = 0
" racer rust
let g:racer_cmd = "/usr/bin/racer"

" multiple cursors
function! Multiple_cursors_before()
	exe 'NeoCompleteLock'
endfunction
function! Multiple_cursors_after()
	exe 'NeoCompleteUnlock'
endfunction
let g:multi_cursor_exit_from_insert_mode = 0

" goyo
function! s:goyo_enter()
  Limelight
endfunction

function! s:goyo_leave()
  Limelight!
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
