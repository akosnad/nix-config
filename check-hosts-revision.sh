git fetch
hosts=$(nix eval --raw .#nixosConfigurations --apply 'x: (builtins.attrNames x) |> builtins.concatStringsSep "\n"')
latest_rev=$(git rev-parse main)

result_fifo_dir=$(mktemp -d)
result_fifo="$result_fifo_dir/fifo"
mkfifo "$result_fifo"
function cleanup() {
  rm -rf "$result_fifo_dir"
}
trap cleanup EXIT

function check_host() {
  rev=$(ssh -oConnectTimeout=2s "$host" -- "jq -r '.flakes | .[] | select(.from.id == \"self\") | .to.rev' /etc/nix/registry.json" 2>/dev/null || echo \?)
  if [[ $rev == "$latest_rev" ]]; then
    echo "$1": up-to-date >>"$result_fifo"
  else
    echo "$1": not up-to-date: "$rev" >>"$result_fifo"
  fi
}

for host in $hosts; do
  check_host "$host" &
done

while [[ "$(jobs -rp)" != "" ]]; do
  if read -r line; then
    echo "$line"
  fi
done <"$result_fifo"

wait
