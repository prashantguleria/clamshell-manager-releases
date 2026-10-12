# Appcast

`appcast.xml` is the Sparkle 2 feed. The app will read `SUFeedURL`, which is
`https://evenpine.com/clamshell-manager/appcast.xml`; that address is meant to redirect or proxy to the raw
file in this repository. Until a release exists the feed has no items.

## Publishing a release

1. Build, sign and notarize the disk image `ClamshellManager-<version>.dmg`. None of that happens here.
2. Sign it with Sparkle's `sign_update` on your own Mac. The private key stays in your login Keychain and
   never enters this repository:

   ```sh
   sign_update ClamshellManager-<version>.dmg
   ```

3. Run `scripts/publish-release.sh <dmg> <version>`. It prints the SHA-256 and size, prints an `<item>`
   block for the appcast with the EdDSA signature left as a placeholder, and creates a **draft** GitHub
   release with the disk image attached.
4. Paste the item into `appcast.xml` above any older items and replace `EDDSA_SIGNATURE_HERE` with the
   signature from step 2.
5. Add the version to `CHANGELOG.md`, commit, then publish the draft release.

Each `<item>` needs the version (`sparkle:version` is the build number, `sparkle:shortVersionString` the
display version), `sparkle:minimumSystemVersion` (`13.0`), the download URL, the length in bytes and the
EdDSA signature.
