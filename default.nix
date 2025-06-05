{ stdenv, fetchurl, buildFHSUserEnv, makeWrapper }:

let
  factorio-unwrapped = stdenv.mkDerivation {
    name = "aces-factorio-headless-unwrapped";
    src = fetchurl {
      url = "https://factorio.com/get-download/stable/headless/linux64";
      sha256 = "ef12a54d1556ae1f84ff99edc23706d13b7ad41f1c02d74ca1dfadf9448fcbae";
    };
    unpackPhase = "tar -xJf $src";
    installPhase = ''
      mkdir -p $out/lib/factorio
      cp -r factorio/* $out/lib/factorio/
      chmod +x $out/lib/factorio/bin/x64/factorio
    '';
    meta = {
      description = "Factorio headless server (unwrapped)";
      license = "unfree";
    };
  };
in
buildFHSUserEnv {
  name = "factorio";
  
  targetPkgs = pkgs: with pkgs; [
    # Core libraries that Factorio needs
    stdenv.cc.cc.lib
    glibc
    zlib
    openssl
    curl
    libGL
    libpulseaudio
    alsa-lib
    
    # Additional libraries that might be needed
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libXinerama
    
    # Make the unwrapped factorio available
    factorio-unwrapped
  ];
  
  runScript = ''
    #!/bin/bash
    export FACTORIO_USERDATA_PATH=$HOME/.factorio
    mkdir -p $HOME/.factorio
    
    # Create config file if it doesn't exist
    if [ ! -f $HOME/.factorio/config.ini ]; then
      cat > $HOME/.factorio/config.ini << EOFC
[path]
read-data=${factorio-unwrapped}/lib/factorio/data
write-data=$HOME/.factorio
EOFC
    fi
    
    cd $HOME
    exec ${factorio-unwrapped}/lib/factorio/bin/x64/factorio --config $HOME/.factorio/config.ini "$@"
  '';
  
  meta = {
    description = "Factorio headless server";
    license = "unfree";
    platforms = [ "x86_64-linux" ];
  };
}