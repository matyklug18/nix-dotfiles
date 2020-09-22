{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.nvimgen;
  convert-set = lib.generators.toKeyValue {
    mkKeyValue = key: value:
    let
      value' = toString value;
    in "${if isString value || isInt value then "set ${key}=${value'}" else (if isBool value then (if value == true then "set " + key else "") else "")}";
  };
  convert-let = lib.generators.toKeyValue {
    mkKeyValue = key: value:
    let
      value' = toString value;
    in "${if isString value then "let ${key}=\"${value'}\"" else (if isInt value then "let ${key}=${value}" else "")}";
  };
  colorPlugs = with pkgs.vimPlugins; {
    "gruvbox" = gruvbox;
    "NeoSolarized" = NeoSolarized;
  };
in {
  options.programs.nvimgen = {
    enable = mkEnableOption "init.vim generator";

    colorscheme = mkOption {
      type = types.str;
      default = "default";
    };

    preExtra = mkOption {
      type = types.str;
      default = "";
    };

    postExtra = mkOption {
      type = types.str;
      default = "";
    };

    others = mkOption {
      type = types.attrs;
      default = {};
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = [];
    };

    options = mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    
    programs.neovim.enable = true;

    programs.neovim.plugins = [(lib.attrsets.attrByPath [ cfg.colorscheme ] 0 colorPlugs)] ++ cfg.plugins;

    programs.neovim.extraConfig = "
      \" manual pre:
      ${cfg.preExtra}

      \" automatic:
      colorscheme ${cfg.colorscheme}

      \" automaic options:
      ${if (lib.attrsets.attrByPath [ "mouse" ] 0 cfg.options) == true then "set mouse=a\n" else ""}
      ${if (lib.attrsets.attrByPath [ "clipboardsync" ] 0 cfg.options) == true then "set clipboard=unnamedplus\n" else ""}

      \" automatic sets:
      ${convert-set cfg.others.sets}

      \" automatic lets:
      ${convert-let cfg.others.lets}
      
      \" manual post:
      ${cfg.postExtra}
    ";
  };
}

