return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp'
  },
  opts = {
    servers = {
      arduino_language_server = {},
      basedpyright = {},
      bashls = {
        filetypes = { 'sh', 'bash', 'zsh' },
      },
      clangd = {},
      cssls = {},
      dockerls = {},
      glslls = {
        cmd = {
          "glslls",
          "--stdin",
          "--target-env", "opengl",
          -- [vulkan vulkan1.0 vulkan1.1 vulkan1.2 vulkan1.3 opengl opengl4.5]
        },
      },
      gopls = {},
      html = {},
      jsonls = {},
      lua_ls = {
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { 'vim' },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
          },
        },
      },
      openscad_lsp = {
        cmd = { "openscad-lsp", "--stdio", "--fmt-style", "file" },
      },
      rust_analyzer = {},
      -- https://github.com/rust-analyzer/rust-analyzer/tree/master/docs/user#settings
      ts_ls = {},
      -- tsserver = {
      --   completions = {
      --     completeFunctionCalls = true,
      --   },
      --
      --   init_options = {
      --     preferences = {
      --       includeInlayParameterNameHints = 'all',
      --       includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      --
      --       -- works, but too noisy imo
      --       -- includeInlayFunctionParameterTypeHints = true,
      --
      --       -- broken
      --       -- includeInlayFunctionLikeReturnTypeHints = true,
      --       -- includeInlayVariableTypeHints = true,
      --
      --       -- untested
      --       -- includeInlayPropertyDeclarationTypeHints = true,
      --       -- includeInlayEnumMemberValueHints = true,
      --       -- importModuleSpecifierPreference = 'non-relative',
      --
      --     },
      --   },
      -- },
      yamlls = {},
      vimls = {},
      zls = {},
    }
  },

  config = function(_, opts)
    local lspconfig = require('lspconfig')
    local cmp = require('blink.cmp')
    for server, config in pairs(opts.servers) do
      config.capabilities = cmp.get_lsp_capabilities(config.capabilities)
      lspconfig[server].setup(config)
    end
  end
}
