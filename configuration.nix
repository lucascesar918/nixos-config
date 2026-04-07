{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.nix-lab = {
    isNormalUser = true;
    description = "NixOS Lab";
    extraGroups = [ "networkmanager" "wheel" ];
    
    # BASE PACKAGES: Only everyday tools
    packages = with pkgs; [
      librewolf
      wget
      curl
      git
      gh
      neovim
      vim
      kitty
      btop
    ];
  };

  # ---------------------------------------------------------
  # SPECIALISATIONS (Boot Menu Profiles)
  # ---------------------------------------------------------
  specialisation = {
    # Option 1: Boot into Java Development
    java-dev.configuration = {
      system.nixos.tags = [ "java-dev" ];
      users.users.nix-lab.packages = with pkgs; [
        jetbrains.idea
        jdk21
        maven
      ];
    };

    # Option 2: Boot into C++ Development
    cpp-dev.configuration = {
      system.nixos.tags = [ "cpp-dev" ];
      users.users.nix-lab.packages = with pkgs; [
        jetbrains.clion
        libgcc
        cmake
        gnumake
      ];
    };
  };

  # ---------------------------------------------------------
  # AUTO-UPDATE FROM GITHUB ON BOOT
  # ---------------------------------------------------------
  systemd.services.update-nixos-config = {
    description = "Pull NixOS config from GitHub and rebuild on boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    path = with pkgs; [ git config.system.build.nixos-rebuild ];
    
    script = ''
      cd /etc/nixos 
      
      # Fetch from your public GitHub repo (assuming your default branch is 'main')
      git fetch https://github.com/lucascesar918/nixos-config.git main
      
      # Overwrite local changes with the remote branch
      git reset --hard FETCH_HEAD
      
      # Rebuild the system
      nixos-rebuild switch
    '';
    
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "25.11"; 
}
