# Free-first Sileo sources for ynoez

These are upstream sources, not mirrors. Add them individually in Sileo → Sources → +. A source being free does not mean every package in it supports iOS 15.8.8 or your exact device.

| Repository | URL | Notes |
|---|---|---|
| Jond-ie | https://jond-ie.github.io/repo/ | Explicitly advertises free Rootless/RootHide tweaks; broadest currently reviewed free catalog here. |
| Rato | https://ios.ratu.sh/ | Rootless packages; check package architecture and each package's stated test matrix. |
| opa334 | https://opa334.github.io/ | Dopamine developer's repository and jailbreak ecosystem packages. |
| SparkDev | https://sparkdev.me/ | SnowBoard and customization ecosystem; verify the exact package and dependencies. |
| jjolano | https://ios.jjolano.me/ | Shadow and compatibility utilities; use only if needed and configure per-app. |
| BigBoss | https://apt.thebigboss.org/repofiles/cydia/ | Large legacy catalog. Many packages are rootful or old; do not assume compatibility. |
| CokePokes | https://cokepokes.github.io/ | Historical App Store++ source; check current availability and package metadata before use. |
| LumiRepo | https://repo.ya-ebal.mom/ | Themes and utilities; check individual package source, license and rootless support. |

## Jond-ie free Rootless/RootHide catalog reviewed

The publisher describes this repository as free and compatible with Rootless and RootHide. Its current site lists the following projects and iOS ranges. The iOS range is the publisher's claim, not a device-specific test on iPhone8,2.

| Tweak | Publisher's iOS range | Function | ynoez note |
|---|---|---|---|
| Triggr | 15–27 | Button, gesture and event actions | Useful customization; not a speed optimizer |
| Pinstant | 15–18 | Wake directly to passcode screen | Lock-screen behavior |
| BlankPass | 15–18 | Hide passcode keypad numbers | Visual/privacy option |
| Anywhere | 15–17 | Place apps/widgets anywhere on Home Screen | Home Screen customization |
| Bounce It! port | 15–27 | Springy Home Screen animations | Optional effects may add overhead |
| XEdgeProtect port | 15–27 | Two-step swipe-up behavior | Gesture customization |
| PullOver Pro port | 15–27 | Edge pull-over multitasking panel | Multitasking |
| Density | 15–18 | Per-app display density | Change cautiously; layout issues possible |
| Podified | 15–18 | Remove cellular settings clutter on devices without SIM | Niche utility |
| BegoneCIA port | 15–27 | Control Center switch for camera/mic/location blocking | Privacy; test permissions and calls |
| Slaplock beta | 15–17 | Lock selected apps behind biometrics | Beta; security-sensitive |
| Scrub | 15–27 | Remove location and other hidden photo metadata before sharing | Privacy |
| Crest | 15–27 | Player for local files including FLAC/DSD/Opus | Music utility |
| Crossfade | 15–16 | Crossfade in stock Music | Music utility |
| EQELinker | 15–27 | Switch EQE presets using Triggr | Requires Triggr and EQE |
| Catapult beta | 14–18 | LineageOS-style Home Screen | Publisher labels this Rootful; excluded from this Rootless target |
| LiteFace | 18–27 | Face ID animation change | Not compatible with iOS 15; excluded |

## Other free projects worth checking

- **SnowBoard** (SparkDev): theming engine; use sparingly because theme hooks can add overhead.
- **App Store++**: the video mentions it, but its current free availability and exact iOS 15.8.8 support are not confirmed here.
- **BegoneCIA, Scrub, Crossfade and Crest** are convenience/privacy/media tools, not CPU/RAM/battery optimizers.

## Rules

1. Prefer the developer's own source over recompiled third-party mirrors.
2. Do not add RootHide-only (iphoneos-arm64e) or Rootful (iphoneos-arm) packages to the standard Dopamine Rootless setup.
3. Standard Rootless packages use iphoneos-arm64; Theos Rootless builds install under /var/jb.
4. Check dependencies, conflicts, minimum iOS version, architecture and license before installing.
5. Never install multiple jailbreak-detection bypass tweaks together.
6. Do not install a package merely because its name appears in the 2022 video.
7. For iPhone8,2 / iOS 15.8.8, treat every upstream range as a candidate until tested on this exact device.
