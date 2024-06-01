{ pkgs, ... }:
let
  debugpy = pkgs.python311.withPackages (ps: [ ps.debugpy ]);
  codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb.overrideAttrs (final: prev: {
    lldb = pkgs.lldb_16;
  });

  vimspector_gadgets = {
    adapters = {
      CodeLLDB = {
        command = [
          "${codelldb}/share/vscode/extensions/${codelldb.vscodeExtPublisher}.${codelldb.vscodeExtName}/adapter/codelldb"
          "--port"
          "\${unusedLocalPort}"
        ];
        configuration = {
          args = [ ];
          cargo = { };
          cwd = "\${workspaceRoot}";
          env = { };
          name = "lldb";
          terminal = "integrated";
          type = "lldb";
        };
        name = "CodeLLDB";
        port = "\${unusedLocalPort}";
        type = "CodeLLDB";
      };

      debugpy = {
        command = [
          "${debugpy}/bin/python3"
          "${debugpy}/lib/python3.11/site-packages/debugpy/adapter"
        ];
        configuration = {
          python = "${debugpy}/bin/python3";
        };
        custom_handler = "vimspector.custom.python.Debugpy";
        name = "debugpy";
      };
    };
  };
in
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = vimspector;
      type = "lua";
      config = /* lua */ ''
        vim.g.vimspector_enable_mappings = 'HUMAN';
      '';
    }
  ];

  home.file.".config/vimspector/gadgets/linux/.gadgets.json".source = pkgs.writeText ".gadgets.json" (builtins.toJSON vimspector_gadgets);
}
