{ vimUtils
, fetchFromGitHub
}: vimUtils.buildVimPlugin {
  pname = "vim-transparent";
  version = "2024-06-01";
  dontBuild = true;
  src = fetchFromGitHub {
    owner = "tribela";
    repo = "vim-transparent";
    rev = "master";
    sha256 = "sha256-TGP8/NnMfwtpyaCtrRyxmeHTL029YjxRKHED5aY7NO4=";
  };
}
