-- autocmd helper object around lower level vim.api.nvim_create_augroup etc functions
--
-- usage:
--
--   local group = augroup('MyCommands')
--
--   -- pattern defaults to '*' if not given or you can pass it
--   group('BufEnter', do_stuff)
--   group('BufEnter', '*.js', do_stuff)
--
--   -- additional options may be passed thru to vim.api.nvim_create_autocmd
--   group('BufEnter', do_stuff, {desc = 'bla'})
--   group('BufEnter', '*.js', do_stuff, {desc = 'bla'})
--
--   -- can create a buffer-local sub group
--   group('FileType', 'java', function(opts)
--     local group_local = group.buffer(opts.buf)
--     group_local('CursorHoldI', function()
--       vim.notify('Keep Typing! You're getting paid by the character!')
--     end)
--   end)
--
local augroup = function(name)
  local group = vim.api.nvim_create_augroup(name, { clear = true })

  local make

  make = function(fixed_opts)
    return setmetatable({

      buffer = function(bufnr)
        local sub = make(vim.tbl_extend('force', fixed_opts, { buffer = bufnr }))
        sub.clear()
        return sub
      end,

      clear = function(opts)
        vim.api.nvim_clear_autocmds(vim.tbl_extend('force', opts or {}, fixed_opts))
      end,

    }, {
      __call = function(self, ...)
        local event, action, opts

        if fixed_opts.buffer == nil then
          local pattern
          event, pattern, action, opts = ...
          if opts == nil and type(action) == 'table' then
            opts = action
            action = nil
          end
          if action == nil then
            action = pattern
            pattern = '*'
          end
          opts = vim.tbl_extend('force', opts or {}, { pattern = pattern })
        else
          event, action, opts = ...
        end

        opts = vim.tbl_extend('force', opts or {}, fixed_opts)

        if type(action) == 'function' then
          opts.callback = action
        else
          opts.command = action
        end

        return vim.api.nvim_create_autocmd(event, opts)
      end
    })

  end

  return make({ group = group })
end

return augroup
