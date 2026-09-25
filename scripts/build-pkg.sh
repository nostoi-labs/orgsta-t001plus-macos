#!/bin/bash
# Builds the .pkg installer. Env: VERSION, INSTALLER_ID (Developer ID Installer identity; empty = unsigned)
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${VERSION:-1.0.0}"
ROOT="$HERE/build/root"
OUT="$HERE/build/ORGSTA-T001Plus-macOS-$VERSION.pkg"
rm -rf "$ROOT" "$HERE/build/component.pkg"
mkdir -p "$ROOT/Library/Printers/OpenTSPL/Filter" "$ROOT/Library/Printers/PPDs/Contents/Resources"
install -m 755 "$HERE/build/rastertotspl" "$ROOT/Library/Printers/OpenTSPL/Filter/rastertotspl"
install -m 644 "$HERE/ppd/orgsta-t001plus.ppd" "$ROOT/Library/Printers/PPDs/Contents/Resources/orgsta-t001plus.ppd"
install -m 755 "$HERE/scripts/uninstall.sh" "$ROOT/Library/Printers/OpenTSPL/uninstall.sh"
install -m 644 "$HERE/LICENSE" "$ROOT/Library/Printers/OpenTSPL/LICENSE"
install -m 644 "$HERE/NOTICE" "$ROOT/Library/Printers/OpenTSPL/NOTICE"
pkgbuild --root "$ROOT" --identifier com.vinceris.orgsta-t001plus --version "$VERSION" \
  --scripts "$HERE/pkg/scripts" --install-location / "$HERE/build/component.pkg"
sed "s/@VERSION@/$VERSION/g" "$HERE/pkg/distribution.xml" > "$HERE/build/distribution.xml"
ARGS=(--distribution "$HERE/build/distribution.xml" --package-path "$HERE/build" --resources "$HERE/pkg/resources")
if [ -n "${INSTALLER_ID:-}" ]; then ARGS+=(--sign "$INSTALLER_ID" --timestamp); fi
productbuild "${ARGS[@]}" "$OUT"
echo "built: $OUT"; [ -n "${INSTALLER_ID:-}" ] && pkgutil --check-signature "$OUT" | head -3 || echo "(unsigned)"
