{ config, pkgs, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <nixos/modules/programs/command-not-found/command-not-found.nix>
    ];

  time.timeZone = "America/Montreal";

  nix.binaryCaches = [ http://cache.nixos.org http://hydra.nixos.org ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking.hostName = "bob";
  networking.wireless.enable = true;

  i18n = {
     consoleFont = "";
     consoleKeyMap = "us";
     defaultLocale = "en_US.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    ansible
    atom
    chromium
    dmenu
    docker
    git
    idea.idea-community
    mplayer
    nix
    nixops
    nodejs
    oraclejdk8
    popcorntime
    rxvt_unicode
    sbt
    scala_2_11
    sublime3
    tig
    tree
    unzip
    wpa_supplicant_gui
    xclip
  ];

  # services.openssh.enable = true;
  # programs.ssh.startAgent = true;
  # programs.zsh.enable = true;

  # services.printing.enable = true;

  users.mutableUsers = true;
  users.extraUsers.gui = {
    name = "gui";
    group = "users";
    uid = 1000;
    extraGroups = [ "wheel" ];
    createHome = true;
    home = "/home/gui";
    shell = "/run/current-system/sw/bin/zsh";
  };
  security.sudo.wheelNeedsPassword = false;
  users.extraGroups.docker.members = [ "gui" ];

  services.peerflix.enable = true;
  services.deluge.enable = true;

  services.xserver = {
    enable = true;
    layout = "en";

    synaptics = {
      enable = true;
      palmDetect = true;
      tapButtons = true;
      twoFingerScroll = true;
    };

    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    windowManager.default = "xmonad";
    desktopManager.xterm.enable = false;
    desktopManager.default = "none";
    displayManager = {
      slim = {
        autoLogin = true;
        enable = true;
        defaultUser = "gui";
      };
      sessionCommands = ''
        ${pkgs.xlibs.xrdb}/bin/xrdb -all ~/.Xresources
        ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr
        ${pkgs.xlibs.xset}/bin/xset r rate 200 50
        ${pkgs.xlibs.xinput}/bin/xinput set-prop 8 "Device Accel Constant Deceleration" 3
        ${pkgs.redshift}/bin/redshift &
        ${pkgs.compton}/bin/compton -r 4 -o 0.75 -l -6 -t -6 -c -G -b
        ${pkgs.hsetroot}/bin/hsetroot -solid '#000000'
      '';
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
    oraclejdk8 = {
      installjce = true;
    };
    packageOverrides = pkgs : rec {
      jdk = pkgs.oraclejdk8;
      jre = pkgs.oraclejdk8.jre;
    };
  };

  services.upower.enable = true;
  services.nixosManual.showManual = false;

  virtualisation.docker.enable = true;

  fonts = {
    enableGhostscriptFonts = true;
    fontconfig.enable = true;
    enableCoreFonts = true;
    fonts = with pkgs; [
      clearlyU
      cm_unicode
      dejavu_fonts
      dosemu_fonts
      freefont_ttf
      proggyfonts
      terminus_font
      ttf_bitstream_vera
      ubuntu_font_family
      unifont
      vistafonts
      powerline-fonts
    ];
  };
}
