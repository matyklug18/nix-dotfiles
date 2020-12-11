{ lib, config, pkgs, buildVimPlugin, fetchzip, ... }:
let 
  gitvim = url: 
    pkgs.vimUtils.buildVimPlugin {
      name = builtins.elemAt (lib.splitString "/" url) 1;
      src = builtins.fetchTarball {
        url = "https://github.com/" + url + "/archive/master.tar.gz";
      };
    };

in {
  nixpkgs = {
    overlays = [
      (import ./packages)
    ];
    config = {
      permittedInsecurePackages = [
       "openssl-1.0.2u"
      ];
    };
  };

  imports = [
    ./modules/nvimgen.nix
    ./modules/zshgen.nix
    ./modules/awesomewmgen.nix
  ];

  fonts.fontconfig.enable = true;
  
  gtk = {
    enable = true;
    theme = {
      name = "Breeze";
      package = pkgs.breeze-gtk;
    };
  };

  home = {
   file.".config/rofi/config.rasi".text = ''
      configuration {
        location: 0;
        yoffset: 0;
        xoffset: 0;
        show-icons: true;
        modi: "drun";
        theme: "custom";
      }
    '';
    username = "matyk";
    homeDirectory = "/home/matyk";

    stateVersion = "20.09";
    sessionVariables = {
      TERMINAL = "kitty";
      EDITOR = "nvim";
      ZSH_AUTOSUGGEST_STRATEGY = [ "completion" "match_prev_cmd" "history" ];
    };
    packages = with pkgs.python38Packages; with pkgs; [
      #_pkg_
      #torbrowser
#     (st.override {
#       conf = builtins.readFile ./config/st-config.h;
#       patches = builtins.map builtins.fetchurl [
#         {url="https://st.suckless.org/patches/font2/st-font2-20190416-ba72400.diff";}
#       ];
#     })

      (st.overrideAttrs (oldAttrs: rec {
        src = pkgs.fetchFromGitHub {
          owner = "LukeSmithxyz";
          repo = "st";
          rev = "8ab3d03681479263a11b05f7f1b53157f61e8c3b";
          sha256 = "1brwnyi1hr56840cdx0qw2y19hpr0haw4la9n0rqdn0r2chl8vag";
        };
        buildInputs = oldAttrs.buildInputs ++ (with super; [ harfbuzz ]);
      }))
      fzf
      tree
      skypeforlinux
      docker
      joypixels
      jdk14
      noto-fonts-emoji
      xdotool
      rofi
      i3-gaps
      webtorrent_desktop
      pup
      krita
      feh
      nodejs
      fira-code
      awesome
      steam
      aria
      wine
      winetricks
      aseprite-unfree
      jetbrains.idea-community
      transmission
      #texlive.combined.scheme-context
      #texlive.combined.scheme-full
      calibre
      unzip
      zip
      pasystray
      skype
      screen
      cbatticon
      ripcord
      multimc
      poppler_utils
      bc
      okular
      qbittorrent
      expect
      github-cli
      networkmanagerapplet
      multimc
      appimage-run
      vlc
      youtube-dl
      pavucontrol
      htop
      emacs
      jq
      wget
      gcc
      cmake
      gnumake
      youtube-dl
      cowsay
      figlet
      lolcat
      gimp
      libnotify
      dconf
      audit
      inotify-tools
      lsof
      arandr
      xorg.xev
      neofetch
      hexyl
      binwalk
      file
      blender
      flameshot
      firefox
      discord
      lightcord
      goosemod-discord
      kitty
      nix-index
      topgrade
      git
      exa
      bat
      breeze-gtk
      python3
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.joypixels.acceptLicense = true;

  services = {
    dunst = {
      enable = true;
    };
    picom = {
      enable = false;
      package = pkgs.picom.overrideAttrs (old: {
        src = builtins.fetchTarball {
          url = "https://github.com/ibhagwan/picom/archive/next.tar.gz";
        };
      });
      shadow = true;
      blur = true;
      experimentalBackends = true;
      extraOptions = ''
        blur-method = "dual_kawase";
        blur-strength = 10;
        corner-radius = 15;
        detect-client-opacity = true;
        rounded-corners-exclude = [
          "class_g != 'kitty'",
          "FULL@:8s = 'true'"
        ];
      '';
      blurExclude = [
        "window_type *= 'menu'"
        "window_type *= 'dropdown_menu'"
        "window_type *= 'popup_menu'"
        "window_type *= 'utility'"
        "class_g = 'i3-frame'"
        "class_g = 'kitty' && !focused"
      ];
      opacityRule = [
        "90:class_g != 'kitty' && !focused"
      ];
      shadowExclude = [
        "window_type *= 'menu'"
        "window_type *= 'dropdown_menu'"
        "window_type *= 'popup_menu'"
        "window_type *= 'utility'"
        "class_g = 'i3-frame'"
        "class_g = 'Rofi'"
        "class_g = 'kitty'"
      ];
    };
    polybar = {
      package = pkgs.polybar.override {
        i3GapsSupport = true;
        alsaSupport = true;
      };
      enable = true;
      config = {
        "bar/bot" = {
          background = "#00000000";
          separator = " ";
          modules-left = "separator i3";
          modules-right = "date battery separator";
          bottom = true;
          font-0 = "Hack Nerd Font Mono:size=20;+5"; # i3
          font-1 = "Hack Nerd Font Mono:size=34;+8"; # battery
          font-2 = "Hack Nerd Font Mono:size=10;+3"; # time
          font-3 = "Hack Nerd Font Mono:size=1;+0";  # separator
          font-4 = "Hack Nerd Font Mono:size=15;+2"; # dash
          height = 35;
        };
        "module/i3" = {
          type = "internal/i3";
          ws-icon-0 = "1;";
          ws-icon-1 = "2;";
          ws-icon-2 = ''3;ﭮ'';
          ws-icon-3 = "4;";

          label-focused = "%icon%";
          label-focused-foreground="#405c8d";

          label-unfocused = "%icon%";

          label-separator = " ";

          label-urgent = "%icon%";
          label-urgent-foreground = "#bd2c40";
        };
        "module/battery" = {
          type = "internal/battery";
          battery = "BAT0";
          adapter = "ADP0";
          full-at = 95;
          format-charging = "<animation-charging>";
          format-charging-font = 2;
          format-discharging = "<ramp-capacity>";
          format-discharging-font = 2;
          label-full = "";
          format-full-font = 2;
          ramp-capacity-0 = "";
          ramp-capacity-1 = "";
          ramp-capacity-2 = "";
          ramp-capacity-3 = "";
          ramp-capacity-4 = "";
          animation-charging-0 = "";
          animation-charging-1 = "";
          animation-charging-2 = "";
          animation-charging-3 = "";
          animation-charging-4 = "";
          animation-charging-framerate = 750;
        };
        "module/date" = {
          type = "internal/date";
          date = "%d.%m.%Y";
          time = "%H:%M:%S";
          format-font = 3;
          label = "%time% %date% ";
        };
        "module/separator" = {
          type = "custom/text";
          content = " ";
          content-font = 4;
        };
        "module/dash" = {
          type = "custom/text";
          content = "|";
          content-font = 5;
        };
      };
      script = ''
        polybar bot -r &
      '';
    };
  };

  programs = {

    home-manager.enable = true;

    kitty = {
      enable = true;
      font.name = "Hack Nerd Font";
      settings = {
        background_opacity = "0.1";
      };
    };
    nvimgen = {
      enable = true;
      colorscheme = "gruvbox";
      options = {
        clipboardsync = true;
        mouse = true;
      };
      others = {
        sets = {
          tabstop = 2;
          shiftwidth = 2;
          number = true;
          cursorline = true;
          wildmenu = true;
          lazyredraw = true;
          showmatch = true;
          incsearch = true;
          hlsearch = true;
          termguicolors = true;
          noexpandtab = true;
        };
        lets = {
          "g:UltiSnipsJumpForwardTrigger" = "<tab>";
        };
      };
      plugins = with pkgs.vimPlugins; [
        gitgutter
        ultisnips
        nerdtree
        surround
        fzf-vim
      ];
      postExtra = ''
        fu! TexCompile()
          :AsyncRun context % && okular %:r.pdf
        endf
        command! TexCompile call TexCompile()
      '';
    };

    zshgen = {
      enable = true;
      plugins = [
        "zsh-users/zsh-completions"
        "zdharma/fast-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "MichaelAquilina/zsh-auto-notify"
      ];
      p10k = {
        enable = true;
      };
      shellAliases = {
        cat   = "bat";
        ls    = "exa --icons";
        clear = "printf '\\033[2J\\033[3J\\033[1;1H'; kitty +kitten icat --clear";
        ff    = "firefox";
      };
    };

    awesomewmgen = {
      #enable = true;
    };
  };

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    extraConfig = ''
    '';
    config = {
      modifier = "Mod4";
      terminal = "kitty";
      window = {
        titlebar = false;
        border = 0;
      };
      bars = [];
      gaps = {
        #smartBorders = "on";
        #smartGaps = true;

        #inner = 25;
        #outer = 25;
      };
    };
  };
}
