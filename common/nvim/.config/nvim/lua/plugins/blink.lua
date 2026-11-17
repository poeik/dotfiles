return {
  'saghen/blink.cmp',
  version = '1.*', -- v2 is under active development currently
  event = { 'InsertEnter', 'CmdlineEnter' },
  opts = {
    -- <CR> accepts, <C-n>/<C-p> select, <C-y> accepts, <C-e> hides, <Tab> only jumps in snippets
    keymap = { preset = 'enter' },
    appearance = { nerd_font_variant = 'mono' },
    completion = { documentation = { auto_show = true } },
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
        snippets = { min_keyword_length = 2 },
        buffer = { min_keyword_length = 3 },
      },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
  opts_extend = { 'sources.default' },
}
