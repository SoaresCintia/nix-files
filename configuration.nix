{ config, pkgs, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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
     consoleFont = "lat9w-16";
     consoleKeyMap = "us";
     defaultLocale = "en_US.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    acpi
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

  services.openssh.enable = true;
  services.printing.enable = true;

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

  programs.ssh.startAgent = true;
  programs.zsh.enable = true;
  programs.zsh.interactiveShellInit =
  ''
    # Taken from <nixos/modules/programs/bash/command-not-found.nix>
    # and adapted to zsh (i.e. changed name from 'handle' to
    # 'handler').
    # This function is called whenever a command is not found.
    command_not_found_handler() {
      local p=/run/current-system/sw/bin/command-not-found
      if [ -x $p -a -f /nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite ]; then
        # Run the helper program.
        $p "$1"
        # Retry the command if we just installed it.
        if [ $? = 126 ]; then
          "$@"
        else
          return 127
        fi
      else
        echo "$1: command not found" >&2
        return 127
      fi
    }
  '';

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
