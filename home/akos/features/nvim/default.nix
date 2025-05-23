{ pkgs, config, lib, ... }:
{
  imports = [
    ./ui.nix
  ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;

    extraConfig = /* vim */ ''
      	filetype plugin indent on
      	syntax on
      	set number
      	set autoindent
      	set tabstop=4
      	set shiftwidth=4
      	set expandtab
      	set hlsearch
      	set mouse=a
      	set incsearch
      	set t_Co=256
      	let base16colorspace=256
      	set termguicolors
      	set noshowmode
      	set listchars=tab:→\ ,nbsp:+,space:·
        set timeoutlen=500
        set scrolloff=25

      	hi! link @variable Normal

      	set pastetoggle=<F2>
      	 
      	let mapleader = ","
      	 
      	" Quitting, saving
      	nnoremap <leader>w <cmd>w<cr>
      	nnoremap <leader>W <cmd>w !sudo tee % >/dev/null<cr>
      	 
      	nnoremap <leader>q <cmd>q<cr>
      	nnoremap <leader>Q <cmd>q!<cr>
      	 
      	nnoremap <leader>x <cmd>x<cr>

      	" Buffers
      	nnoremap <silent><leader>, <cmd>b#<cr>

      	" Tabs
      	nnoremap <leader>t <cmd>tabnew<cr>

      	" Clipboard
      	nnoremap <leader>y "+y
      	nnoremap <leader>Y "*y

      	nnoremap <leader>p "+p
      	nnoremap <leader>P "*p

      	" Splitting
      	nnoremap <leader>v <cmd>vsplit<cr>
      	nnoremap <leader>s <cmd>split<cr>

      	" Window navigation
      	nnoremap <M-Left> <C-W>h
      	nnoremap <M-Right> <C-W>l
      	nnoremap <M-Up> <C-W>k
      	nnoremap <M-Down> <C-W>j

      	nnoremap <M-Left> <C-W>h
      	nnoremap <M-Right> <C-W>l
      	nnoremap <M-Up> <C-W>k
      	nnoremap <M-Down> <C-W>j

      	nnoremap <leader><Left> <C-W>H
      	nnoremap <leader><Right> <C-W>L
      	nnoremap <leader><Up> <C-W>K
      	nnoremap <leader><Down> <C-W>J

      	nnoremap <S-Left> <C-W>>
      	nnoremap <S-Right> <C-W><
      	nnoremap <S-Up> <C-W>-
      	nnoremap <S-Down> <C-W>+
    '';

    extraLuaConfig = /* lua */ ''
      	-- Ranger
        vim.api.nvim_set_keymap('n', '<leader>r', ':RangerEdit<CR>', { noremap = true, silent = true })

      	-- Telescope
      	vim.api.nvim_set_keymap('n', '<leader>f', ':Telescope find_files<CR>', { noremap = true, silent = true })
      	vim.api.nvim_set_keymap('n', '<leader>g', ':Telescope live_grep<CR>', { noremap = true, silent = true })

      	-- Copilot
      	vim.g.copilot_no_tab_map = true
      	vim.g.copilot_assume_mapped = true
      	vim.g.copilot_tab_fallback = ""

      	vim.keymap.set('i', '<leader><tab>', 'copilot#Accept("<CR>")',
      	    { expr = true, noremap = true, silent = true, script = true, replace_keycodes = false })

        -- Quickfix window
        vim.api.nvim_set_keymap('n', '<leader><space>', ':lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true })

        -- Prettier
        vim.api.nvim_set_keymap('n', '<leader><CR>', ':Prettier<CR>', { noremap = true, silent = true })

        -- LSP
        vim.api.nvim_set_keymap('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', 'gr', '<cmd>Telescope lsp_references<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', 'gs', '<cmd>Telescope lsp_workspace_symbols<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<space>', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
        vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
        vim.diagnostic.config({ float = { border = 'rounded' } })
    '';

    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      ranger-vim
      copilot-vim
      editorconfig-nvim
    ];
  };

  xdg.configFile."nvim/init.lua".onChange = /* bash */ ''
    XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
    for server in $XDG_RUNTIME_DIR/nvim.*; do
      ${lib.getExe config.programs.neovim.package} --server $server --remote-send '<Esc>:source $MYVIMRC<CR>' &
    done
  '';

  home.packages = with pkgs; [
    ripgrep
  ];
}
