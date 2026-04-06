{ vimUtils, fetchFromGitHub }: vimUtils.buildVimPlugin {
  pname = "prettier-nvim";
  version = "2024-06-28";
  src = fetchFromGitHub {
    owner = "MunifTanjim";
    repo = "prettier.nvim";
    rev = "d98e732cb73690b07c00c839c924be1d1d9ac5c2";
    sha256 = "sha256-4xq+caprcQQotvBXnWWSsMwVB2hc5uyjrhT1dPBffXI=";
  };
}
