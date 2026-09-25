#!/bin/bash
# Notarize + staple a signed pkg with an App Store Connect API key.
# Env: ASC_KEY_ID (default 93WLS9TRR2), ASC_ISSUER, ASC_KEY_PATH
set -euo pipefail
PKG="$1"
KEY_ID="${ASC_KEY_ID:-93WLS9TRR2}"
ISSUER="${ASC_ISSUER:-aab4fa1c-5ea5-439e-8cf0-01fd804f298b}"
KEY_PATH="${ASC_KEY_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_${KEY_ID}.p8}"
xcrun notarytool submit "$PKG" --key "$KEY_PATH" --key-id "$KEY_ID" --issuer "$ISSUER" --wait
xcrun stapler staple "$PKG"
spctl -a -vv -t install "$PKG"
