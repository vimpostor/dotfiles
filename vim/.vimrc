if !isdirectory(glob('~/.vim/plugged'))
	"Install vim-plug
	silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	au VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
Plug 'dense-analysis/ale' "linting
if has('vim9script')
	Plug 'yegappan/lsp'
	Plug 'KKoovalsky/TsepepeVim', { 'do': './build.py' }
endif
Plug 'terryma/vim-multiple-cursors' "multiple cursors
Plug 'honza/vim-snippets' "snippets
Plug 'tpope/vim-surround' "surround commands
Plug 'tpope/vim-fugitive' "handy git tools
Plug 'tpope/vim-rhubarb' "github integration
Plug 'markonm/traces.vim' "pattern preview
Plug 'https://gitlab.com/dbeniamine/cheat.sh-vim.git' "cheat sheets
Plug 'puremourning/vimspector' "debugging
Plug 'junegunn/fzf.vim' "fzf integration
Plug 'mbbill/undotree' "undo history visualizer
Plug 'vimpostor/vim-prism' "colorscheme
Plug 'vimpostor/vim-tpipeline' "outsource statusline to tmux
Plug 'vimpostor/vim-lumen' "follow global darkmode
Plug 'vimpostor/vim-gallop' "even faster movement
call plug#end()
packadd! matchit "builtin plugin extends %
if !has('nvim')
	packadd! comment "easier commenting
endif

"color scheme
silent! colorscheme prism
set noswapfile
set updatetime=300 "updatetime for CursorHold
set timeoutlen=1000
set ttimeoutlen=10
set cursorline
set guicursor=
set confirm
set ignorecase
set smartcase
set hlsearch
set incsearch
set scrolloff=4
set display=lastline
set showmatch
syntax enable
set wildmenu
set wildmode=longest:full,full
if has('nvim')
	set cmdheight=0
	set shortmess+=S
else
	set completeopt+=menuone,popup
	set completepopup=highlight:Pmenu,border:off
	set fo+=/
	set ttymouse=sgr
endif
set gdefault "replace globally by default
set encoding=utf-8
set autoindent
set smartindent
set breakindent
set noexpandtab
set tabstop=4
set shiftwidth=0
set cino=:0,g0,N-s
silent! set stl=%!tpipeline#stl#line()
set laststatus=2
set noshowmode
set noruler
set noshowcmd
set mouse=a
set t_ut="" "prevents a weird background on some terminals
if has('termguicolors') "true colors
	let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
	set termguicolors
endif
set hidden
set shortmess+=c "don't give ins-completion-menu messages
set nobackup
set nowritebackup
set autoread
"keep selected text selected when indenting
xnoremap < <gv
xnoremap > >gv
"allow completions from the dictionary
set complete+=kspell
set diffopt+=vertical,internal,algorithm:patience
"split like a normal human being
set splitbelow
set splitright
set fcs=stlnc:─,stl:─,vert:│

"file type specific settings
let g:markdown_recommended_style = 0
let g:python_recommended_style = 0
let g:rust_recommended_style = 0
au Filetype yaml setlocal ts=2 sw=2 et
au Filetype yaml if expand('%:p:h') =~# 'playbooks\|tasks\|handlers' | setlocal ft=yaml.ansible | endif
au Filetype markdown,gitcommit,tex setlocal spell
au FileType mail setlocal spell spelllang=en,de nojs
au FileType haskell setlocal expandtab
au Filetype c,cpp nnoremap <silent> <F4> <Cmd>LspSwitchSourceHeader<CR> | setlocal commentstring=//\ %s

