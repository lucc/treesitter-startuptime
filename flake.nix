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
          [((pkgs.vimPlugins.nvim-treesitter.withPlugins
          select).overrideAttrs(_:{src=treesitter;}))];
      };
      plugin-nixpkgs = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
      plugin-upstream = plugin-nixpkgs.overrideAttrs (oa: { src = treesitter; });
    in
    rec {
      none = nvim (p: []);
      some = nvim (p: [p.julia]);
      all = pkgs.neovim.override {
        configure.packages.treesitter-example.start = [plugin-upstream];
      };
      default = pkgs.writeShellScriptBin "compare" ''
        ${pkgs.hyperfine}/bin/hyperfine \
          -n plain "${pkgs.neovim}/bin/nvim --headless -cq" \
          -n none "${none}/bin/nvim --headless -cq" \
          -n some "${some}/bin/nvim --headless -cq" \
          -n all "${all}/bin/nvim --headless -cq"
      '';
      # to check if we pick up the upstream changes
      diff = pkgs.writeShellScriptBin "compare" ''
        ${pkgs.diffutils}/bin/diff -r ${plugin-nixpkgs} ${plugin-upstream}
      '';
    };
  };
}
