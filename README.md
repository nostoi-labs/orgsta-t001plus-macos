# ORGSTA T001Plus driver for macOS on Apple Silicon (native arm64, no Rosetta)

**Italiano più in basso.**

A working print driver for the **ORGSTA T001Plus** thermal label printer on **macOS 27 and later, Apple Silicon (M1/M2/M3/M4)**, that does **not** need Rosetta 2.

> Not affiliated with ORGSTA. Community project, Apache 2.0.

## The problem

On an Apple Silicon Mac running macOS 27 the official ORGSTA driver (package `prt.orgsta.drv` 3.13.32) fails with:

> **The printer software is not compatible with this device.**

The vendor package claims Apple Silicon support, but every `rastertosnail*-macarm64` filter inside it is an **Intel (x86_64) binary renamed as arm64**, byte-for-byte identical to the `-macx64` version. On Intel Macs, and on Apple Silicon Macs that happen to have Rosetta 2 installed, it runs translated. Without Rosetta the CUPS filter dies with "Bad CPU type in executable" (`com.apple.badarch-error`) and nothing is sent to the printer. Apple is phasing Rosetta out starting with macOS 28, so this is not going to fix itself.

Everything else in the print chain (the PPD, Apple's USB backend, the printer itself, which speaks standard TSPL2 over USB printer class) works fine. Only the filter is broken.

## The fix

This package installs a **native universal (arm64 + x86_64) CUPS raster → TSPL filter** and a matching PPD. The filter is the unmodified [vevor-cups-driver](https://github.com/mattiacolombomc/vevor-cups-driver) by Mattia Colombo (Apache 2.0), written for the VEVOR Y486, which is the same OEM print engine with the same driver defect. It emits the same TSPL byte stream the vendor filter did.

## Install (2 minutes, no Terminal)

1. Download `ORGSTA-T001Plus-macOS-<version>.pkg` from [Releases](../../releases).
2. Double-click it, click Continue, enter your Mac password. The package is signed and notarized, so macOS opens it without warnings.
3. Plug in and switch on the printer. If it was already connected, the installer created the queue `ORGSTA_T001Plus` for you. Otherwise open **System Settings → Printers & Scanners → Add**: the printer is recognised automatically as "ORGSTA T001Plus".
4. Print. Default label size is **100 × 150 mm** (4 × 6 in); see below to make the print dialog open on it.

If you had a broken queue from the vendor driver, the installer switches it to the new driver; you do not need to delete it.

You can leave the vendor package installed (it is inert) or remove it: delete `/Library/Printers/ORGSTA`, the `rastertosnail*-orgsta` symlinks in `/usr/libexec/cups/filter/` and the three `ORGSTA-*.ppd` files in `/Library/Printers/PPDs/Contents/Resources/`, then `sudo pkgutil --forget prt.orgsta.drv`.

### Paper size: make 100 × 150 mm the default (one-time)

macOS pre-selects the **system default paper size** (A4 in most of Europe, Letter in the US) in every print dialog, even for printers that do not support it; it shows up under "Other formats". No driver can change that, and the vendor driver behaves the same way. The fix is a print preset, done once:

1. Open a label, press Cmd+P, set **Paper Size** to **100 × 150 mm** (or your roll size).
2. Open the **Presets** menu → **Save Current Settings as Preset…**, name it e.g. "Labels", choose **Only this printer**, save.
3. Print. From now on macOS re-applies that preset automatically whenever you print to the ORGSTA.

Courier labels such as InPost are A6 pages (105 × 148 mm): the PPD includes A6 as well, so you can also set A6 as the system default paper size (System Settings → Printers & Scanners → Default paper size) if that Mac prints little else. Printed 1:1 on 100 mm stock you lose 2.5 mm per side, which is only the frame.

### Tips

- **LED blinking red after the first label**, or labels feeding past the gap: hold the FEED button for 3–5 seconds to run the gap calibration.
- **Printer shows "Sending data" forever** right after failed attempts with the old driver: switch the printer off, unplug and replug USB, switch on. The stuck USB session goes away.
- Options in the print dialog: darkness, speed, gap/black-mark tracking, offsets, rotation (same names as the vendor driver).

### Uninstall

```
sudo /Library/Printers/OpenTSPL/uninstall.sh
```

## Build from source

Requires Xcode Command Line Tools.

```
git clone --recurse-submodules https://github.com/Vinceris/orgsta-t001plus-macos.git
cd orgsta-t001plus-macos
make          # build/rastertotspl, universal, ad-hoc signed
make pkg      # build/ORGSTA-T001Plus-macOS-<version>.pkg (unsigned unless Developer ID certs are in the keychain)
sudo installer -pkg build/ORGSTA-T001Plus-macOS-*.pkg -target /
```

`make notarize` signs with Developer ID and notarizes with an App Store Connect API key (maintainer use).

## Other TSPL printers

The same defect affects other printers built on the Shenzhen Weida "Snail" driver (Munbyn, Phomemo, iDPRT, Polono, Jadens, …). Adapting is a PPD edit: copy `ppd/orgsta-t001plus.ppd`, change `Manufacturer`, `ModelName`, `NickName` and the `1284DeviceID` line to what `lpinfo -l -v` reports for your printer. Pull requests welcome.

## Credits and license

- Filter: [vevor-cups-driver](https://github.com/mattiacolombomc/vevor-cups-driver) © 2026 Mattia Colombo, Apache License 2.0, bundled unmodified as a git submodule.
- PPD, installer, scripts: © 2026 Vincenzo Risi, Apache License 2.0. See `LICENSE` and `NOTICE`.
- Diagnosed and built with Claude Code on macOS 27.

---

# Italiano

Driver funzionante per la stampante di etichette **ORGSTA T001Plus** su **macOS 27 e successivi, Mac Apple Silicon (M1/M2/M3/M4)**, **senza Rosetta 2**.

## Il problema

Su un Mac Apple Silicon con macOS 27 il driver ufficiale ORGSTA (pacchetto `prt.orgsta.drv` 3.13.32) si ferma con:

> **Il software della stampante non è compatibile con questo dispositivo.**

Il pacchetto dichiara il supporto Apple Silicon, ma tutti i filtri `rastertosnail*-macarm64` al suo interno sono **binari Intel (x86_64) rinominati arm64**, identici byte per byte alla versione `-macx64`. Su Mac Intel, o su Mac Apple Silicon dove per caso c'è Rosetta 2, girano tradotti. Senza Rosetta il filtro CUPS muore con "Bad CPU type in executable" e alla stampante non arriva nulla. Apple sta ritirando Rosetta da macOS 28 in poi, quindi il problema non si risolverà da solo.

Tutto il resto della catena di stampa (PPD, backend USB di Apple, la stampante stessa che parla TSPL2 standard) funziona. È rotto solo il filtro.

## La soluzione

Questo pacchetto installa un **filtro CUPS raster → TSPL nativo universal (arm64 + x86_64)** e il relativo PPD. Il filtro è [vevor-cups-driver](https://github.com/mattiacolombomc/vevor-cups-driver) di Mattia Colombo (Apache 2.0), non modificato, scritto per la VEVOR Y486 che usa lo stesso motore di stampa OEM con lo stesso difetto nel driver.

## Installazione (2 minuti, senza Terminale)

1. Scarica `ORGSTA-T001Plus-macOS-<versione>.pkg` da [Releases](../../releases).
2. Doppio click, Continua, password del Mac. Il pacchetto è firmato e notarizzato: macOS lo apre senza avvisi.
3. Collega e accendi la stampante. Se era già collegata, l'installer ha creato la coda `ORGSTA_T001Plus` da solo. Altrimenti **Impostazioni di Sistema → Stampanti e scanner → Aggiungi**: la stampante viene riconosciuta come "ORGSTA T001Plus".
4. Stampa. Il formato di default è **100 × 150 mm** (4 × 6 pollici); vedi sotto per far aprire il dialogo di stampa già su quel formato.

Se avevi una coda rotta creata dal driver del produttore, l'installer la converte al driver nuovo: non serve cancellarla.

### Formato carta: rendere 100 × 150 mm il default (una volta sola)

macOS preseleziona in ogni dialogo di stampa il **formato carta di default di sistema** (A4 in Italia), anche per stampanti che non lo supportano: compare sotto "Altri formati". Nessun driver può cambiarlo, e il driver del produttore si comporta allo stesso modo. La soluzione è un preset di stampa, da fare una volta:

1. Apri un'etichetta, Cmd+P, imposta **Formato carta** su **100 × 150 mm** (o la misura del tuo rotolo).
2. Menu **Preset** → **Salva impostazioni attuali come preset…**, nome ad esempio "Etichette", scegli **Solo per questa stampante**, salva.
3. Stampa. Da quel momento macOS riapplica il preset da solo ogni volta che stampi sulla ORGSTA.

Le etichette dei corrieri come InPost sono pagine A6 (105 × 148 mm): il PPD include anche l'A6, quindi in alternativa puoi impostare A6 come formato di default di sistema (Impostazioni di Sistema → Stampanti e scanner → Formato carta di default) se quel Mac stampa poco altro. Stampata 1:1 su rotolo da 100 mm perdi 2,5 mm per lato, cioè solo la cornice.

### Consigli

- **LED rosso lampeggiante dopo la prima etichetta**: tieni premuto FEED per 3–5 secondi, la stampante ricalibra il sensore del gap.
- **"Invio dati alla stampante" che non finisce mai** subito dopo i tentativi falliti col vecchio driver: spegni la stampante, scollega e ricollega la USB, riaccendi.

### Disinstallazione

```
sudo /Library/Printers/OpenTSPL/uninstall.sh
```

## Crediti e licenza

Filtro: [vevor-cups-driver](https://github.com/mattiacolombomc/vevor-cups-driver) © 2026 Mattia Colombo, Apache 2.0. PPD, installer e script: © 2026 Vincenzo Risi, Apache 2.0. Progetto non affiliato a ORGSTA. Diagnosi e sviluppo con Claude Code su macOS 27.
