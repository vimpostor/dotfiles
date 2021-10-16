if !isdirectory(glob('~/.vim/plugged'))
	"Install vim-plug
	silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdcommenter' "easier commenting
Plug 'terryma/vim-multiple-cursors' "multiple cursors
Plug 'honza/vim-snippets' "snippets
Plug 'tpope/vim-surround' "surround commands
Plug 'easymotion/vim-easymotion' "even faster movement
Plug 'tpope/vim-fugitive' "handy git tools
Plug 'markonm/traces.vim' "pattern preview
Plug 'vimpostor/vim-prism' "colorscheme
Plug 'https://gitlab.com/dbeniamine/cheat.sh-vim.git' "cheat sheets
Plug 'dense-analysis/ale' "linting
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'puremourning/vimspector' "debugging
Plug 'vimpostor/vim-tpipeline' "outsource statusline to tmux
Plug 'junegunn/fzf.vim' "fzf integration
call plug#end()

"color scheme
set background=dark
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
silent! set stl=%!tpipeline#stl#line()
set laststatus=2 "always show the statusline
set noshowmode "dont show mode
set noruler "no curser position
set noshowcmd "don't show cmds
set mouse=a "enable mouse input
set t_ut="" "prevents a weird background on some terminals
set lazyredraw
set hidden "allow buffers to be hidden
set shortmess+=c "don't give ins-completion-menu messages
set shortmess-=S "show number of search matches
"do not write backup files, they cause more problems than they solve
set nobackup
set nowritebackup
set autoread
if has('termguicolors') "true colors
	let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
	set termguicolors
endif
"keep selected text selected when indenting
xnoremap < <gv
xnoremap > >gv
"allow completions from the dictionary
set complete+=kspell
set diffopt+=vertical
"split like a normal human being
set splitbelow
set splitright

"file type specific settings
autocmd Filetype yaml setlocal ts=2 sw=2 et
autocmd Filetype yaml if expand('%:p:h') =~# 'playbooks\|tasks\|handlers' | setlocal ft=yaml.ansible | endif
autocmd Filetype tex setlocal conceallevel=1 spell
autocmd Filetype markdown setlocal spell
autocmd Filetype gitcommit setlocal spell
au BufRead /tmp/mutt-* setlocal fo+=aw spell spelllang=en,de
autocmd FileType haskell setlocal expandtab
"switch between header and source
autocmd Filetype c,cpp nnoremap <silent> <F4> :<C-u>CocCommand clangd.switchSourceHeader<CR>

"pandoc
command PandocDisable autocmd! Pandoc BufWritePost *
command PandocEnable exe 'silent! PandocDisable!' | exe 'augroup Pandoc' | exe 'silent !pandoc % -o /tmp/%:t.pdf && xdg-open /tmp/%:t.pdf' | exe 'autocmd BufWritePost * silent! !pandoc % -o /tmp/%:t.pdf' | exe 'augroup END' | exe 'redraw!'

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
nnoremap <silent> J :<C-U>exec "exec 'norm m`' \| move +" . v:count1<CR>==``
nnoremap <silent> K :<C-U>exec "exec 'norm m`' \| move -" . (1+v:count1)<CR>==``
xnoremap <silent> J :<C-U>exec "'<,'>move '>+" . v:count1<CR>gv=gv
xnoremap <silent> K :<C-U>exec "'<,'>move '<-" . (1+v:count1)<CR>gv=gv
"quickfix
nmap <silent> <C-q> :call ToggleQf()<CR>
nmap <silent> <Leader>J :cnext<CR>
nmap <silent> <Leader>K :cprev<CR>
nmap <silent> <Leader>j :lbelow<CR>
nmap <silent> <Leader>k :labove<CR>
"join lines
nnoremap <LocalLeader>J J
xnoremap <LocalLeader>J J
"clear search
nnoremap <silent> <Leader>/ :nohl<CR>
"switch to last buffer
nnoremap <Leader><Leader> <c-^>
"autocorrect last misspelling
imap <c-v> <c-g>u<Esc>[s1z=`]a<c-g>u
"do not overwrite my keybindings in rebase mode
let g:no_gitrebase_maps = 1
"write with sudo
command SudoWrite execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

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
		let line = getline('.')
		let start = col('.') - 1
		while start > 0 && line[start - 1] =~ '\a'
			let start -= 1
		endwhile
		return start
	else
		let res = []
		let h = ''
		for l in split(system('aiksaurus '.shellescape(a:base)), '\n')
			if l[:3] == '=== '
				let h = substitute(l[4:], ' =*$', '', '')
			elseif l[0] =~ '\a'
				call extend(res, map(split(l, ', '), {_, val -> {'word': val, 'menu': '('.h.')'}}))
			endif
		endfor
		return res
	endif
endfunc
if has('patch-8.2.3520')
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
exec 'hi ALEVirtualTextWarning cterm=italic guifg='.synIDattr(hlID('WarningMsg'),'fg').' guibg='.synIDattr(hlID('CursorLine'),'bg')
exec 'hi ALEVirtualTextError cterm=italic guifg='.synIDattr(hlID('ErrorMsg'),'fg').' guibg='.synIDattr(hlID('CursorLine'),'bg')

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
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
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
autocmd CursorHold * silent call CocActionAsync('highlight') "highlight symbol on cursor hold
nmap <LocalLeader>rn <Plug>(coc-rename)
xmap <LocalLeader>f  <Plug>(coc-format-selected)
nmap <LocalLeader>f  <Plug>(coc-format-selected)
augroup mygroup
  autocmd!
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected') "Setup formatexpr specified filetype(s).
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp') "Update signature help on jump placeholder
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
nnoremap <silent> <Leader>p  :<C-u>CocListResume<CR>
"snippets
imap <C-j> <Plug>(coc-snippets-expand-jump)
"coc-texlab
nnoremap <silent> <Leader>ll :<C-u>CocCommand latex.Build<CR>
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
