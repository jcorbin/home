return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "stevearc/dressing.nvim",

    "lalitmee/codecompanion-spinners.nvim",
    "nvim-lualine/lualine.nvim",

    "ravitemer/codecompanion-history.nvim",

  },

  config = function()
    require("codecompanion").setup({
      adapters = {
        http = {

          -- for @web_search tool
          tavily = function()
            return require("codecompanion.adapters").extend("tavily", {
              env = {
                -- cleartext key, but at least it's not in ambient environ
                api_key = 'cmd: cat ~/.config/api_keys/tavily',

                -- example for 1password
                -- api_key = "cmd:op read op://personal/Anthropic/credential --no-newline",

                -- example for gnupg
                -- api_key = 'cmd: gpg --batch --quiet --decrypt /path/to/api_key.gpg',
                -- TODO prep with `gpg -c /path/to/api_key`

                -- TODO lead for bitwarden
                -- api_key = vim.fn.system('bw get password "Gemini API Key"'):match("[^\n]+")
              },
            })
          end,

          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {

              env = {
                url = "http://doral:11434"
              },
              parameters = {
                sync = true,
              },

              opts = {
                vision = true,
                stream = true,
              },

              schema = {
                model = {
                  default = "glm-4.7-flash"
                },

                num_ctx = {
                  default = 131072,
                },

                -- think = {
                --   default = false,
                -- },

                -- num_predict = {
                --   default = -1,
                -- },

              },
            })
          end,
        },
      },

      prompt_library = {
        -- Users can define prompt library items in markdown
        markdown = {
          dirs = {
            '~/.config/nvim/cc_library',
          },
        },
      },

      strategies = {
        chat = {
          adapter = "ollama",
        },
        inline = {
          adapter = "ollama",
        },
      },

      display = {
        chat = {
          intro_message = "",

          show_context = true, -- Show context (from slash commands and variables) in the chat buffer?
          show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin

          -- show_settings = true, -- Show LLM settings at the top of the chat buffer?
          show_token_count = true, -- Show the token count for each response?
          show_tools_processing = true, -- Show the loading message when tools are being executed?

          fold_reasoning = true,
          show_reasoning = true,

        },
      },

      extensions = {
          spinner = {
              enabled = true,
              opts = {
                   style = "lualine",
              },
          },

          history = {
              enabled = true,
              opts = {
                  -- Keymap to open history from chat buffer (default: gh)
                  keymap = "gh",
                  -- Keymap to save the current chat manually (when auto_save is disabled)
                  save_chat_keymap = "sc",
                  -- Save all chats by default (disable to save only manually using 'sc')
                  auto_save = true,
                  -- Number of days after which chats are automatically deleted (0 to disable)
                  expiration_days = 0,
                  -- Picker interface (auto resolved to a valid picker)
                  picker = "telescope", --- ("telescope", "snacks", "fzf-lua", or "default") 

                  ---Optional filter function to control which chats are shown when browsing
                  chat_filter = function(chat_data)
                      return chat_data.cwd == vim.fn.getcwd()
                      -- return chat_data.project_root == utils.find_project_root()
                  end,

                  -- Customize picker keymaps (optional)
                  picker_keymaps = {
                      rename = { n = "<C-r>", i = "<M-r>" },
                      delete = { n = "<C-d>", i = "<M-d>" },
                      duplicate = { n = "<C-y>", i = "<C-y>" },
                  },

                  ---Automatically generate titles for new chats
                  auto_generate_title = true,
                  title_generation_opts = {
                      ---Adapter for generating titles (defaults to current chat adapter) 
                      adapter = nil, -- "copilot"
                      ---Model for generating titles (defaults to current chat model)
                      model = nil, -- "gpt-4o"
                      ---Number of user prompts after which to refresh the title (0 to disable)
                      refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
                      ---Maximum number of times to refresh the title (default: 3)
                      max_refreshes = 3,
                      format_title = function(original_title)
                          -- this can be a custom function that applies some custom
                          -- formatting to the title.
                          return original_title
                      end
                  },
                  ---On exiting and entering neovim, loads the last chat on opening chat
                  continue_last_chat = false,
                  ---When chat is cleared with `gx` delete the chat from history
                  delete_on_clearing_chat = false,
                  ---Directory path to save the chats
                  dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
                  ---Enable detailed logging for history extension
                  enable_logging = false,

                  -- Summary system
                  summary = {
                      -- Keymap to generate summary for current chat (default: "gcs")
                      create_summary_keymap = "gcs",
                      -- Keymap to browse summaries (default: "gbs")
                      browse_summaries_keymap = "gbs",
                      
                      generation_opts = {
                          adapter = nil, -- defaults to current chat adapter
                          model = nil, -- defaults to current chat model
                          context_size = 90000, -- max tokens that the model supports
                          include_references = true, -- include slash command content
                          include_tool_outputs = true, -- include tool execution results
                          system_prompt = nil, -- custom system prompt (string or function)
                          format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
                      },
                  },
                  
                  -- Memory system (requires VectorCode CLI)
                  memory = {
                      -- Automatically index summaries when they are generated
                      auto_create_memories_on_summary_generation = true,
                      -- Path to the VectorCode executable
                      vectorcode_exe = "vectorcode",
                      -- Tool configuration
                      tool_opts = { 
                          -- Default number of memories to retrieve
                          default_num = 10 
                      },
                      -- Enable notifications for indexing progress
                      notify = true,
                      -- Index all existing memories on startup
                      -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
                      index_on_startup = false,
                  },
              }
          }
      },

    })
  end,

  keys = {

    { "<LocalLeader>A",  mode = "n", "<cmd>CodeCompanionActions<cr>",     desc = "AI Actions" },
    { "<LocalLeader>A",  mode = "v", "<cmd>CodeCompanionActions<cr>",     desc = "AI Actions" },

    { "<LocalLeader>C",  mode = "n", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Chat" },
    { "<LocalLeader>C",  mode = "v", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Chat" },

    { "<LocalLeader>ca", mode = "v", "<cmd>CodeCompanionChat Add<cr>",    desc = "AI Add" },

    {
      "<LocalLeader>ce",
      mode = "v",
      function()
        require("codecompanion").prompt("explain")
      end
    },

    {
      "<LocalLeader>cl",
      mode = "n",
      function()
        require("codecompanion").prompt("lsp")
      end
    },

    {
      "<LocalLeader>cf",
      mode = "v",
      function()
        require("codecompanion").prompt("fix")
      end
    },

  },

  -- -- Expand 'cc' into 'CodeCompanion' in the command line
  -- vim.cmd([[cab cc CodeCompanion]])

}
