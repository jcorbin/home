local keymap = vim.keymap

-- use <Space> for mapleader
keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local mykeymap = {}

-- TODO desc support

-- creates a pair of mappings under the [ and ] family
mykeymap.pair = function(mode, key, prev, next, opts)
  local prev_opts = {}
  local next_opts = {}
  if opts then
    prev_opts = vim.tbl_extend('force', prev_opts, opts)
    next_opts = vim.tbl_extend('force', next_opts, opts)
    local desc = opts.desc
    if desc then
      prev_opts = vim.tbl_extend('force', prev_opts, { desc = 'Previous ' .. desc })
      next_opts = vim.tbl_extend('force', next_opts, { desc = 'Next ' .. desc })
    end
  end
  vim.keymap.set(mode, '[' .. key, prev, prev_opts)
  vim.keymap.set(mode, ']' .. key, next, next_opts)
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

mykeymap.opt_toggle = function(keys, name)
  vim.keymap.set('n', keys, function()
    if vim.opt[name]:get() then
      vim.opt[name] = false
      vim.notify('set no' .. name)
    else
      vim.opt[name] = true
      vim.notify('set ' .. name)
    end
  end, {
    desc = "toggle '" .. name .. "' option"
  })
end

return mykeymap
