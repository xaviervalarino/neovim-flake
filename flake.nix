{
  description = "Neovim derivation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";

    # Add bleeding-edge plugins here.
    # They can be updated with `nix flake update` (make sure to commit the generated flake.lock)
    lz-n.url = "github:nvim-neorocks/lz.n";
    lz-n.inputs.nixpkgs.follows = "nixpkgs";

    twoslash-queries.url = "github:marilari88/twoslash-queries.nvim";
    twoslash-queries.flake = false;

    format-ts-errors.url = "github:davidosomething/format-ts-errors.nvim";
    format-ts-errors.flake = false;

    mini-ai.url = "github:echasnovski/mini.ai";
    mini-ai.flake = false;
    
    mini-animate.url = "github:echasnovski/mini.animate";
    mini-animate.flake = false;
    
    mini-clue.url = "github:echasnovski/mini.clue";
    mini-clue.flake = false;
    
    mini-comment.url = "github:echasnovski/mini.comment";
    mini-comment.flake = false;
    
    mini-completion.url = "github:echasnovski/mini.completion";
    mini-completion.flake = false;
    
    mini-diff.url = "github:echasnovski/mini.diff";
    mini-diff.flake = false;
    
    mini-git.url = "github:echasnovski/mini-git";
    mini-git.flake = false;
    
    mini-icons.url = "github:echasnovski/mini.icons";
    mini-icons.flake = false;
    
    mini-indentscope.url = "github:echasnovski/mini.indentscope";
    mini-indentscope.flake = false;
    
    mini-pairs.url = "github:echasnovski/mini.pairs";
    mini-pairs.flake = false;
    
    mini-surround.url = "github:echasnovski/mini.surround";
    mini-surround.flake = false;
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    gen-luarc,
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    # This is where the Neovim derivation is built.
    neovim-overlay = import ./modules/overlay.nix {inherit inputs;};
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          # Import the overlay, so that the final Neovim derivation(s) can be accessed via pkgs.<nvim-pkg>
          neovim-overlay
          # This adds a function can be used to generate a .luarc.json
          # containing the Neovim API all plugins in the workspace directory.
          # The generated file can be symlinked in the devShell's shellHook.
          gen-luarc.overlays.default
        ];
      };
      shell = pkgs.mkShell {
        name = "nvim-devShell";
        buildInputs = with pkgs; [
          # Tools for Lua and Nix development, useful for editing files in this repo
          lua-language-server
          nil
          stylua
          luajitPackages.luacheck
        ];
        shellHook = ''
          # symlink the .luarc.json generated in the overlay
          ln -fs ${pkgs.nvim-luarc-json} .luarc.json
        '';
      };
    in {
      packages = rec {
        default = nvim;
        nvim = pkgs.nvim-pkg;
      };
      devShells = {
        default = shell;
      };
    })
    // {
      # You can add this overlay to your NixOS configuration
      overlays.default = neovim-overlay;
    };
}
