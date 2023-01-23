local keymap = vim.keymap

-- use <Space> for mapleader
keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '

local mykeymap = {}

-- TODO desc support

-- creates a pair of mappings under the [ and ] family
mykeymap.pair = function(mode, key, prev, next)
  vim.keymap.set(mode, '[' .. key, prev)
  vim.keymap.set(mode, ']' .. key, next)
end

-- keymap.set combinator that adds a LHS prefix
mykeymap.prefix = function(prefix, mapper)
  if mapper == nil then
    mapper = vim.keymap.set
  end
  return function(mode, key, rhs, opts)
    local lhs = prefix .. key
    mapper(mode, lhs, rhs, opts)
  end
end

-- keymap.set combinator that fixes some options
--
-- Example use case would be fixing the { buffer } option within an
-- autocmd when binding filetype-specific keys
mykeymap.options = function(forced_opts, mapper)
  if mapper == nil then
    mapper = vim.keymap.set
  end
  return function(mode, lhs, rhs, opts)
    if opts == nil then
      opts = forced_opts
    else
      opts = vim.tbl_extend('force', opts, forced_opts)
    end
    mapper(mode, lhs, rhs, opts)
  end
end

mykeymap.leader = mykeymap.prefix '<Leader>'

return mykeymap
