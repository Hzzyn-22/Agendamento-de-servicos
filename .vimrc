syntax on
set number

" Definição de grupos de destaque por tags semânticas
augroup ComentariosSemanticos
  autocmd!
  autocmd Syntax * syntax match TagFluxo /\/\/.*\[FLUXO\].*/ containedin=ALL
  autocmd Syntax * syntax match TagTransf /\/\/.*\[TRANSF\].*/ containedin=ALL
  autocmd Syntax * syntax match TagErro /\/\/.*\[ERRO\].*/ containedin=ALL
  " Suporte também para comentários em Bash (#)
  autocmd Syntax * syntax match TagFluxo /#.*\[FLUXO\].*/ containedin=ALL
  autocmd Syntax * syntax match TagTransf /#.*\[TRANSF\].*/ containedin=ALL
  autocmd Syntax * syntax match TagErro /#.*\[ERRO\].*/ containedin=ALL
augroup END

" Estilização das cores (Terminal 256 cores / Google Cloud Shell / Debian)
highlight TagFluxo ctermfg=39 guifg=#00afff cterm=bold
highlight TagTransf ctermfg=46 guifg=#00ff00 cterm=bold
highlight TagErro ctermfg=196 guifg=#ff0000 cterm=bold
