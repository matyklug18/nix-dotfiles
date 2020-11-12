{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.awesomewmgen;
in {
  options.programs.awesomewmgen = {
    enable = mkEnableOption "rc.lua generator";

    error = {
        messageStartup = mkOption {
        type = types.str;
        default = "Oops, there were errors during startup!"; 
      };

      messageRuntime = mkOption {
        type = types.str;
        default = "Oops, an error happened!"; 
      };
    };

    themes = {
      localTheme = mkOption {
        type = types.str;
        default = "default/theme.lua";
      };
    };

    settings = {
      terminal = mkOption {
        type = types.str;
        default = "kitty";
      };
      editor = mkOption {
        type = types.str;
        default = "nvim";
      };
      modkey = mkOption {
        type = types.str;
        default = "Mod4";
      };
    };

    layout = {
      list = mkOption {
        type = types.listOf types.str;
        default = [ "floating" "tile" "tile.left" "tile.bottom" "tile.top" "fair"
        "fair.horizontal" "spiral" "spiral.dwindle" "max" "max.fullscreen"
        "magnifier" "corner.nw" ];
      };
    };
  };

  config = mkIf cfg.enable {
    
    xsession.windowManager.awesome.enable = true;

    home.file.".config/awesome/rc.lua".text = ''
      #<lua>
      local gears = require("gears")
      local awful = require("awful")
      require("awful.autofocus")
      local wibox = require("wibox")
      local beautiful = require("beautiful")
      local naughty = require("naughty")
      local menubar = require("menubar")
      local hotkeys_popup = require("awful.hotkeys_popup")
      require("awful.hotkeys_popup.keys")

      if awesome.startup_errors then
        naughty.notify({
          preset = naughty.config.presets.critical,
          title = "${cfg.error.messageStartup}",
          text = awesome.startup_errors
        })
      end

      do
        local in_error = false
        awesome.connect_signal("debug::error", function (err)
          if in_error then return end
          in_error = true

          naughty.notify({ 
            preset = naughty.config.presets.critical,
            title = "${cfg.error.messageRuntime}",
            text = tostring(err) 
          })
          in_error = false
        end)
      end

      beautiful.init(gears.filesystem.get_themes_dir() .. "${cfg.themes.localTheme}")

      terminal = "${cfg.settings.terminal}"
      editor = "${cfg.settings.editor}" 
      editor_cmd = terminal .. " -e " .. editor

      modkey = "${cfg.settings.modkey}"

      awful.layout.layouts = {
      ${builtins.concatStringsSep ",\n" (lib.lists.forEach cfg.layout.list (l: "awful.layout.suit.${l}"))}
      }
      #<lua/>
    '';
  };
}

