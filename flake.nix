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
      nvim = select: pkgs.neovim.override {
        configure.packages.treesitter-example.start =
          [(pkgs.vimPlugins.nvim-treesitter.withPlugins select)];
      };
    in
    {
      none = nvim (p: []);
      some = nvim (p: [p.lua]);
      all = pkgs.neovim.override {
        configure.packages.treesitter-example.start =
          [pkgs.vimPlugins.nvim-treesitter.withAllGrammars];
      };
    };
  };
}
