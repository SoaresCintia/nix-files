{ config, pkgs, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  time.timeZone = "America/Montreal";

  nix.binaryCaches = [ http://cache.nixos.org http://hydra.nixos.org ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    gummiboot = {
      enable = true;
      timeout = 1;
    };
  };

  networking.hostName = "nenem";
  networking.wireless.enable = true;

  i18n = {
     consoleFont = "";
     consoleKeyMap = "us";
     defaultLocale = "en_US.UTF-8";
  };

  services.acpid.enable = true;
  services.acpid.lidEventCommands = ''
   LID_STATE=/proc/acpi/button/lid/LID0/state
   if [ $(/run/current-system/sw/bin/awk '{print $2}' $LID_STATE) = 'closed' ]; then
     systemctl suspend
   fi
  '';

  environment.systemPackages = with pkgs; [
    acpi
    ansible
    atom
    chromiumDev
    dmenu
    docker
    git
    #idea.idea-community
    mercurial
    mplayer
    nix
    nixops
    nodejs
    #oraclejdk8
    rxvt_unicode
    #sbt
    #scala_2_11
    sublime3
    tig
    tree
    unzip
    wpa_supplicant_gui
    xclip
  ];

  services.openssh.enable = true;
  programs.ssh.startAgent = true;
  services.printing.enable = true;
  programs.zsh.enable = true;
  # services.peerflix.enable = true;

  users.mutableUsers = true;
  users.extraUsers.cintia = {
    name = "cintia";
    group = "users";
    uid = 1000;
    extraGroups = [ "wheel" ];
    createHome = true;
    home = "/home/cintia";
    shell = "/run/current-system/sw/bin/zsh";
  };
  security.sudo.wheelNeedsPassword = false;
  users.extraGroups.docker.members = [ "cintia" ];

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
        defaultUser = "cintia";
      };
      sessionCommands = ''
        ${pkgs.xlibs.xrdb}/bin/xrdb -all ~/.Xresources
        ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr
        ${pkgs.xlibs.xset}/bin/xset r rate 200 50
        ${pkgs.xlibs.xinput}/bin/xinput set-prop 8 "Device Accel Constant Deceleration" 3
        ${pkgs.xlibs.xinput}/bin/xmodmap ~/.Xmodmap
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
    # oraclejdk8 = {
    #   installjce = true;
    # };
    # packageOverrides = pkgs : rec {
    #   jdk = pkgs.oraclejdk8;
    #   jre = pkgs.oraclejdk8.jre;
    # };
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
