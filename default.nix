# default.nix
{ stdenv, fetchurl, makeWrapper, writeText
, serverName ? "My Factorio Server"
, description ? "A Factorio server"
, tags ? []
, maxPlayers ? 0
, visibility ? { public = false; lan = true; }
, username ? ""
, password ? ""
, token ? ""
, gamePassword ? ""
, requireUserVerification ? true
, maxUploadInKilobytesPerSecond ? 0
, maxUploadSlots ? 5
, minimumLatencyInTicks ? 0
, maxHeartbeatsPerSecond ? 60
, ignorePlayerLimitForReturningPlayers ? false
, allowCommands ? "admins-only"
, autosaveInterval ? 10
, autosaveSlots ? 5
, afkAutokickInterval ? 0
, autoPause ? true
, autoPauseWhenPlayersConnect ? false
, onlyAdminsCanPauseTheGame ? false
, autosaveOnlyOnServer ? true
, nonBlockingSaving ? false
, minimumSegmentSize ? 25
, minimumSegmentSizePeerCount ? 20
, maximumSegmentSize ? 100
, maximumSegmentSizePeerCount ? 10
, admins ? []
, serverSettings ? {}
}:

let
  # Default server settings matching the example format
  defaultServerSettings = {
    name = serverName;
    description = description;
    tags = tags;
    max_players = maxPlayers;
    visibility = visibility;
    username = username;
    password = password;
    token = token;
    game_password = gamePassword;
    require_user_verification = requireUserVerification;
    max_upload_in_kilobytes_per_second = maxUploadInKilobytesPerSecond;
    max_upload_slots = maxUploadSlots;
    minimum_latency_in_ticks = minimumLatencyInTicks;
    max_heartbeats_per_second = maxHeartbeatsPerSecond;
    ignore_player_limit_for_returning_players = ignorePlayerLimitForReturningPlayers;
    allow_commands = allowCommands;
    autosave_interval = autosaveInterval;
    autosave_slots = autosaveSlots;
    afk_autokick_interval = afkAutokickInterval;
    auto_pause = autoPause;
    auto_pause_when_players_connect = autoPauseWhenPlayersConnect;
    only_admins_can_pause_the_game = onlyAdminsCanPauseTheGame;
    autosave_only_on_server = autosaveOnlyOnServer;
    non_blocking_saving = nonBlockingSaving;
    minimum_segment_size = minimumSegmentSize;
    minimum_segment_size_peer_count = minimumSegmentSizePeerCount;
    maximum_segment_size = maximumSegmentSize;
    maximum_segment_size_peer_count = maximumSegmentSizePeerCount;
    admins = admins;
  };
  
  # Merge default settings with user-provided overrides
  finalServerSettings = defaultServerSettings // serverSettings;
  
  serverSettingsJson = writeText "server-settings.json" (builtins.toJSON finalServerSettings);

in stdenv.mkDerivation {
  name = "aces-factorio-headless";
  src = fetchurl {
    url = "https://factorio.com/get-download/stable/headless/linux64";
    sha256 = "ef12a54d1556ae1f84ff99edc23706d13b7ad41f1c02d74ca1dfadf9448fcbae";
  };
  buildInputs = [ makeWrapper ];
  unpackPhase = "tar -xJf $src";
  installPhase = ''
    mkdir -p $out/lib/factorio $out/bin $out/share/factorio
    cp -r factorio/* $out/lib/factorio/
    
    # Copy the server settings to a shared location
    cp ${serverSettingsJson} $out/share/factorio/server-settings.json
    
    cat > $out/bin/factorio << EOF
  #!/bin/sh
  export FACTORIO_USERDATA_PATH=\$HOME/.factorio
  mkdir -p \$HOME/.factorio
  cd \$HOME
  
  # Copy default server settings if none exist
  if [ ! -f \$HOME/.factorio/server-settings.json ]; then
    cp $out/share/factorio/server-settings.json \$HOME/.factorio/server-settings.json
  fi
  
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