if !isdirectory(glob('~/.vim/plugged'))
	"Install vim-plug
	silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	au VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdcommenter' "easier commenting
Plug 'terryma/vim-multiple-cursors' "multiple cursors
Plug 'honza/vim-snippets' "snippets
Plug 'tpope/vim-surround' "surround commands
Plug 'easymotion/vim-easymotion' "even faster movement
Plug 'tpope/vim-fugitive' "handy git tools
Plug 'tpope/vim-rhubarb' "github integration
Plug 'markonm/traces.vim' "pattern preview
Plug 'https://gitlab.com/dbeniamine/cheat.sh-vim.git' "cheat sheets
Plug 'dense-analysis/ale' "linting
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'puremourning/vimspector' "debugging
Plug 'junegunn/fzf.vim' "fzf integration
Plug 'mbbill/undotree' "undo history visualizer
Plug 'vimpostor/vim-prism' "colorscheme
Plug 'vimpostor/vim-tpipeline' "outsource statusline to tmux
Plug 'vimpostor/vim-lumen' "follow global darkmode
call plug#end()
packadd! matchit "builtin plugin extends %

"color scheme
silent! colorscheme prism
"general vim options
set noswapfile "no swap
set updatetime=300 "updatetime for CursorHold
set timeoutlen=1000 "mapping delays
set ttimeoutlen=10 "keycode delays
set cursorline "highlight current line
set guicursor=
set confirm "Ask to confirm instead of failing
set ignorecase "case insensitive search
set smartcase "case sensitive if search term contains capitals
set hlsearch "highlight search
set incsearch "highlight while you type
set scrolloff=4 "start scrolling a few lines from the border
set display=lastline "always display the last line of the screen
set showmatch "when inserting brackets, highlight the matching one
syntax enable
set wildmenu "better tab completion
set wildmode=longest:full,full
if !has('nvim')
	set completeopt+=menuone,popup
	set completepopup=highlight:Pmenu,border:off
	set fo+=/
elseif has('nvim-0.8')
	set cmdheight=0
	set shortmess+=S
endif
set ttyfast "fast terminal connection
set gdefault "replace globally by default
set encoding=utf-8
set autoindent
set smartindent
set breakindent
set noexpandtab
set shiftwidth=4 "tab = 4 spaces
set tabstop=4
set cino=:0,g0,N-s
silent! set stl=%!tpipeline#stl#line()
set laststatus=2 "always show the statusline
set noshowmode "dont show mode
set noruler "no curser position
set noshowcmd "don't show cmds
set mouse=a
if has('mouse_sgr')
	set ttymouse=sgr
elseif !has('nvim')
	set ttymouse=xterm2
endif
set t_ut="" "prevents a weird background on some terminals
if has('termguicolors') "true colors
	let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
	set termguicolors
endif
set lazyredraw
set hidden "allow buffers to be hidden
set shortmess+=c "don't give ins-completion-menu messages
"do not write backup files, they cause more problems than they solve
set nobackup
set nowritebackup
set autoread
"keep selected text selected when indenting
xnoremap < <gv
xnoremap > >gv
"allow completions from the dictionary
set complete+=kspell
set diffopt+=vertical,algorithm:patience
"split like a normal human being
set splitbelow
set splitright

"file type specific settings
let g:python_recommended_style = 0
let g:rust_recommended_style = 0
au Filetype yaml setlocal ts=2 sw=2 et
au Filetype yaml if expand('%:p:h') =~# 'playbooks\|tasks\|handlers' | setlocal ft=yaml.ansible | endif
au Filetype markdown,gitcommit,tex setlocal spell
au FileType mail setlocal spell spelllang=en,de nojs
au FileType haskell setlocal expandtab
au Filetype c,cpp nnoremap <silent> <F4> :<C-u>CocCommand clangd.switchSourceHeader<CR>

"pandoc
command PandocDisable au! Pandoc BufWritePost *
command PandocEnable exe 'silent! PandocDisable!' | exe 'augroup Pandoc' | exe 'silent !pandoc % -o /tmp/%:t.pdf && xdg-open /tmp/%:t.pdf' | exe 'au BufWritePost * silent! !pandoc % -o /tmp/%:t.pdf' | exe 'augroup END' | exe 'redraw!'

