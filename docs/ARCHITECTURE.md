# Architecture proposal: Family OS on the Echo Show 15 (AEOHY, Fire OS 7)

Status: proposal only. Nothing on the Echo has been changed. Research is from public sources, not from the device.

## Constraints

- No ADB, Fastboot, root, or ordinary sideloading. The APK in `android/` cannot reach the Echo under these rules.
- Keep the Echo's existing software and data. Do not replace its home screen or launcher.
- No browser exploits or security bypasses.

## What the Echo offers

| Capability | Status | Source |
| --- | --- | --- |
| Silk browser is built in and opens by voice ("Alexa, open Silk") | **Documented by Amazon** for Echo Show; a user reports the wording changed for some users | [Silk developer guide](https://docs.aws.amazon.com/silk/latest/developerguide/what-is-silk.md), [SharpTools thread](https://community.sharptools.io/t/echo-show-15-kiosk-workaround-2024/14930) |
| A custom skill can open a URL with the APL `OpenURL` command | **Documented by Amazon** as a command that opens a URL in a browser on the device. Echo Show 15 behaviour is **not verified**; one forum report describes a black screen on an older Echo Show 5 | [APL standard commands](https://developer.amazon.com/en-IN/docs/alexa/alexa-presentation-language/apl-standard-commands.html), [HA forum](https://community.home-assistant.io/t/alexa-skill-to-display-lovelace-dashboards-on-echo-show/397632) |
| Development-stage skill on your own device, no store publication | **Documented**: enable the skill for testing and use the simulator. Physical-device testing is not confirmed by Amazon's own docs | [Alexa simulator](https://developer.amazon.com/docs/alexa/devconsole/alexa-simulator.html) |
| Home-screen cards for a custom skill | **Restricted**: developer preview only, en-US only, up to five active cards, a card shows for at least two hours, and cannot be personalised | [Amazon home cards doc](https://developer.amazon.com/en-US/docs/alexa/custom-skills/add-content-home-screen.html) |
| Keep Silk on screen | **Unsupported workaround**: a third-party "Keep Silk Open" script in a custom tile. Users report Silk returns to the Alexa home after a few minutes | [SharpTools thread](https://community.sharptools.io/t/echo-show-15-kiosk-workaround-2024/14930) |
| Set a custom screen as the default home | **Not available** through any documented route found | Amazon home-card docs above |
| Cast or mirror from a phone to arbitrary web content | **Not available**: Matter casting launched for Prime Video and a few apps only | [TechCrunch](https://techcrunch.com/2024/01/09/amazon-adds-matter-casting-to-its-smart-displays-and-tvs/) |
| Sideload an APK | **Unsupported**: a user report says current Echo Show 15 builds removed the file manager and sideloading | [SharpTools thread](https://community.sharptools.io/t/echo-show-15-kiosk-workaround-2024/14930) |
| Speech recognition and microphone inside Silk | **Not verified**. Family OS's voice mode relies on the microphone, so it may not work there | Family OS `docs/KIOSK.md` |

## Recommended route: custom Alexa skill that opens Family OS in Silk

Amazon's supported way to put custom content on an Echo Show is an Alexa skill. The skill runs in Amazon's cloud and sends a screen document to the device. Our code lives in this repo, and the Echo runs none of it locally.

```
Family OS (Vercel, already live)
        ^  opened by
Silk browser on Echo Show 15  <-- APL OpenURL command
        ^  sent by
Alexa skill "Family OS" (Node.js, Alexa-hosted backend, development stage)
        ^  invoked by
Voice: "Alexa, open Family OS"
```

1. **Skill (`skill/`, new):** a small Node.js skill using the ASK SDK. Its launch handler returns an APL document with an `OpenURL` command set to `config/dashboard.json` `url`. The URL is read at deploy time, not hard-coded.
2. **Deploy:** an Alexa-hosted backend. This needs an Amazon developer account (the same account as the Echo, or one linked to it), which you create and sign in to yourself.
3. **Test:** enable the skill for testing, run it in the simulator, then try it on the Echo. The skill stays in development stage and is never published.
4. **Keep-alive:** not built yet. If the Echo drops back to its home screen, the options are a voice routine that re-invokes the skill or the unsupported Silk tile. Both need testing on the device before they are relied on.

What stays the same on the Echo: its firmware, launcher, settings, accounts and data. The skill is removable from the Alexa app, and disabling it returns the Echo to normal.

### What this gives you, and what it does not

- **Gives:** Family OS opens on the Echo's screen by voice, full-screen in Silk if Silk's full-screen behaviour holds. Family OS's own idle and nightly reload logic still runs in the page.
- **Does not give:** Family OS as the default home screen. Amazon's home is not replaced. The Echo returns to its own screens after a timeout, and possibly after a few minutes of inactivity (reported, not verified).
- **Unknown until tested:** whether Silk holds the page, whether `OpenURL` works on this model, whether the microphone works for Family OS voice mode, and whether Silk's full screen hides Amazon's status bar.

## Alternatives considered

| Option | Verdict |
| --- | --- |
| Sideload the APK (`android/`) | Blocked by the constraints. The shell is kept for a future route, not deployed |
| Home-screen card from a skill | Too restricted to be the primary screen (preview only, en-US, two-hour minimum) |
| "Keep Silk Open" tile | Unsupported third-party script; use only if you accept that risk, after testing |
| Replace the Echo's launcher or home | No documented route. Would need root or firmware changes, which are out of scope |
| Cast from a phone | Only Prime Video and a few apps support it |

## Proposed repo changes (not built yet, waiting for your approval)

- `skill/` : the Alexa skill, with an interaction model, launch handler and APL document. No secrets are committed.
- `config/dashboard.json` : still the single source for the Family OS URL.
- `android/` : kept as documentation of the shell, marked as not deployable under the current constraints.
- `device/probe.sh` : unchanged; still useful for confirming ADB is closed.

## Decisions needed from you

1. **Primary experience:** the skill route gives Family OS on demand (by voice), not as a permanent home screen. Is that acceptable?
2. **Amazon developer account:** may I help set up the skill under your account? You must create or sign in to the developer account yourself.
3. **Keep-alive:** do you want the unsupported Silk tile tried on the device, or should we accept the voice-only launch?

## Sources

- [Silk developer guide](https://docs.aws.amazon.com/silk/latest/developerguide/what-is-silk.md)
- [SharpTools, "Echo Show 15 - Kiosk - Workaround 2024"](https://community.sharptools.io/t/echo-show-15-kiosk-workaround-2024/14930)
- [APL standard commands](https://developer.amazon.com/en-IN/docs/alexa/alexa-presentation-language/apl-standard-commands.html)
- [Add content to the home screen of Alexa devices](https://developer.amazon.com/en-US/docs/alexa/custom-skills/add-content-home-screen.html)
- [Test with the Alexa Simulator](https://developer.amazon.com/docs/alexa/devconsole/alexa-simulator.html)
- [Home Assistant forum, Alexa skill for Lovelace on Echo Show](https://community.home-assistant.io/t/alexa-skill-to-display-lovelace-dashboards-on-echo-show/397632)
- [Home Assistant forum, keep HA dashboard open on Echo Show 15 without sideloading](https://community.home-assistant.io/t/keep-ha-dashboard-open-on-newer-echo-show-15-without-sideloading-anything/605542)
- [TechCrunch, Matter casting on smart displays](https://techcrunch.com/2024/01/09/amazon-adds-matter-casting-to-its-smart-displays-and-tvs/)
