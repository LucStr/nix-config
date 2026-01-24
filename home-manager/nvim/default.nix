{ config, pkgs, lib, inputs, ... }:

{
  home.packages = with pkgs; [
    tmux
  ];

  programs.neovim = 
  let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";

    fromGitHub = rev: ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = ref;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        ref = ref;
        rev = rev;
     };
  };
  in
  {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = ''
      set number relativenumber
      let mapleader=";"
    '';

    extraPackages = with pkgs; [
      lua-language-server
      wl-clipboard
      tmux
      rust-analyzer
      pyright
      nil
      roslyn-ls
      ripgrep
      phpactor
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
      copilot-vim
      plenary-nvim
      {
        plugin = renamer-nvim;
        config = toLua "require(\"renamer\").setup {}";
      }
      {
        plugin = (fromGitHub "e284f0e6c34b01cd1db9fdb71c75ae85d732a43b" "main" "seblj/roslyn.nvim");
      }
      actions-preview-nvim
      {
        plugin = harpoon2;
        config = toLuaFile ./plugins/harpoon.lua;
      }

      # Start Laravel stuff
      nui-nvim
      vim-dotenv
      none-ls-nvim
      # End Laravel stuff

      # GitHub integration
      {
        plugin = octo-nvim;
        config = toLua "require('octo').setup()";
      }
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./keybinds/default.lua}
    '';
  };
}
