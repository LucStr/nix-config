{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    tmux
  ];

  programs.neovim = 
  let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in
  {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = ''
      set number relativenumber
    '';

    extraPackages = with pkgs; [
      lua-language-server
      wl-clipboard
      tmux
      rust-analyzer
      pyright
    ];

    plugins = with pkgs.vimPlugins; [
      {
        plugin = everforest;
        config = ''
            let g:everforest_background = 'hard'
            colorscheme everforest
        '';
      }
      vim-sleuth
      {
        plugin = gitsigns-nvim;
        config = toLuaFile ./plugins/gitsigns.lua;
      }
      {
        plugin = nvim-treesitter.withAllGrammars;
        config = toLuaFile ./plugins/treesitter.lua;
      }
      {
        plugin = mini-nvim;
        config = toLuaFile ./plugins/mini.lua;
      }
      {
        plugin = todo-comments-nvim;
        config = toLua "require(\"todo-comments\").setup()";
      }
      {
        plugin = telescope-nvim;
        config = toLuaFile ./plugins/telescope.lua;
      }
      telescope-fzf-native-nvim
      {
        plugin = nvim-autopairs;
        config = toLua "require(\"nvim-autopairs\").setup()";
      }
      vim-tmux-navigator
      vimux
      {
        plugin = typescript-tools-nvim;
        config = toLua "require(\"typescript-tools\").setup {}";
      }
      {
        plugin = nvim-lspconfig;
        config = toLuaFile ./plugins/lsp.lua;
      }
      {
        plugin = oil-nvim;
        config = toLuaFile ./plugins/oil.lua;
      }
      luasnip
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      {
        plugin = nvim-cmp;
        config = toLuaFile ./plugins/cmp.lua;
      }
      plenary-nvim
      {
        plugin = renamer-nvim;
        config = toLua "require(\"renamer\").setup {}";
      }
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./keybinds/default.lua}
    '';
  };
}
