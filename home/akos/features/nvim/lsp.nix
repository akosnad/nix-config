{ pkgs, ... }:
let
  bicep = pkgs.vscode-extensions.ms-azuretools.vscode-bicep;
in
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = neodev-nvim;
      type = "lua";
      config = /* lua */ ''
        require('neodev').setup()
      '';
    }
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = /* lua */ ''
                local lspconfig = require('lspconfig')
                local configs = require('lspconfig.configs')

                function add_lsp(server, options)
                  if not options["cmd"] then
                    options["cmd"] = server["document_config"]["default_config"]["cmd"]
                  end
                  if not options["capabilities"] then
                    options["capabilities"] = require("cmp_nvim_lsp").default_capabilities()
                  end

                  -- if vim.fn.executable(options["cmd"][1]) == 1 then
                  --   server.setup(options)
                  -- end
                  if server.setup then
                    server.setup(options)
                  end
                end

                add_lsp(lspconfig.dockerls, {})
                add_lsp(lspconfig.bashls, {})
                add_lsp(lspconfig.clangd, {})
                add_lsp(lspconfig.pylsp, {})
                add_lsp(lspconfig.lua_ls, {
                  settings = {
                    Lua = {
                      completion = {
                        callSnippet = "Replace",
                      }
                    }
                  }
                })
                add_lsp(lspconfig.ts_ls, {})
                add_lsp(lspconfig.nil_ls, {
                  settings = {
                    formatting = {
                      command = { "nixpkgs-fmt" },
                    }
                  }
                })
                add_lsp(lspconfig.vhdl_ls, {})
        if not configs.bicep then configs.bicep = {
                    default_config = {
                      cmd = { '${pkgs.dotnet-runtime_8}/bin/dotnet', '${bicep}/share/vscode/extensions/${bicep.vscodeExtUniqueId}/bicepLanguageServer/Bicep.LangServer.dll' },
                      filetypes = { 'bicep' },
                      root_dir = lspconfig.util.root_pattern('.bicepconfig.json', 'bicepconfig.json', 'main.bicep', '.git'),
                    }
                  }
                end
                add_lsp(lspconfig.bicep, {})
      '';
    }
    # LSP support for embedded code blocks

    {
      plugin = otter-nvim;
      type = "lua";
      config = /* lua */ ''
        local otter = require('otter')
        otter.setup({
          lsp = {
            hover = {
              border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            },
            diagnostic_update_events = { "BufWritePost" },
          },
          buffers = {
            set_filetype = false,
            write_to_disk = false,
          },
          strip_wrapping_quote_characters = { "'", '"', "`" },
          handle_leading_whitespace = false,
        })
      '';
    }
    rustaceanvim

    # snippets
    luasnip

    # completions
    cmp-nvim-lsp
    cmp_luasnip

    cmp-buffer
    cmp-path
    {
      plugin = cmp-git;
      type = "lua";
      config = /* lua */ ''
        require('cmp_git').setup({})
      '';
    }

    # completion pictograms
    lspkind-nvim
    {
      plugin = nvim-cmp;
      type = "lua";
      config = /* lua */ ''
        local cmp = require('cmp')
        local luasnip = require('luasnip')

        cmp.setup({
            formatting = {
              format = require('lspkind').cmp_format({
                before = function (entry, vim_item)
                  return vim_item
                end
              }),
            },
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end
            },
            sources = cmp.config.sources({
              { name = 'otter' },
              { name = 'nvim_lsp' },
            },
            {
              { name = 'luasnip' },
              { name = 'git' },
              { name = 'buffer', option = { get_bufnrs = vim.api.nvim_list_bufs }},
              { name = 'path' },
            }),
            mapping = cmp.mapping.preset.insert({
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.close(),
                ['<Tab>'] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.confirm({ select = true })
                  elseif luasnip.locally_jumpable(1) then
                    luasnip.jump(1)
                  else
                    fallback()
                  end
                end, { "i", "s" }),
            }),
        })
      '';
    }
  ];


  home.persistence."/persist".files = [ ".config/github-copilot/hosts.json" ];

  home.packages = with pkgs; [
    # LSP servers
    nodePackages.bash-language-server
    dockerfile-language-server
    python311Packages.python-lsp-server
    nodePackages.typescript-language-server
    lua-language-server
    rust-analyzer
    nil
    lua54Packages.jsregexp
    vhdl-ls
  ];
}
