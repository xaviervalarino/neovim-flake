if vim.g.vscode then
  return {}
end

-- Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

return {
  {
    'nvim-lspconfig',
    -- event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    after = function()
      local lspconfig = require 'lspconfig'
      lspconfig.eslint.setup {
        settings = {
          format = false,
          workingDirectory = {
            mode = 'auto',
          },
        },
        root_dir = lspconfig.util.find_git_ancestor,
      }
      lspconfig.graphql.setup {}
      lspconfig.html.setup {}
      lspconfig.jsonls.setup {
        capabilities = capabilities,
      }
      lspconfig.cssls.setup {}
      -- lspconfig.cssmodules_ls.setup {
      --   -- on_attach = function(client)
      --   --     client.server_capabilities.definitionProvider = false
      --   -- end,
      -- }
      -- lspconfig.css_variables.setup {}
      lspconfig.somesass_ls.setup {}
      lspconfig.lua_ls.setup {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' },
              disable = { 'missing-fields' },
            },
          },
        },
      }
      lspconfig.nil_ls.setup {}
    end,
  },
  {
    'lazydev.nvim',
    ft = 'lua', -- only load on lua file
    after = function()
      require('lazydev').setup {}
    end,
  },
  {
    'twoslash-queries',
    ft = { 'typescript', 'typescriptreact' },
    after = function()
      require('twoslash-queries').setup { multi_line = true }
    end,
  },
  {
    'typescript-tools.nvim',
    ft = { 'typescript', 'typescriptreact' },
    after = function()
      require('typescript-tools').setup {
        handlers = {
          ['textDocument/publishDiagnostics'] = function(_, result, ctx, config)
            if result.diagnostics == nil then
              return
            end

            -- ignore some tsserver diagnostics
            local idx = 1
            while idx <= #result.diagnostics do
              local entry = result.diagnostics[idx]

              local formatter = require('format-ts-errors')[entry.code]
              entry.message = formatter and formatter(entry.message) or entry.message

              -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
              if entry.code == 80001 then
                -- { message = "File is a CommonJS module; it may be converted to an ES module.", }
                table.remove(result.diagnostics, idx)
              else
                idx = idx + 1
              end
            end

            vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
          end,
        },
        on_attach = function(client, bufnr)
          require('twoslash-queries').attach(client, bufnr)

          vim.keymap.set(
            'n',
            '<leader>im',
            ':TSToolsAddMissingImports<CR> :TSToolsOrganizeImports<CR>',
            { desc = 'TS: [u]pdate imports' }
          )
          vim.keymap.set('n', '<leader>fa', ':TSToolsFixAll<CR>', { desc = 'TS: [f]ix [a]ll' })
          vim.keymap.set('n', '<leader>rf', ':TSToolsRenameFile<CR>', { desc = 'TS: [r]ename [f]ile' })
        end,
      }
    end,
  },
}
