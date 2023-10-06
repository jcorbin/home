local augroup = require 'my.augroup'
local mykeymap = require 'my.keymap'
local autocmd = augroup 'plugins.lsp'

local telescopes = require 'telescope.builtin'

local on_lsp_attach = function(caps, bufnr)
  local lsp = vim.lsp

  local autocmd_local = autocmd.buffer(bufnr)

  local map_buffer = mykeymap.options { buffer = bufnr }
  local map_local = mykeymap.prefix('<LocalLeader>', map_buffer)

  map_buffer('n', '<C-k>', lsp.buf.signature_help)

  -- keymaps to jump
  map_buffer('n', '<c-]>', lsp.buf.definition, { desc = 'jump to definition (lsp)' })
  map_local('n', 'gD', lsp.buf.declaration, { desc = 'jump to declaration (lsp)' })
  map_local('n', 'gI', lsp.buf.implementation, { desc = 'jump to implementation (lsp)' })
  map_local('n', 'gT', lsp.buf.type_definition, { desc = 'jump to type definition (lsp)' })

  -- keymaps to act on code
  map_local('n', 'a', lsp.buf.code_action, { desc = 'invoke code action (lsp)' })
  map_local('n', 'f', lsp.buf.format, { desc = 'format buffer (lsp)' })
  map_local('n', 'gR', lsp.buf.rename, { desc = 'rename symbol (lsp)' })
  -- TODO format range/object

  -- telescope invocations
  map_local('n', 'sr', telescopes.lsp_references, { desc = 'search lsp references' })
  map_local('n', 'so', telescopes.lsp_document_symbols, { desc = 'search lsp document symbosl' })
  map_local('n', 'sw', telescopes.lsp_workspace_symbols, { desc = 'search lsp workspace symbols' })

  local ft = vim.opt_local.filetype:get()
  -- auto formatting
  if ft ~= "openscad" then
    autocmd_local('BufWritePre', function()
      -- NOTE: sync 1s timeout is the default, may pass {timeout_ms} or {async}
      lsp.buf.format()
    end)
  end

  -- cursor hold highlighting
  if caps['textDocument/documentHighlight'] ~= nil then
    autocmd_local({ 'CursorHold', 'CursorHoldI' }, function()
      lsp.buf.document_highlight()
    end)
    autocmd_local('CursorMoved', function()
      lsp.buf.clear_references()
    end)
  end

  -- Use LSP as the handler for formatexpr.
  --    See `:help formatexpr` for more information.
  vim.api.nvim_buf_set_option_value('formatexpr', 'v:lua.vim.lsp.formatexpr()')

  if caps['textDocument/codeLens'] ~= nil then
    autocmd_local({ 'BufEnter', 'CursorHold', 'InsertLeave' }, function()
      lsp.codelens.refresh()
    end)
  end
end

local function setup_server(name, opts)
  if opts == nil then
    opts = {}
  end
  local lspconfig = require 'lspconfig'
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  lspconfig[name].setup(vim.tbl_extend('keep', opts, {
    on_attach = on_lsp_attach,
    capabilities = capabilities,
  }))
end

return {
  setup_server = setup_server,
}
