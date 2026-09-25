#!/bin/bash
# Removes the ORGSTA T001Plus open driver and its print queues. Run: sudo /Library/Printers/OpenTSPL/uninstall.sh
set -uo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Please run with sudo: sudo $0"; exit 1; }
for f in /etc/cups/ppd/*.ppd; do
  [ -f "$f" ] || continue
  if grep -q '/Library/Printers/OpenTSPL/' "$f"; then q="$(basename "$f" .ppd)"; echo "removing queue $q"; lpadmin -x "$q"; fi
done
rm -f /Library/Printers/PPDs/Contents/Resources/orgsta-t001plus.ppd
rm -rf /Library/Printers/OpenTSPL
pkgutil --forget com.vinceris.orgsta-t001plus >/dev/null 2>&1 || true
echo "Done. The ORGSTA T001Plus open driver has been removed."
