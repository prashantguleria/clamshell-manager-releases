#!/usr/bin/env bash
# Prepare a Clamshell Manager release from a notarized disk image.
#
# Usage: scripts/publish-release.sh <path-to-dmg> <version> [build-number]
#
# It computes the SHA-256 and size, prints the appcast <item> block (EdDSA signature is a placeholder you
# fill in from Sparkle's sign_update), and creates a DRAFT GitHub release. It never publishes anything and
# never touches the Keychain.
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "usage: $0 <path-to-dmg> <version> [build-number]" >&2
  exit 64
fi

dmg="$1"
version="$2"
build="${3:-$version}"
repo="prashantguleria/clamshell-manager-releases"
tag="v${version}"

[ -f "$dmg" ] || { echo "no such file: $dmg" >&2; exit 66; }

sha256="$(shasum -a 256 "$dmg" | awk '{print $1}')"
size="$(stat -f%z "$dmg")"
name="$(basename "$dmg")"
date_rfc822="$(LC_ALL=C date -u +"%a, %d %b %Y %H:%M:%S +0000")"

echo "SHA-256: ${sha256}"
echo "Size:    ${size} bytes"
echo
cat <<ITEM
    <item>
      <title>Version ${version}</title>
      <pubDate>${date_rfc822}</pubDate>
      <sparkle:version>${build}</sparkle:version>
      <sparkle:shortVersionString>${version}</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
      <sparkle:releaseNotesLink>https://github.com/${repo}/releases/tag/${tag}</sparkle:releaseNotesLink>
      <enclosure
        url="https://github.com/${repo}/releases/download/${tag}/${name}"
        length="${size}"
        type="application/octet-stream"
        sparkle:edSignature="EDDSA_SIGNATURE_HERE" />
    </item>
ITEM
echo
echo "Replace EDDSA_SIGNATURE_HERE with the output of: sign_update ${name}"
echo

gh release create "$tag" "$dmg" \
  --repo "$repo" \
  --draft \
  --title "Clamshell Manager ${version}" \
  --notes "SHA-256: ${sha256}"
