# YNOEZ — iOS Tweaks Catalog

Curated index of jailbreak tweaks, themes and utilities. This directory is intentionally separate from the existing Roblox hub at the repository root.

## Important: catalog vs. installable Sileo source

This folder is a **catalog**, not yet a hosted APT/Sileo package repository. It does not pretend that third-party tweaks are installable from this GitHub URL. A real Sileo source needs valid Debian package metadata and authorized package files (or a properly maintained mirror). This project links to original developer repositories instead of copying paid/proprietary `.deb` files or redistributing packages without permission.

For now, add the original repository URLs listed in [Sileo sources](SILEO-SOURCES.md) to Sileo. This avoids broken packages and preserves developer updates.

## The video you sent

[❄️ MOSTRANDO MEUS TWEAKS ATUALIZADOS E FUNCIONANDO 100% PARA IPHONE (COM JAILBREAK) — RUIYA](https://www.youtube.com/watch?v=_mUys4RsW8g)  
Published: 13 February 2022 · Length: 12:15

The spoken Portuguese captions were machine-generated. Some tweak names are distorted by automatic transcription, so the catalog marks uncertain identifications instead of inventing exact package names.

### Identified from the video (transcript-based)

| Name heard / likely identification | What the video says it does | Confidence |
|---|---|---|
| AppData | WhatsApp storage/cache management; clear accumulated cache/data | Medium |
| App Store++ | Downgrade App Store apps to older versions | High |
| Battery/charging tweak (name unclear) | Claimed faster charging | Low — not identified |
| Dark Void X | Theme | Medium |
| Frame | Theme / visual customization | High |
| MyWall | WhatsApp background/wallpaper customization | High |
| Resolution / DPI tweak (name unclear) | Changes display scaling/resolution; video mentions 1792×828 and 2150×994 | Low — not identified |
| Floating app shortcut (name unclear) | Floating square shortcut to open another app | Low — not identified |
| RGB keyboard tweak (name unclear; heard as “RG Board”) | Keyboard colors/effects | Low — not identified |
| Shadow | Per-app jailbreak-detection compatibility/bypass | High |
| SnowBoard | Theme engine for icons and system appearance | High |
| Opus theme | Theme | High |
| Springtomize 5 | Broad SpringBoard customization | High |
| Substitute | Tweak injection / substrate compatibility layer, not a cosmetic tweak | High |
| TapticFlow (transcript spelling) | On-screen floating control / recording aid; exact package identity unverified | Low |
| Status-bar customization (name unclear) | Changes status-bar icons/colors | Low — not identified |

**Do not install the low-confidence entries by name alone.** Their spoken captions are too distorted to identify a trustworthy package. The video is from 2022; its claim that tweaks worked at the time is not evidence of compatibility with current iOS.

## Recommended original sources

See [SILEO-SOURCES.md](SILEO-SOURCES.md) for repository URLs and what each source is used for.

## Performance policy

Most tweaks shown in the video are customization, theming, app compatibility or convenience tools — **not performance optimizers**. Themes, animation-heavy effects, injected tweaks and status-bar modifications can increase memory use, battery drain or SpringBoard instability. This catalog keeps performance claims separate from appearance features.

Start with no more than one system-level tweak at a time. Keep a known-good jailbreak recovery path and disable/remove a tweak if SpringBoard enters Safe Mode, battery drain rises, or apps crash.

## Compatibility

There is no universal compatibility promise. Compatibility depends on:
- exact iPhone model and iOS build;
- jailbreak and bootstrap (Dopamine, palera1n, RootHide, etc.);
- package architecture (rootless, RootHide, or rootful);
- injection environment and dependencies.

Before any installation, verify the package's current developer README and package metadata. Rootless, RootHide and rootful packages are not interchangeable.

## Next work

- Resolve the low-confidence video names from the actual on-screen package manager frames.
- Add a verified compatibility matrix once the target iPhone/iOS/jailbreak is known.
- Only publish a Sileo/APT endpoint after authorized package hosting, metadata, checksums and installation tests exist.
