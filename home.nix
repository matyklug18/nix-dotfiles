{ lib, config, pkgs, buildVimPlugin, ... }:
let 
  comma = import ( pkgs.fetchFromGitHub {
    owner = "fzakaria";
    repo = "comma";
    rev = "60a4cf8ec5c93104d3cfb9fc5a5bac8fb18cc8e4";
    sha256 = "16i4vkpbppqc7xv6w791awhj71blj42mj99mi2lx6949yn2xyavi";
  }) { };
  gitvim = url: 
    pkgs.vimUtils.buildVimPlugin {
      name = builtins.elemAt (lib.splitString "/" url) 1;
      src = builtins.fetchTarball {
        url = "https://github.com/" + url + "/archive/master.tar.gz";
      };
    };

  pkgsMaster = import ./repos/nixpkgs;

  masterOverlay = self: super: {
    master = super.callPackage pkgsMaster { config = super.config; };
  };

in {
  nixpkgs.overlays = [ masterOverlay ];

  imports = [
    ./modules/nvimgen.nix
    ./modules/zshgen.nix
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Breeze";
      package = pkgs.breeze-gtk;
    };
  };

  home = {
    file.".emacs.d/init.el".text = ''
      (require 'package)
      (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
      (package-initialize)
      (package-refresh-contents)

      (unless
        (package-installed-p 'use-package)
        (package-install 'use-package)
      )

      ;; projectile
      ;; Project-Thing (no idea tbh)
      (use-package
        projectile
      )

      ;; lsp-mode
      ;; Does LSP-Stuff, ig.
      (unless
        (package-installed-p 'lsp-mode)
        (package-install 'lsp-mode)
      )

      ;; polymode
      ;; Multiple Major Modes
      (unless
        (package-installed-p 'polymode)
        (package-install 'polymode)
      )

      ;; treemacs
      ;; a file tree
      (use-package
        treemacs
        :ensure t
        :defer t
        :init
      )
      (use-package
        treemacs-evil
        :after treemacs evil
        :ensure t
      )
      (use-package
        treemacs-projectile
        :after treemacs projectile
        :ensure t
      )

      ;; flycheck
      ;; Error Checking
      (use-package
        flycheck
        :ensure t
        :init (global-flycheck-mode)
      )

      ;; company
      ;; Auto Complete
      (unless
        (package-installed-p 'company)
        (package-install 'company)
      )

      ;; evil
      ;; Vim Emulation
      (use-package
        evil
      )

      (unless
        (package-installed-p 'lsp-treemacs)
        (package-install 'lsp-treemacs)
      )

      ;; Enable Evil
      (require 'evil)
      (evil-mode 1)

      ;; tabnew patch
      (evil-define-command evil-patch-tabnew (name)
        (interactive "<f>")
        (tab-bar-new-tab)
        (find-file name)
      )

      (evil-ex-define-cmd "tabnew" 'evil-patch-tabnew)

      (use-package gruvbox-theme
      :ensure t
      :config
      (load-theme 'gruvbox-dark-soft t))

      (tool-bar-mode -1)
      (custom-set-variables
       ;; custom-set-variables was added by Custom.
       ;; If you edit it by hand, you could mess it up, so be careful.
       ;; Your init file should contain only one such instance.
       ;; If there is more than one, they won't work right.
       '(package-selected-packages
         '(lsp-treemacs use-package treemacs-projectile treemacs-evil polymode lsp-mode gruvbox-theme flycheck company)))
      (custom-set-faces
       ;; custom-set-faces was added by Custom.
       ;; If you edit it by hand, you could mess it up, so be careful.
       ;; Your init file should contain only one such instance.
       ;; If there is more than one, they won't work right.
       )
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
      poppler_utils
      bc
      calibre
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
      kitty
      comma
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

  services.dunst = {
    enable = true;
  };

  programs = {

    home-manager.enable = true;

    kitty = {
      enable = true;
      font.name = "Hack Nerd Font";
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
        };
        lets = {
          "g:UltiSnipsJumpForwardTrigger" = "<tab>";
        };
      };
      plugins = with pkgs.vimPlugins; [
        gitgutter
        ultisnips
        polyglot
        nerdtree
      ];
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

  };

  xsession.windowManager.i3.config.terminal = "kitty";
}
