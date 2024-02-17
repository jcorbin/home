local initls = require('my.lsp').setup_server

initls 'bashls'

initls 'cssls'

initls 'dockerls'

initls('glslls', {
  cmd = {
    "glslls",
    "--stdin",
    "--target-env", "opengl",
    -- [vulkan vulkan1.0 vulkan1.1 vulkan1.2 vulkan1.3 opengl opengl4.5]
  },
})

initls 'gopls'

initls 'html'

initls 'jsonls'

initls('lua_ls', {
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
})

initls('openscad_lsp', {
  cmd = { "openscad-lsp", "--stdio", "--fmt-style", "file" },
})

initls('pylsp', {
  settings = {
    -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = {
            -- NOTE these don't actually work for pylint... what even is the point of pycodestyle?
            'C0114', -- missing-module-docstring
            'C0115', -- missing-class-docstring
            'C0116', -- missing-function-docstring
          },
          maxLineLength = 100
        },
        jedi_completion = {
          fuzzy = true,
          eager = true,
        },

        -- TODO useful or not w/ pycodestyle?
        pylint = {
          enabled = false,
        },

        -- TODO decide on black vs yapf
        black = {
          enabled = false,
          line_length = 100,
        },
        yapf = {
          enabled = true,
        },
      }
    }
  }
})

initls 'rust_analyzer'
-- https://github.com/rust-analyzer/rust-analyzer/tree/master/docs/user#settings

initls('tsserver', {
  completions = {
    completeFunctionCalls = true,
  },

  init_options = {
    preferences = {

      includeInlayParameterNameHints = 'all',
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,

      -- works, but too noisy imo
      -- includeInlayFunctionParameterTypeHints = true,

      -- broken
      -- includeInlayFunctionLikeReturnTypeHints = true,
      -- includeInlayVariableTypeHints = true,

      -- untested
      -- includeInlayPropertyDeclarationTypeHints = true,
      -- includeInlayEnumMemberValueHints = true,
      -- importModuleSpecifierPreference = 'non-relative',

    },
  },
})

initls 'yamlls'

initls 'vimls'

initls 'zls'
