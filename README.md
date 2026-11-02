# Echo Show 15 — family command centre

The Echo Show 15 (2022, first generation) shows the Family OS dashboard full-screen:
<https://family-os-lemon-three.vercel.app/>. Family OS is its own project
(`Claude Code/Family OS/family-os`); this repo only holds the setup for the Echo.

## Layout

```
config/dashboard.json   the URL and display size the Echo should show
device/probe.sh         read-only check of a device's debug ports (ADB 5555, HTTP 80)
```

## Device status (checked 1 Nov 2026)

- No Echo Show is connected by USB, and none answered on the LAN. Its ADB port (5555) was not found.
- The only ADB device on this network is the Fire TV Stick (`192.168.86.64`), which belongs to `tv-dashboard`. It is not touched here.
- Nothing has been installed, changed or backed up on the Echo. Its original software and data are untouched.

## Next steps (need the Echo)

1. Put the Echo on the same Wi-Fi as this Mac and wake it.
2. Run `device/probe.sh <echo-ip>` to see which debug interfaces it actually exposes.
3. Only after that is confirmed, choose how to put the dashboard on screen. Options to check on the device:
   - the built-in browser, if the Echo exposes one, opened to the dashboard URL;
   - a kiosk app like FreeKiosk, if it can be installed (Family OS's `docs/KIOSK.md` covers the Fire tablet case);
   - an APK via ADB, if developer access turns out to be available.
4. Sign in once with a parent account on the device. Family OS then asks you to turn on "Family tablet (kiosk mode)".

Nothing in this list has been verified on the Echo itself.

## Dashboard check

The dashboard was loaded in the desktop browser at 1920×1080. It opens to its sign-in page (`/login`), as expected for a family account.

## Probe

```bash
device/probe.sh 192.168.86.xx
```

It checks ports 5555 and 80 and reports whether ADB is connected. It sends nothing to the device except a read-only `getprop` when ADB is already connected.
