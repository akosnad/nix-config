let
  infiniteSeeding = name: {
    inherit name;
    seeding_time_limit = -1;
    ratio_limit = -1;
  };
  leechOnly = name: {
    inherit name;
    seeding_time_limit = 0;
    ratio_limit = 0;
  };

  nCore = name: {
    inherit name;
    seeding_time_limit = 3240;
    ratio_limit = 1.01;
  };
in
{
  category_limits = (map nCore [ "nCore" "nCore Filmek" "nCore Sorozatok" ])
    ++ (map leechOnly [ "Bitmagnet" ])
    ++ (map infiniteSeeding [ "ProAudioTorrents" ])
    ++ [
    {
      name = "Redacted";
      seeding_time_limit = -1;
      ratio_limit = 0.6;
    }
    {
      name = "TorrentLeech";
      seeding_time_limit = 14450;
      ratio_limit = 1;
    }
    {
      name = "RuTracker";
      seeding_time_limit = 14450;
      ratio_limit = 0.6;
    }
    {
      name = "BestCore";
      seeding_time_limit = 4350;
      ratio_limit = 0.8;
    }
  ];
}
