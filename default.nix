# default.nix
{ stdenv, fetchurl, makeWrapper, writeText
# Server settings
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
, onlyAdminsCanPauseTheGame ? true
, autosaveOnlyOnServer ? true
, nonBlockingSaving ? false
, minimumSegmentSize ? 25
, minimumSegmentSizePeerCount ? 20
, maximumSegmentSize ? 100
, maximumSegmentSizePeerCount ? 10
, admins ? []
, serverSettings ? {}

# Map generation settings
, mapWidth ? 0
, mapHeight ? 0
, startingArea ? 1
, peacefulMode ? false
, mapSeed ? null
, startingPoints ? [{ x = 0; y = 0; }]
, oreSettings ? {
    coal = { frequency = 1; size = 1; richness = 1; };
    stone = { frequency = 1; size = 1; richness = 1; };
    copper-ore = { frequency = 1; size = 1; richness = 1; };
    iron-ore = { frequency = 1; size = 1; richness = 1; };
    uranium-ore = { frequency = 1; size = 1; richness = 1; };
    crude-oil = { frequency = 1; size = 1; richness = 1; };
  }
, terrainSettings ? {
    water = { frequency = 1; size = 1; };
    trees = { frequency = 1; size = 1; };
    enemy-base = { frequency = 1; size = 1; };
  }
, cliffSettings ? {
    name = "cliff";
    cliff_elevation_0 = 10;
    cliff_elevation_interval = 40;
    richness = 1;
  }
, moistureSettings ? {
    frequency = "1";
    bias = "0";
  }
, terrainTypeSettings ? {
    frequency = "1";
    bias = "0";
  }
, mapGenSettings ? {}

# Map settings (gameplay)
, technologyPriceMultiplier ? 1
, spoilTimeModifier ? 1
, pollutionEnabled ? true
, pollutionSettings ? {
    diffusion_ratio = 0.02;
    min_to_diffuse = 15;
    ageing = 1;
    expected_max_per_chunk = 150;
    min_to_show_per_chunk = 50;
    min_pollution_to_damage_trees = 60;
    pollution_with_max_forest_damage = 150;
    pollution_per_tree_damage = 50;
    pollution_restored_per_tree_damage = 10;
    max_pollution_to_restore_trees = 20;
    enemy_attack_pollution_consumption_modifier = 1;
  }
, enemyEvolutionEnabled ? true
, enemyEvolutionSettings ? {
    time_factor = 0.000004;
    destroy_factor = 0.002;
    pollution_factor = 0.0000009;
  }
, enemyExpansionEnabled ? true
, enemyExpansionSettings ? {
    max_expansion_distance = 7;
    friendly_base_influence_radius = 2;
    enemy_building_influence_radius = 2;
    building_coefficient = 0.1;
    other_base_coefficient = 2.0;
    neighbouring_chunk_coefficient = 0.5;
    neighbouring_base_chunk_coefficient = 0.4;
    max_colliding_tiles_coefficient = 0.9;
    settler_group_min_size = 5;
    settler_group_max_size = 20;
    min_expansion_cooldown = 14400;
    max_expansion_cooldown = 216000;
  }
, asteroidsSettings ? {
    spawning_rate = 1;
    max_ray_portals_expanded_per_tick = 100;
  }
, mapSettings ? {}
}:

