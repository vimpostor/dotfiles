call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdcommenter' "easier commenting
Plug 'terryma/vim-multiple-cursors' "multiple cursors
Plug 'honza/vim-snippets' "snippet collection
Plug 'lervag/vimtex' "LaTeX
Plug 'tpope/vim-surround' "surround commands
Plug 'Shougo/neosnippet' "snippets
Plug 'Shougo/neosnippet-snippets' "more snippets
Plug 'scrooloose/nerdtree' "file system tree
Plug 'easymotion/vim-easymotion' "even faster movement
Plug 'tpope/vim-fugitive' "handy git tools
Plug 'junegunn/limelight.vim' "limelight
Plug 'junegunn/goyo.vim' "distraction free editing
Plug 'markonm/traces.vim' "pattern preview
Plug 'w0rp/ale' "ale
Plug 'morhetz/gruvbox' "colorscheme
Plug 'https://gitlab.com/dbeniamine/cheat.sh-vim.git' "cheat sheets
Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}
Plug 'fatih/vim-go' "golang support
Plug 'junegunn/vim-slash' "improved search
call plug#end()

"color scheme
set background=dark
let g:gruvbox_guisp_fallback = "bg"
colorscheme gruvbox
"general vim options
set noswapfile "no swap
set updatetime=300 "updatetime for CursorHold
set cursorline "highlight current line
set confirm "Ask to confirm instead of failing
set ignorecase "case insensitive search
set smartcase "case sensitive if search term contains capitals
set scrolloff=4 "start scrolling a few lines from the border
set display+=lastline "always display the last line of the screen
set showmatch "when inserting brackets, highlight the matching one
syntax enable
set wildmenu "better tab completion
set wildmode=longest:full,full
set ttyfast "fast terminal connection
set gdefault "replace globally by default
set encoding=utf-8 "latin1? what year is it? fuckin 1991?
set autoindent
set smartindent
set noexpandtab
set shiftwidth=4 "tab = 4 spaces
set tabstop=4
set hlsearch "highlight search
set incsearch "highlight while you type
set laststatus=0 "never show status line
set noshowmode "dont show mode
set noruler "no curser position
set noshowcmd "don't show cmds
set number "show line numbers
set mouse=a "enable mouse input
set t_ut="" "prevents a weird background on some terminals
set lazyredraw
set hidden "allow buffers to be hidden
if has('termguicolors') "true colors
	let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
	set termguicolors
endif
vnoremap < <gv "keep selected text selected when indenting
vnoremap > >gv
"highlight Comment cterm=italic

"file type specific settings
"tex
autocmd Filetype tex setlocal tw=80
"mutt
au BufRead /tmp/mutt-* set tw=72
"pandoc
command PandocDisable autocmd! Pandoc BufWritePost *
command PandocEnable exe 'silent! PandocDisable!' | exe 'augroup Pandoc' | exe 'silent !pandoc % -o /tmp/%:t.pdf && xdg-open /tmp/%:t.pdf' | exe 'autocmd BufWritePost * silent! !pandoc % -o /tmp/%:t.pdf' | exe 'augroup END' | exe 'redraw!'

"general key mappings
let mapleader = ","
let maplocalleader = " "
map j gj
map k gk
nnoremap Q @@ "last macro
"Use the system clipboard only when explicitly yanking
xnoremap <silent> y "+y
nnoremap <silent> y "+y
nnoremap <silent> p "+p
nnoremap <silent> P "+P
"use backspace to go back a paragraph
nnoremap <BS> {
onoremap <BS> {
vnoremap <BS> {
"use Enter to go forward one paragraph
nnoremap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
onoremap <expr> <CR> empty(&buftype) ? '}' : '<CR>'
vnoremap <CR> }
"move lines around
nnoremap J :m .+1<CR>==
nnoremap K :m .-2<CR>==
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

"plugin settings
"neosnippet
imap <C-l> <Plug>(neosnippet_expand_or_jump)
smap <C-l> <Plug>(neosnippet_expand_or_jump)
xmap <C-l> <Plug>(neosnippet_expand_target)
"coc.nvim
inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : <SID>check_back_space() ? "\<TAB>" : coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1] =~# '\s'
endfunction
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> gD :call <SID>show_documentation()<CR>
function! s:show_documentation()
	if &filetype == 'vim'
		execute 'h '.expand('<cword>')
	else
		call CocAction('doHover')
	endif
endfunction
autocmd CursorHold * silent call CocActionAsync('highlight')
nmap <leader>R <Plug>(coc-rename)
vmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)
autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
vmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>ac <Plug>(coc-codeaction)
nmap <leader>qf <Plug>(coc-fix-current)
command! -nargs=0 Format :call CocAction('format')
command! -nargs=? Fold :call CocAction('fold', <f-args>)
nnoremap <silent> <LocalLeader>p :<C-u>CocList outline<cr>
nnoremap <silent> <LocalLeader>P :<C-u>CocListResume<CR>

"nerd tree
map <C-t> :NERDTreeToggle<CR>

"easy motion
nmap s <Plug>(easymotion-s2)
nmap t <Plug>(easymotion-t2)
map <Leader> <Plug>(easymotion-prefix)
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)
let g:EasyMotion_startofline = 0 "keep cursor column when JK motion
hi link EasyMotionTarget2First Search
hi link EasyMotionTarget2Second ErrorMsg
let g:EasyMotion_keys = "asdghklqwertyuiopzxcvbnmfj,"

"vimtex
let g:vimtex_view_method = "zathura"
let g:vimtex_quickfix_mode = 0

"multiple cursors
let g:multi_cursor_exit_from_insert_mode = 0

"goyo
function! s:goyo_enter()
  Limelight
endfunction
function! s:goyo_leave()
  Limelight!
endfunction
autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

"ale
"let g:ale_completion_enabled = 1
let g:ale_lint_on_text_changed="never"
map <Leader>ad <Plug>(ALEGoToDefinition)
map <Leader>au <Plug>(ALEFindReferences)
"vim-slash
if has('timers')
	noremap <expr> <plug>(slash-after) slash#blink(1, 200)
endif
