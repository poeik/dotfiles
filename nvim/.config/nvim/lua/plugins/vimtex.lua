return {
  'lervag/vimtex',
  config = function()
    vim.api.nvim_set_var('maplocalleader', ' ')
    -- This is necessary for VimTeX to load properly. The "indent" is optional.
    -- Note that most plugin managers will do this automatically.
    vim.cmd('filetype plugin indent on')
    -- opens quickfix only if there are errors
    vim.g.vimtex_quickfix_open_on_warning = 0
    -- open quickfix window not automatically
    vim.g.tex_flavor='latex'
    -- show some latex symbols only when on corresponding line
    --vim.opt.conceallevel = 1
    --vim.g.tex_conceal = 'abdmg'

    -- This enables Vim's and neovim's syntax-related features. Without this, some
    -- VimTeX features will not work (see ":help vimtex-requirements" for more
    -- info).
    -- vim.cmd('syntax enable')

    -- Viewer options: One may configure the viewer either by specifying a built-in
    -- viewer method:
    vim.g.vimtex_view_method = 'skim'
    vim.g.vimtex_compiler_latexmk = {
      aux_dir = 'build',
      out_dir = 'build',
    }
    -- for tex files width to 80
    vim.cmd([[
    augroup WrapLineInTeXFile
    autocmd!
    autocmd FileType tex setlocal tw=79
    augroup END
    ]])

    vim.keymap.set({"n", "v"}, "<localleader>cl", [[:! rm -rf build & find . -name "*.aux" -delete<CR>]])
  end

}