let
  # Server settings JSON
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
  
  finalServerSettings = defaultServerSettings // serverSettings;
  serverSettingsJson = writeText "server-settings.json" (builtins.toJSON finalServerSettings);

  # Map generation settings JSON
  defaultMapGenSettings = {
    width = mapWidth;
    height = mapHeight;
    starting_area = startingArea;
    peaceful_mode = peacefulMode;
    seed = mapSeed;
    starting_points = startingPoints;
    autoplace_controls = oreSettings // terrainSettings;
    cliff_settings = cliffSettings;
    property_expression_names = {
      "control:moisture:frequency" = moistureSettings.frequency;
      "control:moisture:bias" = moistureSettings.bias;
      "control:aux:frequency" = terrainTypeSettings.frequency;
      "control:aux:bias" = terrainTypeSettings.bias;
    };
  };
  
  finalMapGenSettings = defaultMapGenSettings // mapGenSettings;
  mapGenSettingsJson = writeText "map-gen-settings.json" (builtins.toJSON finalMapGenSettings);

  # Map settings JSON (gameplay settings)
  defaultMapSettings = {
    difficulty_settings = {
      technology_price_multiplier = technologyPriceMultiplier;
      spoil_time_modifier = spoilTimeModifier;
    };
    pollution = {
      enabled = pollutionEnabled;
    } // pollutionSettings;
    enemy_evolution = {
      enabled = enemyEvolutionEnabled;
    } // enemyEvolutionSettings;
    enemy_expansion = {
      enabled = enemyExpansionEnabled;
    } // enemyExpansionSettings;
    unit_group = {
      min_group_gathering_time = 3600;
      max_group_gathering_time = 36000;
      max_wait_time_for_late_members = 7200;
      max_group_radius = 30.0;
      min_group_radius = 5.0;
      max_member_speedup_when_behind = 1.4;
      max_member_slowdown_when_ahead = 0.6;
      max_group_slowdown_factor = 0.3;
      max_group_member_fallback_factor = 3;
      member_disown_distance = 10;
      tick_tolerance_when_member_arrives = 60;
      max_gathering_unit_groups = 30;
      max_unit_group_size = 200;
    };
    steering = {
      default = {
        radius = 1.2;
        separation_force = 0.005;
        separation_factor = 1.2;
        force_unit_fuzzy_goto_behavior = false;
      };
      moving = {
        radius = 3;
        separation_force = 0.01;
        separation_factor = 3;
        force_unit_fuzzy_goto_behavior = false;
      };
    };
    path_finder = {
      fwd2bwd_ratio = 5;
      goal_pressure_ratio = 2;
      max_steps_worked_per_tick = 1000;
      max_work_done_per_tick = 8000;
      use_path_cache = true;
      short_cache_size = 5;
      long_cache_size = 25;
      short_cache_min_cacheable_distance = 10;
      short_cache_min_algo_steps_to_cache = 50;
      long_cache_min_cacheable_distance = 30;
      cache_max_connect_to_cache_steps_multiplier = 100;
      cache_accept_path_start_distance_ratio = 0.2;
      cache_accept_path_end_distance_ratio = 0.15;
      negative_cache_accept_path_start_distance_ratio = 0.3;
      negative_cache_accept_path_end_distance_ratio = 0.3;
      cache_path_start_distance_rating_multiplier = 10;
      cache_path_end_distance_rating_multiplier = 20;
      stale_enemy_with_same_destination_collision_penalty = 30;
      ignore_moving_enemy_collision_distance = 5;
      enemy_with_different_destination_collision_penalty = 30;
      general_entity_collision_penalty = 10;
      general_entity_subsequent_collision_penalty = 3;
      extended_collision_penalty = 3;
      max_clients_to_accept_any_new_request = 10;
      max_clients_to_accept_short_new_request = 100;
      direct_distance_to_consider_short_request = 100;
      short_request_max_steps = 1000;
      short_request_ratio = 0.5;
      min_steps_to_check_path_find_termination = 2000;
      start_to_goal_cost_multiplier_to_terminate_path_find = 2000.0;
      overload_levels = [0 100 500];
      overload_multipliers = [2 3 4];
      negative_path_cache_delay_interval = 20;
    };
    asteroids = asteroidsSettings;
    max_failed_behavior_count = 3;
  };
  
  finalMapSettings = defaultMapSettings // mapSettings;
  mapSettingsJson = writeText "map-settings.json" (builtins.toJSON finalMapSettings);

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
    
    # Copy all configuration files to shared location
    cp ${serverSettingsJson} $out/share/factorio/server-settings.json
    cp ${mapGenSettingsJson} $out/share/factorio/map-gen-settings.json
    cp ${mapSettingsJson} $out/share/factorio/map-settings.json
    
    cat > $out/bin/factorio << EOF
  #!/bin/sh
  export FACTORIO_USERDATA_PATH=\$HOME/.factorio
  mkdir -p \$HOME/.factorio
  cd \$HOME
  
  # Copy default configuration files if none exist
  if [ ! -f \$HOME/.factorio/server-settings.json ]; then
    cp $out/share/factorio/server-settings.json \$HOME/.factorio/server-settings.json
  fi
  if [ ! -f \$HOME/.factorio/map-gen-settings.json ]; then
    cp $out/share/factorio/map-gen-settings.json \$HOME/.factorio/map-gen-settings.json
  fi
  if [ ! -f \$HOME/.factorio/map-settings.json ]; then
    cp $out/share/factorio/map-settings.json \$HOME/.factorio/map-settings.json
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