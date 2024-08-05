return {
  -- Using this as a barrel file
  -- lz.n doesn't seem to be picking up other plugin specs
  -- because Nix is using a symlink for the files
  require 'plugins.lsp',
  require 'plugins.telescope',

  {
    'nvim-treesitter',
    event = 'DeferredUIEnter',
    after = function()
      local configs = require 'nvim-treesitter.configs'
      configs.setup {
        highlight = {
          enable = true,
        },
        indent = { enable = true },
      }
    end,
  },
  {
    'mini.diff',
    enabled = not vim.g.vscode,
    event = 'DeferredUIEnter',
    after = function()
      local diff = require 'mini.diff'
      diff.setup {
        view = { style = 'sign' },
      }
      vim.keymap.set('n', 'dh', diff.toggle_overlay, { desc = 'Toggle [d]iff [h]unks' })
    end,
  },
  {
    'diffview.nvim',
    enabled = not vim.g.vscode,
    cmd = {
      'DiffviewOpen',
      'DiffviewFileHistory',
      'DiffviewFocusFiles',
      'DiffviewLog',
    },
    after = function()
      require('diffview').setup()
    end,
  },
  {
    'mini.ai',
    keys = { 'a', 'i' },
    after = function()
      require('mini.ai').setup()
    end,
  },
  {
    -- TODO: `MiniGit` doesn't get assinged to the global object
    'mini.git',
    enabled = not vim.g.vscode,
    event = 'CmdlineEnter',
    after = function()
      require('mini.git').setup()
    end,
  },
  {
    'mini.animate',
    enabled = not vim.g.vscode,
    event = 'CursorMoved',
    after = function()
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false

      for _, scroll in ipairs { 'Up', 'Down' } do
        local key = '<ScrollWheel' .. scroll .. '>'
        vim.keymap.set({ '', 'i' }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      local animate = require 'mini.animate'
      animate.setup {
        cursor = { enable = false },
        resize = {
          timing = animate.gen_timing.linear { duration = 50, unit = 'total' },
        },
        scroll = {
          timing = animate.gen_timing.linear { duration = 150, unit = 'total' },
          subscroll = animate.gen_subscroll.equal {
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          },
        },
      }
    end,
  },
  {
    'mini.icons',
    enabled = not vim.g.vscode,
    event = 'DeferredUIEnter',
    after = function()
      require('mini.icons').setup()
      MiniIcons.mock_nvim_web_devicons()
    end,
  },
  {
    'oil.nvim',
    enabled = not vim.g.vscode,
    keys = {
      { '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' } },
    },
    after = function()
      require('oil').setup()
    end,
  },
  {
    'mini.clue',
    enabled = not vim.g.vscode,
    keys = {
      { '<leader>', mode = { 'n', 'x' } },
      { '<C-x>', mode = { 'n', 'x' } },
      { 'g', mode = { 'n', 'x' } },
      { "'", mode = { 'n', 'x' } },
      { '`', mode = { 'n', 'x' } },
      { '"', mode = { 'n', 'x' } },
      { '<C-r>', mode = { 'n', 'x' } },
      '<C-w>',
      { 'z', mode = { 'n', 'x' } },
    },
    after = function()
      local miniclue = require 'mini.clue'
      miniclue.setup {
        window = {
          config = {
            width = 60,
          },
        },
        triggers = {
          -- Leader triggers
          { mode = 'n', keys = '<Leader>' },
          { mode = 'x', keys = '<Leader>' },
          -- Built-in completion
          { mode = 'i', keys = '<C-x>' },
          -- `g` key
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },
          -- Marks
          { mode = 'n', keys = "'" },
          { mode = 'n', keys = '`' },
          { mode = 'x', keys = "'" },
          { mode = 'x', keys = '`' },
          -- Registers
          { mode = 'n', keys = '"' },
          { mode = 'x', keys = '"' },
          { mode = 'i', keys = '<C-r>' },
          { mode = 'c', keys = '<C-r>' },
          -- Window commands
          { mode = 'n', keys = '<C-w>' },
          -- `z` key
          { mode = 'n', keys = 'z' },
          { mode = 'x', keys = 'z' },
        },
        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
      }
    end,
  },
  {
    'mini.pairs',
    event = 'InsertEnter',
    after = function()
      require('mini.pairs').setup {}
    end,
  },
  {

    'mini.surround',
    keys = {
      { 'sr', mode = { 'n', 'x' } },
      { 'sa', mode = { 'n', 'x' } },
      { 'sd', mode = { 'n', 'x' } },
    },
    after = function()
      require('mini.surround').setup {
        n_lines = 200,
      }
    end,
  },
  {
    'mini.indentscope',
    enabled = not vim.g.vscode,
    event = 'CursorMoved',
    after = function()
      require('mini.indentscope').setup {
        draw = {
          delay = 0,
          animation = function()
            return 0
          end,
        },
        symbol = '│',
      }
    end,
  },
  {
    'conform.nvim',
    enabled = not vim.g.vscode,
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    after = function()
      require('conform').setup {
        format_on_save = {
          timeout_ms = 500,
          lsp_format = 'fallback',
        },
        formatters_by_ft = {
          lua = { 'stylua' },
          javascript = { 'prettierd', 'prettier', stop_after_first = true },
          javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
          typescript = { 'prettierd', 'prettier', stop_after_first = true },
          typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
          vue = { 'prettierd', 'prettier', stop_after_first = true },
          css = { 'prettierd', 'prettier', stop_after_first = true },
          scss = { 'prettierd', 'prettier', stop_after_first = true },
          less = { 'prettierd', 'prettier', stop_after_first = true },
          html = { 'prettierd', 'prettier', stop_after_first = true },
          json = { 'prettierd', 'prettier', stop_after_first = true },
          jsonc = { 'prettierd', 'prettier', stop_after_first = true },
          yaml = { 'prettierd', 'prettier', stop_after_first = true },
        },
      }
    end,
  },
  {
    'harpoon2',
    enabled = not vim.g.vscode,
    keys = {
      '<leader>a',
      '<C-e>',
      '<C-h>',
      '<C-j>',
      '<C-k>',
      '<C-l>',
      '<leader>p',
      '<leader>n',
    },
    after = function()
      local harpoon = require 'harpoon'
      harpoon.setup {}

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = 'harpoon: [a]dd file to list' })

      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'harpoon: show list' })

      vim.keymap.set('n', '<C-h>', function()
        harpoon:list():select(1)
      end, { desc = 'harpoon: Go to to 1st item' })

      vim.keymap.set('n', '<C-j>', function()
        harpoon:list():select(2)
      end, { desc = 'harpoon: Go to to 2nd item' })

      vim.keymap.set('n', '<C-k>', function()
        harpoon:list():select(3)
      end, { desc = 'harpoon: Go to to 3rd item' })

      vim.keymap.set('n', '<C-l>', function()
        harpoon:list():select(4)
      end, { desc = 'harpoon: Go to to 4th item' })

      vim.keymap.set('n', '<leader>p', function()
        harpoon:list():prev()
      end, { desc = 'harpoon: go to [p]rev file' })

      vim.keymap.set('n', '<leader>n', function()
        harpoon:list():next()
      end, { desc = 'harpoon: go to [n]ext file' })
    end,
  },
  {
    'yanky.nvim',
    enabled = not vim.g.vscode,
    keys = {
      { 'y', mode = { 'n', 'x' } },
      { 'Y', mode = { 'n', 'x' } },
      { 'p', mode = { 'n', 'x' } },
      { 'P', mode = { 'n', 'x' } },
      { 'gp', mode = { 'n', 'x' } },
      { 'gP', mode = { 'n', 'x' } },
      '<c-p>',
      '<c-n>',
    },
    after = function()
      require('yanky').setup {
        highlight = {
          timer = 100,
        },
      }
      vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)')
      vim.keymap.set({ 'n', 'x' }, 'gp', '<Plug>(YankyGPutAfter)')
      vim.keymap.set({ 'n', 'x' }, 'gP', '<Plug>(YankyGPutBefore)')

      vim.keymap.set('n', '<c-p>', '<Plug>(YankyPreviousEntry)')
      vim.keymap.set('n', '<c-n>', '<Plug>(YankyNextEntry)')
    end,
  },
  {
    'mini.completion',
    event = 'InsertEnter',
    enabled = not vim.g.vscode,
    after = function()
      require('mini.completion').setup()
    end,
  },
  {
    'mini.comment',
    key = { 'gc', mode = { 'n', 'x' } },
    after = function()
      require('mini.comment').setup {
        options = {
          custom_commentstring = function()
            return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring
          end,
        },
      }
    end,
  },
  {
    'zen-mode.nvim',
    cmd = 'ZenMode',
    keys = '<leader>z',
    after = function()
      require('zen-mode').setup {
        window = { backdrop = 0.7 },
        plugins = {},
      }
      vim.keymap.set('n', '<leader>z', '<cmd>ZenMode<cr>', { desc = 'Zen Mode' })
    end,
  },
  {
    'vim-startuptime',
    event = 'DeferredUIEnter',
    before = function()
      vim.g.startuptime_tries = 10
    end,
  },
}
