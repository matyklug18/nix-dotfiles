{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

    networking = {
      hostName = "matyk"; # Define your hostname.

    useDHCP = false;
    interfaces.enp3s0f0.useDHCP = true;

    networkmanager.enable = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "cz";
  };

  time.timeZone = "Europe/Prague";

  nixpkgs.config.allowUnfree = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "matyk" ];

  sound.enable = true;
  hardware = {
    pulseaudio.enable = true;
    opengl = {
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };
    pulseaudio.support32Bit = true;
  };


  services.xserver = {
    enable = true;
    layout = "cz";

    displayManager.lightdm.enable = true;
    windowManager.i3 = { 
      enable = true;
      package = pkgs.i3-gaps;
    };

    synaptics.enable = true;
  };


  users.users.matyk = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  system.stateVersion = "20.03";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    tmpOnTmpfs = true;
    loader = {
      efi = {
        efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = true;
      };
      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        efiSupport = true;
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    promptInit = "";
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" "Meslo" "JetBrainsMono" ]; })
  ];
}