"general keybindings
let mapleader = " "
let maplocalleader = ","
map j gj
map k gk
inoremap <expr> <Tab> pumvisible() ? "\<C-N>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-P>" : "\<C-D>"
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"
nnoremap Q @q
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
nnoremap <silent> <C-L> :nohl<CR>
nmap <silent> <Leader>u :UndotreeToggle<CR>
"switch to last buffer
nnoremap <Leader><Leader> <c-^>
"autocorrect last misspelling
imap <c-v> <c-g>u<Esc>[s1z=`]a<c-g>u
let g:no_gitrebase_maps = 1
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
command -nargs=1 -complete=file Cunit call HeaderCreate(<q-args>)

"netrw
nnoremap <silent> <C-t> :Lexplore<CR>
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_winsize = 25

"toggle qflist
func ToggleQf()
	if getqflist({'winid': 0}).winid
		cclose
	else
		copen
	endif
endfunc
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
set thesaurusfunc=Thesaur
"poor man's editorconfig
func AutoIndent(...)
	let tabs = len(filter(getline('1', '$'), 'v:val =~ "^\t"'))
	let spaces = len(filter(getline('1', '$'), 'v:val =~ "^ "'))
	let n = get(a:, 1, 0) + get(filter(map(getline('1', '$'), 'len(matchstr(v:val, "^ \\+"))'), 'v:val != 0'), 0, 4) * !a:0 + 4 * !get(a:, 1, 0) * a:0
	if tabs && spaces
		echohl ErrorMsg | echo printf('Mixed indentation detected (%d tabs VS %d spaces)', tabs, spaces) | echohl None
	endif
	if (tabs > spaces && (!a:0 || !a:1)) || (a:0 && !a:1)
		exec printf('set noet ts=%d sts=0 sw=0', n)
		echo printf('Indenting with tabs (ts=%d)', n)
	else
		exec printf('set et ts=%d sts=-1 sw=0', n)
		echo printf('Indenting with spaces (ts=%d)', n)
	endif
endfunc
command -nargs=? AutoIndent call AutoIndent(<args>)

"plugin settings
"ale
let g:ale_disable_lsp = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠️'
let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_prefix = "🔧 "
let g:ale_floating_preview = 1
let g:ale_floating_window_border = []
let g:ale_linters = #{python: [], rust: []}
nmap <LocalLeader>i <Cmd>ALEDetail<CR>

"fugitive
nnoremap <silent> <LocalLeader>Gb :0,3Git blame<CR>
" yank Github permalink
nnoremap <Leader>yg :GBrowse!<CR>
nnoremap <LocalLeader>yg :.GBrowse!<CR>
xnoremap <LocalLeader>yg :'<'>GBrowse!<CR>

"lists
nnoremap <silent> <Leader>P <Cmd>Files<CR>
nnoremap <silent> <Leader>b <Cmd>Buffers<CR>
func RipgrepFzf()
	let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case --hidden -- %s || true'
	let initial_command = printf(command_fmt, "''")
	let reload_command = printf(command_fmt, '{q}')
	let spec = {'options': ['--disabled', '--query', '', '--bind', 'change:reload:'.reload_command]}
	call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec, 'right', 'ctrl-/'), 0)
endfunc
nnoremap <silent> <Leader>f <Cmd>call RipgrepFzf()<CR>

"vimspector
let g:vimspector_enable_mappings = 'HUMAN'
nmap <LocalLeader>di <Plug>VimspectorBalloonEval
xmap <LocalLeader>di <Plug>VimspectorBalloonEval
nmap <Leader><F11> <Plug>VimspectorDownFrame
nmap <Leader><F12> <Plug>VimspectorUpFrame
nmap <silent> <Leader><F3> <Cmd>VimspectorReset<CR>

"multiple cursors
let g:multi_cursor_exit_from_insert_mode = 0

"fzf
let g:fzf_layout = {'window': {'width': 1, 'height': 0.5, 'yoffset': 1, 'border': 'horizontal'}}

"cheat.sh
let g:CheatSheetDoNotMap = 1
nnoremap <silent> <LocalLeader>KB :call cheat#cheat("", getcurpos()[1], getcurpos()[1], 0, 0, '!')<CR>
vnoremap <silent> <LocalLeader>KB :call cheat#cheat("", -1, -1, 2, 0, '!')<CR>

"tpipeline
let g:tpipeline_clearstl = 1
let g:tpipeline_autoembed = 0

"lsp
if has('vim9script')
au VimEnter * call LspOptionsSet(#{aleSupport: 1, usePopupInCodeAction: 1, highlightDiagInline: v:false, autoHighlightDiags: 0, ignoreMissingServer: 1, noNewlineInCompletion: 1, useQuickfixForLocations: 1, completionMatcher: "icase"})
au VimEnter * call LspAddServer([
	\ #{ name: 'bash', filetype: ['sh'], path: 'bash-language-server', args: ['start'] },
	\ #{ name: 'cpp', filetype: ['c', 'cpp'], path: 'clangd', args: ['--background-index', '--header-insertion=never'] },
	\ #{ name: 'haskell', filetype: ['haskell'], path: 'haskell-language-server-wrapper', args: ['--lsp'] },
	\ #{ name: 'lua', filetype: ['lua'], path: 'lua-language-server' },
	\ #{ name: 'nix', filetype: ['nix'], path: 'nil' },
	\ #{ name: 'python', filetype: ['python'], path: 'pylsp' },
	\ #{ name: 'qml', filetype: ['qml'], path: 'qmlls6' },
	\ #{ name: 'rust', filetype: ['rust'], path: 'rust-analyzer', syncInit: 1, initializationOptions: #{ checkOnSave: v:false } },
	\ #{ name: 'slint', filetype: ['slint'], path: 'slint-lsp' },
\ ])
nmap <LocalLeader>qf <Cmd>LspCodeAction<CR>
nmap gd <Cmd>LspGotoDefinition<CR>
nmap <LocalLeader>gd <Cmd>tab LspGotoDefinition<CR>
nmap gr <Cmd>LspPeekReferences<CR>
nmap <LocalLeader>gr <Cmd>LspShowReferences<CR>
nnoremap <LocalLeader>K <Cmd>LspHover<CR>
nmap <LocalLeader>rn <Cmd>LspRename<CR>
nmap <Leader>o <Cmd>LspDocumentSymbol<CR>
nmap <Leader>O <Cmd>LspSymbolSearch<CR>
endif
