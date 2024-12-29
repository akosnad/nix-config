{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    vim-illuminate

    vim-transparent

    {
      plugin = vim-fugitive;
      type = "viml";
      config = /* vim */ ''
        nmap <leader>g :Git<CR>
      '';
    }
    {
      plugin = gitsigns-nvim;
      type = "lua";
      config = /* lua */ ''
        require('gitsigns').setup({
            on_attach = function(bufnr)
              local gitsigns = require('gitsigns')

              local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
              end

              -- Navigation
              map('n', ']c', function()
                if vim.wo.diff then
                  vim.cmd.normal({']c', bang = true})
                else
                  gitsigns.nav_hunk('next')
                end
              end)

              map('n', '[c', function()
                if vim.wo.diff then
                  vim.cmd.normal({'[c', bang = true})
                else
                  gitsigns.nav_hunk('prev')
                end
              end)

              -- Actions
              map('n', '<leader>hs', gitsigns.stage_hunk)
              map('n', '<leader>hr', gitsigns.reset_hunk)
              map('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
              map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
              map('n', '<leader>hS', gitsigns.stage_buffer)
              map('n', '<leader>hu', gitsigns.undo_stage_hunk)
              map('n', '<leader>hR', gitsigns.reset_buffer)
              map('n', '<leader>hp', gitsigns.preview_hunk)
              map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end)
              map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
              map('n', '<leader>hd', gitsigns.diffthis)
              map('n', '<leader>hD', function() gitsigns.diffthis('~') end)
              map('n', '<leader>td', gitsigns.toggle_deleted)

              -- Text object
              map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
            end
        })
      '';
    }
    {
      plugin = nvim-bqf;
      type = "lua";
      config = /* lua */ ''
        require('bqf').setup{}
      '';
    }

    lualine-lsp-progress
    {
      plugin = lualine-nvim;
      type = "lua";
      config = /* lua */ ''
        local function diff_source()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed
            }
          end
        end

        local lualine = require('lualine')
        lualine.setup({
          options = {
            section_separators   = { left = '', right = '' },
            component_separators = { },
          },
          sections = {
            lualine_a = {'mode'},
            lualine_b = { { 'FugitiveHead', icon = '' }, { 'diff', source = diff_soure } },
            lualine_c = {'filename', 'lsp_progress'},
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'}
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'location'},
            lualine_y = {},
            lualine_z = {}
          },
          tabline = {},
        })
      '';
    }
  ];
}
