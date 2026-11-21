# Free-first Sileo sources for ynoez

These are upstream sources, not mirrors. Add them individually in Sileo → Sources → +. A source being free does not mean every package in it supports iOS 15.8.8 or your exact device.

| Repository | URL | Notes |
|---|---|---|
| Jond-ie | https://jond-ie.github.io/repo/ | Advertises free Rootless/RootHide tweaks. Includes projects such as Triggr and other utilities; inspect each package's iOS range. |
| Rato | https://ios.ratu.sh/ | Rootless packages; check package architecture and each package's stated test matrix. |
| opa334 | https://opa334.github.io/ | Dopamine developer's repository and jailbreak ecosystem packages. |
| SparkDev | https://sparkdev.me/ | SnowBoard and customization ecosystem; verify the exact package and dependencies. |
| jjolano | https://ios.jjolano.me/ | Shadow and compatibility utilities; use only if needed and configure per-app. |
| BigBoss | https://apt.thebigboss.org/repofiles/cydia/ | Large legacy catalog. Many packages are rootful or old; do not assume compatibility. |
| CokePokes | https://cokepokes.github.io/ | Historical App Store++ source; check current availability and package metadata before use. |
| LumiRepo | https://repo.ya-ebal.mom/ | Themes and utilities; check individual package source, license and rootless support. |

## Free projects worth checking

- **Triggr** (Jond-ie): event/button/gesture actions; the repository advertises iOS 15+.
- **BegoneCIA** (Jond-ie): camera/microphone/location blocking toggle; a community release reports a Rootless port tested on iOS 15–16 on iPhone 7 and iPhone 8. This is adjacent-device evidence, not an iPhone 6s Plus test.
- **Scrub** (Jond-ie): photo metadata/GPS stripping; review its behavior and permissions before installing.
- **Crossfade** (Jond-ie): crossfade for local Music library tracks; not a system performance tweak.
- **SnowBoard** (SparkDev): theming engine; use sparingly because theme hooks can add overhead.
- **App Store++**: the video mentions it, but its current free availability and exact iOS 15.8.8 support are not confirmed here.

## Rules

1. Prefer the developer's own source over recompiled third-party mirrors.
2. Do not add RootHide-only (iphoneos-arm64e) or Rootful (iphoneos-arm) packages to the standard Dopamine Rootless setup.
3. Standard Rootless packages use iphoneos-arm64; Theos Rootless builds install under /var/jb.
4. Check dependencies, conflicts, minimum iOS version, architecture and license before installing.
5. Never install multiple jailbreak-detection bypass tweaks together.
6. Do not install a package merely because its name appears in the 2022 video.
