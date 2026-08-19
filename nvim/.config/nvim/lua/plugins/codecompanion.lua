-- Add `tag` (e.g. "#{buffer}"/"#{selection}") to the ongoing chat without
-- sending it, refreshing buffer_context first since a reused chat's context
-- is otherwise stale and the tag would resolve against the wrong buffer/selection.
local function chat_with_tag(tag)
  return function()
    local codecompanion = require("codecompanion")
    local context = require("codecompanion.utils.context").get(vim.api.nvim_get_current_buf())
    local chat = codecompanion.last_chat()
    if chat then
      chat.buffer_context = context
    else
      chat = codecompanion.chat({ context = context })
    end
    if not chat then
      return
    end
    chat:add_buf_message({ role = require("codecompanion.config").constants.USER_ROLE, content = tag })
    chat.ui:open()
  end
end

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "j-hui/fidget.nvim",
  },
  opts = {
    adapters = {
      acp = {
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            commands = {
              default = { "npx", "@agentclientprotocol/claude-agent-acp" },
            },
            env = {
              CLAUDE_CODE_OAUTH_TOKEN = ("cmd:security find-generic-password -a %s -s 'anthropic-claude' -w | tr -d '\\n'")
                  :format(vim.env.USER),
            },
          })
        end,
      },
    },
    interactions = {
      chat = {
        adapter = "claude_code",
        keymaps = {
          send = {
            modes = {
              n = { "<C-s>" },
              i = { "<C-s>" },
            },
          },
          close = false,
        },
      },
      cli = {
        agent = "claude_code",
        agents = {
          claude_code = {
            cmd = "claude",
            args = {},
            description = "Claude Code CLI",
          },
        },
      },
    },
  },
  keys = {
    -- Toggle / Focus
    { "<leader>ac", function() require("codecompanion").toggle() end, mode = { "n", "v" },        desc = "Toggle Claude" },

    { "<leader>ab", chat_with_tag("#{buffer}"),                       desc = "Add current buffer" },
    { "<leader>as", chat_with_tag("#{selection}"),                    mode = "v",                 desc = "Send selection to Claude" },
  },
  config = function(_, opts)
    require("codecompanion").setup(opts)

    -- Fidget spinner while a request is in-flight (keyed by bufnr, so it can
    -- be hidden/resumed around approval prompts for that same chat below).
    local handles = {}
    local titles = {}
    local group = vim.api.nvim_create_augroup("CodeCompanionFidgetSpinner", {})

    local function start_thinking(bufnr, title)
      handles[bufnr] = require("fidget.progress").handle.create({
        title = title,
        message = "In progress...",
        lsp_client = { name = "CodeCompanion" },
      })
    end

    -- The fidget window overlaps the bottom-right corner of whichever window
    -- is showing this buffer, hiding the last lines; `zz` recenters the
    -- cursor's line so it clears the overlay.
    local function recenter(bufnr)
      if not bufnr then
        return
      end
      for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        vim.api.nvim_win_call(win, function()
          vim.cmd("normal! zz")
        end)
      end
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionRequestStarted",
      group = group,
      callback = function(request)
        local data = request.data or {}
        local bufnr = data.bufnr
        if not bufnr then
          return
        end
        local adapter_name = data.adapter and data.adapter.formatted_name or "LLM"
        local title = "CodeCompanion is thinking (" .. adapter_name .. ")"
        titles[bufnr] = title
        start_thinking(bufnr, title)
        recenter(bufnr)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionRequestFinished",
      group = group,
      callback = function(request)
        local bufnr = request.data and request.data.bufnr
        local handle = bufnr and handles[bufnr]
        if handle then
          handle.message = "Done"
          handle:finish()
        end
        if bufnr then
          handles[bufnr] = nil
          titles[bufnr] = nil
        end
        recenter(bufnr)
      end,
    })

    -- Fidget toast when a tool call needs approval (keyed by bufnr, so the
    -- "resolved" notification replaces the "review needed" one in place).
    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionToolApprovalRequested",
      group = group,
      callback = function(request)
        local data = request.data or {}
        local bufnr = data.bufnr

        -- Hide the "thinking" spinner while it's actually waiting on us
        if bufnr and handles[bufnr] then
          handles[bufnr]:finish()
          handles[bufnr] = nil
        end

        local name = data.name and (" (" .. data.name .. ")") or ""
        require("fidget").notify("Review required" .. name, vim.log.levels.WARN, {
          key = "codecompanion-approval-" .. tostring(bufnr),
          annote = "CodeCompanion",
          ttl = 30,
        })
        recenter(bufnr)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionToolApprovalFinished",
      group = group,
      callback = function(request)
        local data = request.data or {}
        local bufnr = data.bufnr

        require("fidget").notify("Tool call " .. (data.choice or "resolved"), vim.log.levels.INFO, {
          key = "codecompanion-approval-" .. tostring(bufnr),
          annote = "CodeCompanion",
          ttl = 3,
        })

        -- Resume the "thinking" spinner now that the request is unblocked
        if bufnr and titles[bufnr] then
          start_thinking(bufnr, titles[bufnr])
        end
        recenter(bufnr)
      end,
    })

    -- `gv` on a proposed edit opens a floating diff showing just the hunk the
    -- agent reported, not the surrounding file. On request (`gv` again), reconstruct
    -- the change against the real file's current content and open a native
    -- Neovim diff (`:diffthis`) so the whole file is visible with the
    -- proposed change highlighted in place.
    local function open_full_file_diff(diff_bufnr, path)
      local ok_lines, file_lines = pcall(vim.fn.readfile, path)
      if not ok_lines then
        return vim.notify("codecompanion: could not read " .. path, vim.log.levels.ERROR)
      end

      -- Classify each line in the diff buffer via its highlight extmark, so
      -- the old/new snippet can be recovered without the original tool_call.
      local merged = vim.api.nvim_buf_get_lines(diff_bufnr, 0, -1, false)
      local extmarks = vim.api.nvim_buf_get_extmarks(diff_bufnr, -1, 0, -1, { details = true })
      local line_type = {}
      for _, mark in ipairs(extmarks) do
        local hl = mark[4] and mark[4].line_hl_group
        if hl == "CodeCompanionDiffAdd" then
          line_type[mark[2]] = "addition"
        elseif hl == "CodeCompanionDiffDelete" then
          line_type[mark[2]] = "deletion"
        end
      end
      local old_snippet, new_snippet = {}, {}
      for i, line in ipairs(merged) do
        local t = line_type[i - 1]
        if t ~= "addition" then
          table.insert(old_snippet, line)
        end
        if t ~= "deletion" then
          table.insert(new_snippet, line)
        end
      end

      local function find_subsequence(haystack, needle)
        if #needle == 0 then
          return nil
        end
        for start = 1, #haystack - #needle + 1 do
          local match = true
          for j = 1, #needle do
            if haystack[start + j - 1] ~= needle[j] then
              match = false
              break
            end
          end
          if match then
            return start
          end
        end
        return nil
      end

      local start_idx = find_subsequence(file_lines, old_snippet)
      local full_new_lines
      if start_idx then
        full_new_lines = {}
        vim.list_extend(full_new_lines, file_lines, 1, start_idx - 1)
        vim.list_extend(full_new_lines, new_snippet)
        vim.list_extend(full_new_lines, file_lines, start_idx + #old_snippet, #file_lines)
      else
        vim.notify(
          "codecompanion: couldn't locate the change in the file; showing the snippet only",
          vim.log.levels.WARN
        )
        full_new_lines = new_snippet
      end

      vim.cmd("tabedit " .. vim.fn.fnameescape(path))
      vim.cmd("diffthis")
      vim.cmd("vsplit")
      local scratch = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(scratch, 0, -1, false, full_new_lines)
      vim.api.nvim_set_option_value("filetype", vim.bo[diff_bufnr].filetype, { buf = scratch })
      vim.api.nvim_win_set_buf(0, scratch)
      vim.cmd("diffthis")
    end

    -- Uses BufWinEnter, not WinEnter: nvim_open_win() fires WinEnter before
    -- the float's real buffer is attached (briefly showing a placeholder),
    -- so a keymap set there lands on the wrong, transient buffer.
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = group,
      callback = function()
        local win = vim.api.nvim_get_current_win()
        local ok, win_cfg = pcall(vim.api.nvim_win_get_config, win)
        if not ok or win_cfg.relative == "" then
          return
        end

        local title = win_cfg.title
        if type(title) == "table" then
          local parts = {}
          for _, chunk in ipairs(title) do
            table.insert(parts, chunk[1] or "")
          end
          title = table.concat(parts)
        end
        -- create_float() pads the title with spaces for display purposes
        title = type(title) == "string" and vim.trim(title) or nil
        if not title or vim.fn.filereadable(title) ~= 1 then
          return
        end

        local diff_bufnr = vim.api.nvim_win_get_buf(win)
        vim.keymap.set("n", "gv", function()
          open_full_file_diff(diff_bufnr, title)
        end, { buffer = diff_bufnr, desc = "Diff full file against proposed change", nowait = true })
      end,
    })
  end,
}
