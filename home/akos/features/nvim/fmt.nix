{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = null-ls-nvim;
      type = "lua";
      config = /* lua */ ''
      local null_ls = require("null-ls")

      local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
      local event = "BufWritePre" -- or "BufWritePost"
      local async = event == "BufWritePost"

      null_ls.setup({
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            -- format on save
            vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
            vim.api.nvim_create_autocmd(event, {
              buffer = bufnr,
              group = group,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr, async = async })
              end,
              desc = "[lsp] format on save",
            })
          end
        end,
      })
      '';
    }

    {
      plugin = prettier-nvim;
      type = "lua";
      config = /* lua */ ''
        local prettier = require('prettier')

        prettier.setup({
          bin = 'prettierd',
          filetypes = {
            "css",
            "graphql",
            "html",
            "javascript",
            "javascriptreact",
            "json",
            "less",
            "markdown",
            "scss",
            "typescript",
            "typescriptreact",
            "yaml",
          },
          cli_options = {
            trailing_comma = 'es5',
            semi = false,
            single_quote = true,
            end_of_line = 'lf',
            arrow_parens = 'avoid',
            quote_props = 'as-needed',
            jsx_single_quote = true,
            bracket_spacing = true,
            bracket_same_line = false,
            embedded_language_formatting = 'auto',
          },
        })
      '';
    }
  ];

  home.packages = with pkgs; [
    prettierd
  ];
}
