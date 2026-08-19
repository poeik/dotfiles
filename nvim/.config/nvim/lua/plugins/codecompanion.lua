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
              n = { "<CR>", "<C-s>" },
              i = "<CR>",
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
    { "<leader>ac", function() require("codecompanion").toggle() end,                                                       mode = { "n", "v" },        desc = "Toggle Claude" },

    { "<leader>ab", chat_with_tag("#{buffer}"),    desc = "Add current buffer" },
    { "<leader>as", chat_with_tag("#{selection}"), mode = "v", desc = "Send selection to Claude" },
  },
  config = function(_, opts)
    require("codecompanion").setup(opts)

    -- Fidget spinner while a request is in-flight (keyed by request id, so
    -- concurrent chat/cli requests each get their own progress handle).
    local handles = {}
    local group = vim.api.nvim_create_augroup("CodeCompanionFidgetSpinner", {})

    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionRequestStarted",
      group = group,
      callback = function(request)
        local data = request.data or {}
        local adapter_name = data.adapter and data.adapter.formatted_name or "LLM"
        handles[data.id] = require("fidget.progress").handle.create({
          title = "CodeCompanion is thinking (" .. adapter_name .. ")",
          message = "In progress...",
          lsp_client = { name = "CodeCompanion" },
        })
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionRequestFinished",
      group = group,
      callback = function(request)
        local id = request.data and request.data.id
        local handle = handles[id]
        if handle then
          handle.message = "Done"
          handle:finish()
          handles[id] = nil
        end
      end,
    })

    -- Fidget toast when a tool call needs approval (keyed by bufnr, so the
    -- "resolved" notification replaces the "review needed" one in place).
    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionToolApprovalRequested",
      group = group,
      callback = function(request)
        local data = request.data or {}
        local name = data.name and (" (" .. data.name .. ")") or ""
        require("fidget").notify("Review required" .. name, vim.log.levels.WARN, {
          key = "codecompanion-approval-" .. tostring(data.bufnr),
          annote = "CodeCompanion",
          ttl = 30,
        })
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionToolApprovalFinished",
      group = group,
      callback = function(request)
        local data = request.data or {}
        require("fidget").notify("Tool call " .. (data.choice or "resolved"), vim.log.levels.INFO, {
          key = "codecompanion-approval-" .. tostring(data.bufnr),
          annote = "CodeCompanion",
          ttl = 3,
        })
      end,
    })
  end,
}