"general keybindings
let mapleader = " "
let maplocalleader = ","
map j gj
map k gk
nnoremap Q @@
"Use the system clipboard only when explicitly yanking
xnoremap y "+y
nnoremap y "+y
nnoremap p "+p
nnoremap P "+P
nmap Y yg_
"move lines around
nnoremap <silent> J :<C-U>exe "exec 'norm m`' \| move +" . v:count1<CR>==``
nnoremap <silent> K :<C-U>exe "exec 'norm m`' \| move -" . (1+v:count1)<CR>==``
xnoremap <silent> J :<C-U>exe "'<,'>move '>+" . v:count1<CR>gv=gv
xnoremap <silent> K :<C-U>exe "'<,'>move '<-" . (1+v:count1)<CR>gv=gv
"quickfix
nmap <silent> <C-q> :call ToggleQf()<CR>
nmap <silent> <Leader>J :<C-U>exe v:count1 . 'cnext'<CR>
nmap <silent> <Leader>K :<C-U>exe v:count1 . 'cprev'<CR>
nmap <silent> <Leader>j :<C-U>exe v:count1 . 'lbelow'<CR>
nmap <silent> <Leader>k :<C-U>exe v:count1 . 'labove'<CR>
"join lines
nnoremap <LocalLeader>J J
xnoremap <LocalLeader>J J
"clear search
nnoremap <silent> <C-L> :nohl<CR>
nmap <silent> <Leader>u :UndotreeToggle<CR>
"switch to last buffer
nnoremap <Leader><Leader> <c-^>
"autocorrect last misspelling
imap <c-v> <c-g>u<Esc>[s1z=`]a<c-g>u
"do not overwrite my keybindings in rebase mode
let g:no_gitrebase_maps = 1
"write with sudo
command SudoWrite execute 'silent! write !sudo tee % >/dev/null' <bar> edit!
"create new c style header-source file pair
func HeaderCreate(n)
	let h = ['hpp', 'h', 'hh', 'hxx', 'cpp', 'c', 'cc', 'cxx']
	call mkdir(fnamemodify(a:n, ":h"), "p")
	let f = fnamemodify(a:n, ":r") . "."
	let i = index(h, fnamemodify(a:n, ":e")) % (len(h) / 2)
	exec "edit " . f . h[i + len(h) / 2]
	call setline(".", '#include "' . fnamemodify(f, ":t") . h[i] . '"')
	norm 2o
	exec "edit " . f . h[i]
	call setline(".", "#pragma once")
	norm 2o
	wa
endfunc
command -nargs=1 -complete=file Cunit call HeaderCreate(<args>)

"netrw
nnoremap <silent> <C-t> :Lexplore<CR>
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_winsize = 25

"toggle qflist
function! ToggleQf()
	if getqflist({'winid': 0}).winid
		cclose
	else
		copen
	endif
endfunction
"thesaurus
func Thesaur(findstart, base)
	if a:findstart
		return searchpos('\<', 'bnW', line('.'))[1] - 1
	endif
	let res = []
	let h = ''
	for l in systemlist('aiksaurus '.shellescape(a:base))
		if l[:3] == '=== '
			let h = '('.substitute(l[4:], ' =*$', ')', '')
		elseif l ==# 'Alphabetically similar known words are: '
			let h = "\U0001f52e"
		elseif l[0] =~ '\a' || (h ==# "\U0001f52e" && l[0] ==# "\t")
			call extend(res, map(split(substitute(l, '^\t', '', ''), ', '), {_, val -> {'word': val, 'menu': h}}))
		endif
	endfor
	return res
endfunc
if exists('+thesaurusfunc')
	set thesaurusfunc=Thesaur
endif

"plugin settings
"ale
let g:ale_disable_lsp = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_prefix = "🔧 "
let g:ale_floating_preview = 1
let g:ale_floating_window_border = []

"fugitive
nnoremap <silent> <LocalLeader>Gb :0,3Git blame<CR>

"coc.nvim
let g:coc_global_extensions = [
\ 'coc-snippets',
\ 'coc-texlab',
\ 'coc-python',
\ 'coc-json',
\ 'coc-yaml',
\ 'coc-lists',
\ 'coc-clangd',
\ 'coc-rust-analyzer',
\ ]
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> <LocalLeader>K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
au CursorHold * silent call CocActionAsync('highlight') "highlight symbol on cursor hold
nmap <LocalLeader>rn <Plug>(coc-rename)
xmap <LocalLeader>f  <Plug>(coc-format-selected)
nmap <LocalLeader>f  <Plug>(coc-format-selected)
augroup mygroup
  au!
  au FileType typescript,json setl formatexpr=CocAction('formatSelected') "Setup formatexpr specified filetype(s).
  au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp') "Update signature help on jump placeholder
augroup end
xmap <LocalLeader>a  <Plug>(coc-codeaction-selected)
nmap <LocalLeader>a  <Plug>(coc-codeaction-selected)
nmap <LocalLeader>ac  <Plug>(coc-codeaction)
nmap <LocalLeader>qf  <Plug>(coc-fix-current)
"function text objects
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
xmap <silent> <Tab> <Plug>(coc-range-select)
command! -nargs=0 Format :call CocAction('format')
command! -nargs=? Fold :call CocAction('fold', <f-args>)
nnoremap <silent> <Leader>e  :<C-u>CocList diagnostics<cr>
nnoremap <silent> <Leader>o  :<C-u>CocList outline<cr>
nnoremap <silent> <Leader>s  :<C-u>CocList -I symbols<cr>
"snippets
imap <C-j> <Plug>(coc-snippets-expand-jump)
"coc-texlab
if has('nvim')
	nnoremap <silent> <Leader>ll :<C-u>CocCommand latex.Build<CR>
else
	nnoremap <silent> <Leader>ll :<C-u>call remote_startserver("synctex")<CR>:CocCommand latex.Build<CR>
endif
nnoremap <silent> <Leader>lv :<C-u>CocCommand latex.ForwardSearch<CR>
"lists
nnoremap <silent> <Leader>P :<C-u>Files<CR>
nnoremap <silent> <Leader>b :<C-u>Buffers<CR>
nnoremap <silent> <Leader>f :<C-u>Rg<CR>

"vimspector
let g:vimspector_enable_mappings = 'HUMAN'
nmap <LocalLeader>di <Plug>VimspectorBalloonEval
xmap <LocalLeader>di <Plug>VimspectorBalloonEval
nmap <Leader><F11> <Plug>VimspectorUpFrame
nmap <Leader><F12> <Plug>VimspectorDownFrame
nmap <silent> <Leader><F3> :<C-u>VimspectorReset<CR>

"easy motion
nmap s <Plug>(easymotion-s2)
nmap t <Plug>(easymotion-t2)
map <LocalLeader> <Plug>(easymotion-prefix)
map <LocalLeader>l <Plug>(easymotion-lineforward)
map <LocalLeader>j <Plug>(easymotion-j)
map <LocalLeader>k <Plug>(easymotion-k)
map <LocalLeader>h <Plug>(easymotion-linebackward)
let g:EasyMotion_startofline = 0 "keep cursor column JK motion
let g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfj,'

"multiple cursors
let g:multi_cursor_exit_from_insert_mode = 0

"tpipeline
let g:tpipeline_cursormoved = 1

"nerdcommenter
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
nmap <LocalLeader>c<Space> <Plug>NERDCommenterToggle
xmap <LocalLeader>c<Space> <Plug>NERDCommenterToggle

"fzf
let g:fzf_layout = {'window': {'width': 1, 'height': 0.4, 'yoffset': 1, 'border': 'horizontal'}}

"cheat.sh
let g:CheatSheetDoNotMap = 1
nnoremap <silent> <LocalLeader>KB :call cheat#cheat("", getcurpos()[1], getcurpos()[1], 0, 0, '!')<CR>
vnoremap <silent> <LocalLeader>KB :call cheat#cheat("", -1, -1, 2, 0, '!')<CR>
