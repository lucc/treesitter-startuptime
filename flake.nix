{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    treesitter.url = "github:nvim-treesitter/nvim-treesitter";
    treesitter.flake = false;
  };
  outputs = { self, nixpkgs, treesitter }: {
    packages.x86_64-linux =
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.overrideAttrs (oa: {
        src = treesitter;
      });
      nvim = select: pkgs.neovim.override {
        configure.packages.treesitter-example.start =
          [(nvim-treesitter.withPlugins select)];
      };
    in
    rec {
      none = nvim (p: []);
      some = nvim (p: [p.julia]);
      all = pkgs.neovim.override {
        configure.packages.treesitter-example.start =
          [nvim-treesitter.withAllGrammars];
      };
      default = pkgs.writeShellScriptBin "compare" ''
        ${pkgs.hyperfine}/bin/hyperfine \
          -n plain "${pkgs.neovim}/bin/nvim --headless -cq" \
          -n none "${none}/bin/nvim --headless -cq" \
          -n some "${some}/bin/nvim --headless -cq" \
          -n all "${all}/bin/nvim --headless -cq"
      '';
    };
  };
}
