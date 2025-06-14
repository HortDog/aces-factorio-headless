# build.nix - Example usage with various configuration options
let
  pkgs = import <nixpkgs> {};
in
  pkgs.callPackage ./default.nix {
    # Basic server info
    serverName = "My Awesome Factorio Server";
    description = "A modded server for friends and fun";
    tags = [ "modded" "friendly" "eu" ];
    
    # Player settings
    maxPlayers = 15;
    gamePassword = "secret123";
    requireUserVerification = true;
    ignorePlayerLimitForReturningPlayers = true;
    
    # Visibility settings
    visibility = { 
      public = false; 
      lan = false; 
    };
    
    # Factorio.com credentials (required for public servers)
    username = "your_factorio_username";
    # password = "your_password";  # Use token instead for security
    token = "your_auth_token";
    
    # Network settings
    maxUploadInKilobytesPerSecond = 1000;
    maxUploadSlots = 10;
    minimumLatencyInTicks = 0;
    maxHeartbeatsPerSecond = 60;
    
    # Game settings
    allowCommands = "admins-only";
    autosaveInterval = 5;  # Save every 5 minutes
    autosaveSlots = 10;
    afkAutokickInterval = 30;  # Kick after 30 minutes AFK
    autoPause = true;  # Don't pause when empty
    autoPauseWhenPlayersConnect = false;
    onlyAdminsCanPauseTheGame = true;
    
    # Performance settings
    autosaveOnlyOnServer = true;
    nonBlockingSaving = false;  # Keep false unless you know what you're doing
    
    # Segment size settings (for network optimization)
    minimumSegmentSize = 25;
    minimumSegmentSizePeerCount = 20;
    maximumSegmentSize = 100;
    maximumSegmentSizePeerCount = 10;
    
    # Admin list
    admins = [ "admin1" "admin2" "moderator1" ];
    
    # Any additional custom settings can be added here
    serverSettings = {
      # This will override any of the above settings if needed
      # or add new ones not covered by the parameters
    };
  }