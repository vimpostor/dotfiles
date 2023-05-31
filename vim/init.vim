set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc


call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()
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
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#next(1) : CheckBackspace() ? "\<Tab>" : coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
func CheckBackspace() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1] =~# '\s'
endfunc
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> <LocalLeader>K :call <SID>show_documentation()<CR>
func s:show_documentation()
	if (index(['vim','help'], &filetype) >= 0)
	execute 'h '.expand('<cword>')
	else
		call CocAction('doHover')
	endif
endfunc
au CursorHold * silent call CocActionAsync('highlight') "highlight symbol on cursor hold
nmap <LocalLeader>rn <Plug>(coc-rename)
xmap <LocalLeader>f <Plug>(coc-format-selected)
xmap <LocalLeader>a <Plug>(coc-codeaction-selected)
nmap <LocalLeader>a <Plug>(coc-codeaction-selected)
nmap <LocalLeader>ac <Plug>(coc-codeaction)
nmap <LocalLeader>al <Plug>(coc-codeaction-line)
nmap <LocalLeader>qf <Plug>(coc-fix-current)
"function text objects
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
command! -nargs=0 Format :call CocAction('format')
nnoremap <silent> <Leader>e :<C-u>CocList diagnostics<cr>
nnoremap <silent> <Leader>o :<C-u>CocList outline<cr>
nnoremap <silent> <Leader>s :<C-u>CocList -I symbols<cr>
"snippets
imap <C-j> <Plug>(coc-snippets-expand-jump)
"coc-texlab
if has('nvim')
	nnoremap <silent> <Leader>ll :<C-u>CocCommand latex.Build<CR>
else
	nnoremap <silent> <Leader>ll :<C-u>call remote_startserver("synctex")<CR>:CocCommand latex.Build<CR>
endif
nnoremap <silent> <Leader>lv :<C-u>CocCommand latex.ForwardSearch<CR>
