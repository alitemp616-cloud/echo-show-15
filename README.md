# Echo Show 15 — Family OS kiosk

Puts the Family OS dashboard (<https://family-os-lemon-three.vercel.app/>) on the first-generation Echo Show 15
(AEOHY, Fire OS 7). Family OS is its own project (`Claude Code/Family OS/family-os`). This repo holds the bridge.

**Current direction:** see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). ADB is unavailable on this device, so the APK
in `android/` cannot be installed. The proposed route is an Alexa skill that opens Family OS in the Silk browser.
Nothing on the Echo has been changed.

## Architecture

- **Family OS (web app)** does everything visible: the picker, chores, calendar, voice mode, and its own kiosk
  behaviour (keeps the screen awake, returns to "Who's here?" when idle, reloads nightly). See its `docs/KIOSK.md`.
- **Echo shell (`android/`)** is a thin Android app. It is a full-screen WebView that loads the dashboard URL,
  passes the microphone through for voice mode, retries if the page fails to load, and opens after a restart.
- **Device probe (`device/probe.sh`)** is a read-only check of which debug ports the Echo exposes.

## Layout

```
config/dashboard.json   the URL the Echo shows, compiled into the shell at build time
android/                WebView kiosk shell: manifest, two Java classes, build and check scripts
device/probe.sh         read-only check of a device's ADB (5555) and HTTP (80) ports
```

## Build and check (on this Mac, no device needed)

```bash
android/build.sh     # builds android/build/echoshow.apk (debug-signed, key generated locally)
android/check.sh     # checks package, permissions, launcher and boot entries, signature, and the URL
```

The build uses the SDK tools already installed here (build-tools 30.0.3, platform android-22, OpenJDK 17).
`build/` is git-ignored, so the generated signing key is never committed.

## Status (1 Nov 2026)

| Item | Status |
| --- | --- |
| Dashboard loads at 1920×1080 | Verified in the desktop browser; shows the sign-in page |
| Kiosk shell APK builds | Verified (`build.sh`) |
| APK manifest, permissions, signature, URL | Verified (`check.sh`, 9 of 9) |
| Shell runs on the Echo | **Not verified.** No Echo is reachable from this Mac |
| Echo's install path (sideload, developer access) | **Not verified** |
| Microphone and voice mode on the Echo | **Not verified** |
| Auto-start after reboot on the Echo | **Not verified** (Fire OS may block it) |

Limits: the shell is built against platform android-22, so it sets `targetSdk` 22 to get install-time
permissions. Raise it before any store release. The shell is a launcher app, not the home screen: the Echo keeps its own home.

## Device status

- No Echo Show is connected by USB, and none answered on the LAN.
- The only ADB device here is the Fire TV Stick (`192.168.86.64`), which belongs to `tv-dashboard`. It is not touched.
- Nothing has been installed, changed or backed up on the Echo, so its original software and data are untouched.

## Next steps (need the Echo)

1. Put the Echo on this Mac's Wi-Fi, wake it, and run `device/probe.sh <echo-ip>` to see what it exposes.
2. Confirm which install route works (developer access, ADB, or a browser-based method). Ask before any install.
3. Install `android/build/echoshow.apk` and test: the dashboard shows, voice mode hears the wake name, a reboot brings it back.
4. Sign in once with a parent account on the Echo. Family OS then offers "Family tablet (kiosk mode)".
