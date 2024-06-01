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
        local lualine = require('lualine')
        lualine.setup({
          options = {
            section_separators = {'', ''},
            component_separators = {'', ''},
          },
          sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch'},
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
