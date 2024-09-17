require('laravel.config').setup {
  lsp_server = "phpactor",
  register_user_commands = true,
  features = {
    null_ls = {
      enable = true,
    },
    route_info = {
      enable = true,
      middlewares = true,
      method = true,
      uri = true,
      position = "right",
    },
  },
  ui = require "laravel.config.ui",
  commands_options = require "laravel.config.command_options",
  environments = require "laravel.config.environments",
  user_commands = require "laravel.config.user_commands",
  resources = require "laravel.config.resources",
}
