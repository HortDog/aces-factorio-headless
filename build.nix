# build.nix - Example usage with various configuration options
let
  pkgs = import <nixpkgs> {};
in
  pkgs.callPackage ./default.nix {
    # World configuration
    mapSeed = 42424242; # Set Seed for world generation

    # Resource settings - broken for test purposes
    oreSettings = {
      coal = { frequency = 10; size = 10; richness = 10; };
      stone = { frequency = 10; size = 10; richness = 10; };
      copper-ore = { frequency = 10; size = 10; richness = 10; };
      iron-ore = { frequency = 10; size = 10; richness = 10; };
      uranium-ore = { frequency = 10; size = 10; richness = 10; }; 
      crude-oil = { frequency = 10; size = 10; richness = 10; };
    };
    

    # Basic server info
    serverName = "ACES Server";
    description = "A server for friends and fun";
    tags = [ "aces" ];
    
    # Player settings
    maxPlayers = 25; # Maximum number of players allowed
    gamePassword = "ace42"; # Password for joining the server
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
    afkAutokickInterval = 15;  # Kick after 15 minutes AFK
    autoPause = true;  # pause when empty
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