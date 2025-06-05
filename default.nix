{ stdenv, fetchurl, makeWrapper }:

stdenv.mkDerivation {
  name = "aces-factorio-headless";
  src = fetchurl {
    url = "https://factorio.com/get-download/stable/headless/linux64";
    sha256 = "ef12a54d1556ae1f84ff99edc23706d13b7ad41f1c02d74ca1dfadf9448fcbae";
  };
  buildInputs = [ makeWrapper ];
  unpackPhase = "tar -xJf $src";
  installPhase = ''
    mkdir -p $out/lib/factorio $out/bin
    cp -r factorio/* $out/lib/factorio/
    cat > $out/bin/factorio << EOF
  #!/bin/sh
  export FACTORIO_USERDATA_PATH=\$HOME/.factorio
  mkdir -p \$HOME/.factorio
  cd \$HOME
  # Create a config file that sets the data directory
  cat > \$HOME/.factorio/config.ini << EOFC
  [path]
  read-data=$out/lib/factorio/data
  write-data=\$HOME/.factorio
  EOFC
  exec $out/lib/factorio/bin/x64/factorio --config \$HOME/.factorio/config.ini "\$@"
  EOF
    chmod +x $out/bin/factorio
  '';
  meta = {
    description = "Factorio headless server";
    license = "unfree";
  };
}