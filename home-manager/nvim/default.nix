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

    csharpier-server-format = pkgs.writeShellScriptBin "csharpier-server-format" ''
      # CSharpier server formatter - keeps .NET runtime warm
      PIDFILE="/tmp/csharpier-server.pid"
      PORTFILE="/tmp/csharpier-server.port"

      start_server() {
          if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
              return 0
          fi
          PORT=$((17000 + RANDOM % 1000))
          ${pkgs.csharpier}/bin/csharpier server --server-port "$PORT" &>/dev/null &
          echo $! > "$PIDFILE"
          echo "$PORT" > "$PORTFILE"
          sleep 0.5
      }

      get_port() {
          start_server
          cat "$PORTFILE"
      }

      FILENAME="$1"
      CONTENT=$(cat)
      PORT=$(get_port)

      RESPONSE=$(${pkgs.curl}/bin/curl -s -X POST "http://localhost:$PORT/format" \
          -H "Content-Type: application/json" \
          -d "$(${pkgs.jq}/bin/jq -n --arg fn "$FILENAME" --arg fc "$CONTENT" '{fileName: $fn, fileContents: $fc}')")

      STATUS=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r '.status')

      if [ "$STATUS" = "Formatted" ]; then
          echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r '.formattedFile'
      else
          echo "$CONTENT"
          echo "CSharpier error: $(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r '.errorMessage')" >&2
      fi
    '';
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
      csharpier
      csharpier-server-format
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
      smart-splits-nvim
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
      roslyn-nvim
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

      # Better quickfix with folding per file
      {
        plugin = nvim-bqf;
        config = toLua "require('bqf').setup()";
      }

      # Formatter with CSharpier server support
      {
        plugin = conform-nvim;
        config = toLuaFile ./plugins/conform.lua;
      }

      # Tree view for quickfix, diagnostics, references
      {
        plugin = trouble-nvim;
        config = toLua ''
          require('trouble').setup({
            auto_preview = false,  -- Don't auto-preview on cursor move
            follow = false,        -- Don't follow/jump when navigating
            focus = true,          -- Focus trouble window when opened
            keys = {
              ["o"] = function(self)
                local node = self:at()
                if node and node.item and node.item.pos then
                  local item = node.item
                  vim.cmd("wincmd p")
                  vim.cmd("edit " .. vim.fn.fnameescape(item.filename))
                  vim.api.nvim_win_set_cursor(0, {item.pos[1], item.pos[2] - 1})
                else
                  self:fold()
                end
              end,
              ["<cr>"] = function(self)
                local node = self:at()
                if node and node.item and node.item.pos then
                  local item = node.item
                  vim.cmd("wincmd p")
                  vim.cmd("edit " .. vim.fn.fnameescape(item.filename))
                  vim.api.nvim_win_set_cursor(0, {item.pos[1], item.pos[2] - 1})
                  require("trouble").close()
                else
                  self:fold()
                end
              end,
            },
            modes = {
              qflist = {
                groups = {
                  { "directory", format = "{directory_icon} {directory} {count}" },
                  { "filename", format = "{file_icon} {basename} {count}" },
                },
              },
            },
          })

          -- Start with all folds collapsed when trouble window opens (only once)
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "trouble",
            callback = function()
              vim.schedule(function()
                local bufnr = vim.api.nvim_get_current_buf()
                if not vim.b[bufnr].trouble_initial_fold_done then
                  vim.b[bufnr].trouble_initial_fold_done = true
                  require("trouble").fold_close_all()
                end
              end)
            end,
          })
        '';
      }
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./keybinds/default.lua}
      ${builtins.readFile ./plugins/smart-splits.lua}
    '';
  };
}
