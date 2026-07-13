function! nvim_treesitter#foldexpr() abort
  if !&l:foldenable
    return 0
  endif

  if !has('nvim')
    return 0
  endif

  return v:lua.vim.treesitter.foldexpr()
endfunction
