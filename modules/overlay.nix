# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{inputs}: final: prev:
with final.pkgs.lib; let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin = src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-wrapNeovim = inputs.nixpkgs.legacyPackages.${pkgs.system};

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix { inherit pkgs-wrapNeovim; };

  # A plugin can either be a package or an attrset, such as
  # { plugin = <plugin>; # the package, e.g. pkgs.vimPlugins.nvim-cmp
  #   config = <config>; # String; a config that will be loaded with the plugin
  #   # Boolean; Whether to automatically load the plugin as a 'start' plugin,
  #   # or as an 'opt' plugin, that can be loaded with `:packadd!`
  #   optional = <true|false>; # Default: false
  #   ...
  # }
  all-plugins = with pkgs.vimPlugins; [
    {
      plugin = lz-n;
      optional = false;
    }
    {
      plugin = rose-pine;
      optional = false;
    }
    # mini-nvim
    nvim-treesitter.withAllGrammars
    nvim-lspconfig
    lazydev-nvim
    typescript-tools-nvim
    diffview-nvim 
    telescope-nvim 
    # telescope-fzy-native-nvim 
    nvim-treesitter-context 
    nvim-treesitter-textobjects 
    plenary-nvim
    nvim-ts-context-commentstring
    vim-repeat
    yanky-nvim
    conform-nvim
    oil-nvim
    zen-mode-nvim
    twilight-nvim
    harpoon2
   vim-startuptime

    # (mkNvimPlugin inputs.rose-pine "rose-pine")
    (mkNvimPlugin inputs.twoslash-queries "twoslash-queries")
    (mkNvimPlugin inputs.format-ts-errors "format-ts-errors")
    (mkNvimPlugin inputs.mini-ai "mini.ai")
    (mkNvimPlugin inputs.mini-animate "mini.animate")
    (mkNvimPlugin inputs.mini-clue "mini.clue")
    (mkNvimPlugin inputs.mini-comment "mini.comment")
    (mkNvimPlugin inputs.mini-completion "mini.completion")
    (mkNvimPlugin inputs.mini-diff "mini.diff")
    (mkNvimPlugin inputs.mini-git "mini.git")
    (mkNvimPlugin inputs.mini-icons "mini.icons")
    (mkNvimPlugin inputs.mini-indentscope "mini.indentscope")
    (mkNvimPlugin inputs.mini-pairs "mini.pairs")
    (mkNvimPlugin inputs.mini-surround "mini.surround")
  ];

  extraPackages = with pkgs; [
    # language servers, etc.
    lua-language-server
    nil # nix LSP
    prettierd
    stylua
    vscode-langservers-extracted
    nodePackages_latest.graphql-language-service-cli
  ];
in {
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
  };

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json {
    plugins = all-plugins;
  };

  # You can add as many derivations as you like.
  # Use `ignoreConfigRegexes` to filter out config
  # files you would not like to include.
  #
  # For example:
  #
  # nvim-pkg-no-telescope = mkNeovim {
  #   plugins = [];
  #   ignoreConfigRegexes = [
  #     "^plugin/telescope.lua"
  #     "^ftplugin/.*.lua"
  #   ];
  #   inherit extraPackages;
  # };
}
