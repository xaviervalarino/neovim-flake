return {
  -- has to be a barrel file because lz.n doesn't read the symlinks from Nix
  require 'plugins.lsp',
  {
    'nvim-treesitter',
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
    after = function()
      local diff = require 'mini.diff'
      diff.setup {
        view = { style = 'sign' },
      }
      vim.keymap.set('n', 'dh', diff.toggle_overlay, { desc = 'Toggle [d]iff [h]unks' })
    end,
  },
  {
    'mini.ai',
    after = function()
      require('mini.ai').setup()
    end,
  },
  {
    'mini.git',
    enabled = not vim.g.vscode,
    after = function()
      require('mini.git').setup()
    end,
  },

  {
    'mini.animate',
    enabled = not vim.g.vscode,
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

  { 'mini.icons' },
  {
    'oil-nvim',
    opts = {},
    enabled = not vim.g.vscode,
    -- dependencies = { 'echasnovski/mini.icons' },
    before = function()
      require('mini.icons').setup {}
    end,
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
    after = function()
      require('mini.pairs').setup {}
    end,
  },
  {

    'mini.surround',
    after = function()
      require('mini.surround').setup {
        n_lines = 200,
      }
    end,
  },
  {
    'mini.indentscope',
    enabled = not vim.g.vscode,
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
    'rose-pine',
    colorscheme = { 'rose-pine', 'rose-pine-main', 'rose-pine-moon', 'rose-pine-dawn' },
    enabled = not vim.g.vscode,
    after = function()
      require('rose-pine').setup {}
      -- vim.cmd 'colorscheme rose-pine'
      -- vim.cmd 'colorscheme rose-pine-moon'
    end,
  },
  {
    'conform.nvim',
    enabled = not vim.g.vscode,
    event = { 'BufWritePre ' },
    cmd = { 'ConformInfo' },
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
    -- dependencies = { 'nvim-lua/plenary.nvim' },
    enabled = not vim.g.vscode,
    keys = {
      -- { '<leader>a', function()
      --   require('harpoon'):list():add()
      -- end, { desc = 'Harpoon: [a]dd file to list' }},
      {
        '<C-e>',
        function()
          require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())
        end,
        { desc = 'harpoon: show list' },
      },
      {
        '<C-h>',
        function()
          require('harpoon'):list():select(1)
        end,
        { desc = 'harpoon: Go to to 1st item' },
      },
      {
        '<C-j>',
        function()
          require('harpoon'):list():select(2)
        end,
        { desc = 'harpoon: Go to to 2nd item' },
      },
      {
        '<C-k>',
        function()
          require('harpoon'):list():select(3)
        end,
        { desc = 'harpoon: Go to to 3rd item' },
      },
      {
        '<C-l>',
        function()
          require('harpoon'):list():select(4)
        end,
        { desc = 'harpoon: Go to to 4th item' },
      },
      {
        '<leader>p',
        function()
          require('harpoon'):list():prev()
        end,
        { desc = 'harpoon: go to [p]rev file' },
      },
      {
        '<leader>n',
        function()
          require('harpoon'):list():next()
        end,
        { desc = 'harpoon: go to [n]ext file' },
      },
    },
    after = function()
      require('harpoon').setup {}
    end,
  },
  {
    'yanky.nvim',
    enabled = not vim.g.vscode,
    keys = {
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' } },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' } },
      { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' } },
      { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' } },

      { '<c-p>', '<Plug>(YankyPreviousEntry)' },
      { '<c-n>', '<Plug>(YankyNextEntry)' },
    },
    after = function()
      require('yanky').setup {
        highlight = {
          timer = 100,
        },
      }
    end,
  },
  {
    'mini.completion',
    enabled = not vim.g.vscode,
    after = function()
      require('mini.completion').setup()
    end,
  },
  {
    'nvim-ts-context-commentstring',
    -- enabled = not vim.g.vscode,
    after = function()
      require('ts_context_commentstring').setup {
        enable_autocmd = false,
      }
    end,
  },
  {
    'mini.comment',
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
  { 'twilight.nvim' },
  {
    'zen-mode.nvim',
    cmd = 'ZenMode',
    keys = { { '<leader>z', '<cmd>ZenMode<cr>', desc = 'Zen Mode' } },
    after = function()
      require('zen-mode').setup {
        window = { backdrop = 0.7 },
        plugins = {},
      }
    end,
  },
}
