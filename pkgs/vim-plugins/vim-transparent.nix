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
    sha256 = "sha256-zEH5A9CKaoN5DXJjmC0+j74kBZsfJm+Ztk1qFHeIzts=";
  };
}
