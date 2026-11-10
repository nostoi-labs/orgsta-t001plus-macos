#!/bin/bash
# Notarize + staple a signed pkg with an App Store Connect API key.
# Env: ASC_KEY_ID and ASC_ISSUER (required), ASC_KEY_PATH (default: ~/.appstoreconnect/private_keys/AuthKey_<ASC_KEY_ID>.p8)
set -euo pipefail
PKG="$1"
KEY_ID="${ASC_KEY_ID:?set ASC_KEY_ID to your App Store Connect API key ID}"
ISSUER="${ASC_ISSUER:?set ASC_ISSUER to your App Store Connect issuer ID}"
KEY_PATH="${ASC_KEY_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_${KEY_ID}.p8}"
xcrun notarytool submit "$PKG" --key "$KEY_PATH" --key-id "$KEY_ID" --issuer "$ISSUER" --wait
xcrun stapler staple "$PKG"
spctl -a -vv -t install "$PKG"
