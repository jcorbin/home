return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "stevearc/dressing.nvim",
    -- { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
  },

  config = function()
    require("codecompanion").setup({
      adapters = {
        http = {
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

      strategies = {
        chat = {
          adapter = "ollama",
        },
        inline = {
          adapter = "ollama",
        },
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
