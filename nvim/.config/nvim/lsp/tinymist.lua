vim.lsp.config('tinymist', {
  on_attach = function(client, bufnr)
      local mainFile = client.config.root_dir .. '/main.typ'

      -- see https://myriad-dreamin.github.io/tinymist/frontend/neovim.html#label-Working%20with%20Multiple-Files%20Projects
      client:exec_cmd({
        title = "pin",
        command = "tinymist.pinMain",
        arguments = { mainFile },
      }, { bufnr = bufnr })

      local opts = function(desc)
        return { desc = desc, buffer = bufnr, remap = false }
      end
      -- run preview
      vim.keymap.set("n", "<leader>rr", function()
        -- open mainfile
        vim.cmd("e " .. mainFile)
        -- run command
        vim.cmd.TypstPreview()
        -- reselect previous buffer
        vim.cmd("buffer " .. bufnr)
      end, opts("Start Typst preview"))
      -- stop preview
      vim.keymap.set("n", "<leader>rc", function()
        -- open mainfile
        vim.cmd("e " .. mainFile)
        -- run command
        vim.cmd.TypstPreviewStop()
        -- reselect previous buffer
        vim.cmd("buffer " .. bufnr)
      end, opts("Stop Typst preview"))
    end,
    offset_encoding = "utf-8",
    settings = {
      formatterMode = "typstyle",
      exportPdf = "onSave",
    },
})
