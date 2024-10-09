{
  description = "guilded flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in
    {
      packages.x86_64-linux.default = with pkgs;
        stdenv.mkDerivation rec {
          name = "guilded";
          version = "1.0.9284034";
          src = fetchurl {
            url = "https://www.guilded.gg/downloads/Guilded-Linux.deb";
            hash = "sha256-O17EV03JnOarHClQiCR9aEu7XUIoFTWvLVyLe3Q1jBo=";
          };
          nativeBuildInputs = [
            alsa-lib
            autoPatchelfHook
            libdrm
            wrapGAppsHook3
            makeShellWrapper
            xorg.libX11
            xorg.libXtst
            gtk3
            nss
            mesa
            dpkg
          ];
          libPath = lib.makeLibraryPath [
            libcxx
            systemd
            libpulseaudio
            libdrm
            mesa
            stdenv.cc.cc
            alsa-lib
            atk
            at-spi2-atk
            at-spi2-core
            cairo
            cups
            dbus
            expat
            fontconfig
            freetype
            gdk-pixbuf
            glib
            gtk3
            libglvnd
            libnotify
            xorg.libX11
            xorg.libXcomposite
            libunity
            libuuid
            xorg.libXcursor
            xorg.libXdamage
            xorg.libXext
            xorg.libXfixes
            xorg.libXi
            xorg.libXrandr
            xorg.libXrender
            xorg.libXtst
            nspr
            xorg.libxcb
            pango
            xorg.libXScrnSaver
            libappindicator-gtk3
            libdbusmenu
            wayland
          ];
          unpackPhase = ''
            mkdir pkgs
            dpkg-deb -x $src pkg
            sourceRoot=pkg
          '';

          dontWrapGApps = true;
          autoPatchelfIgnoreMissingDeps = true;

          installPhase = ''
            mkdir -p $out/{opt,bin}
            mv opt/Guilded $out/opt/
            mv usr/share $out
            chmod +x $out/opt/Guilded/guilded

            patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} $out/opt/Guilded/guilded

            wrapProgramShell $out/opt/Guilded/guilded \
              "''${gappsWrapperArgs[@]}" \
              --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations}}" \
              --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}/" \
              --prefix LD_LIBRARY_PATH : ${libPath}:$out/opt/Guilded \

            ln -s $out/opt/Guilded/guilded $out/bin/
            substituteInPlace $out/share/applications/guilded.desktop \
              --replace Exec=/opt/Guilded/guilded Exec=$out/bin/guilded
          '';
          meta = with lib; {
            description = "Guilded upgrades your group chat and equips your server with integrated event calendars, forums, and more - 100% free.";
            homepage = "https://www.guilded.gg";
            license = licenses.unfree;
            mainProgram = "guilded";
          };
        };
    };
}
