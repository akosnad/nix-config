{ vimUtils, fetchFromGitHub}: vimUtils.buildVimPlugin {
  pname = "prettier-nvim";
  version = "2024-06-28";
  src = fetchFromGitHub {
    owner = "MunifTanjim";
    repo = "prettier.nvim";
    rev = "main";
    sha256 = "sha256-4xq+caprcQQotvBXnWWSsMwVB2hc5uyjrhT1dPBffXI=";
  };
}
