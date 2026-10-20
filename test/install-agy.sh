#!/usr/bin/env bash
# Pinned real CLI for contract/e2e tests; no account or shell-profile changes.
set -euo pipefail
destination="${1:?usage: install-agy.sh /path/to/bin}"
version=1.4.3
case "$(uname -s)/$(uname -m)" in
Linux/aarch64 | Linux/arm64) platform=linux_arm64; digest=045aa7112f574ef97f8320a65d30a555c4ce9bdd5e3d56d40fce7e262ca98cda ;;
Linux/x86_64) platform=linux_x64; digest=319b2cb3240d244930bd077033b466941fd7ba6f0881d783eee801dbd2fb9371 ;;
Darwin/arm64) platform=mac_arm64; digest=be7a40acd87ff43e453ae216e57843919c77dc7c0278ba2d97e21591fc3b27cb ;;
Darwin/x86_64) platform=mac_x64; digest=3d8e79da604d9532915dc2fb4e4c770d7cc12254563414413987cbcae40fa0b8 ;;
*) echo "Unsupported agy test platform" >&2; exit 1 ;;
esac
temp=$(mktemp -d)
trap 'rm -rf "$temp"' EXIT
curl -fsSL --connect-timeout 15 --max-time 300 --retry 3 \
	"https://github.com/google-antigravity/antigravity-cli/releases/download/$version/agy_cli_$platform.tar.gz" \
	-o "$temp/agy.tar.gz"
if command -v sha256sum >/dev/null; then
	printf '%s  %s\n' "$digest" "$temp/agy.tar.gz" | sha256sum -c -
else
	printf '%s  %s\n' "$digest" "$temp/agy.tar.gz" | shasum -a 256 -c -
fi
tar -xzf "$temp/agy.tar.gz" -C "$temp" antigravity
mkdir -p "$destination"
install -m 0755 "$temp/antigravity" "$destination/agy"
"$destination/agy" --version
