# ynoez — iOS tweaks for Dopamine

Curated, free-first tweak catalog and development workspace for **iPhone 6s Plus (iPhone8,2), iOS 15.8.8, Dopamine Rootless, A9 / arm64**.

The goal is one trustworthy Sileo source named **yno ez** (ynoez), with performance and battery-conscious settings, reversible selective debloat, SpringBoard/Lock Screen/Control Center/icon/status-bar/keyboard customization, practical utilities, and original open-source ynoez packages where a safe feature is missing.

## Target profile

| Field | Target |
|---|---|
| Device | iPhone 6s Plus |
| Product identifier | iPhone8,2 |
| iOS | 15.8.8 |
| SoC | Apple A9 |
| CPU / Debian package architecture | arm64 / iphoneos-arm64 |
| Jailbreak | Dopamine |
| Package scheme | Rootless |
| Install prefix | /var/jb |
| Minimum deployment target for our builds | iOS 15.0 |

Dopamine's current upstream project lists arm64 support, and the device-specific compatibility dataset lists iPhone8,2 through iOS 15.8.8. This is jailbreak support, not proof that every tweak supports this exact device. Every package still needs its own compatibility review and device testing.

## Sileo source status

**The APT repository has now been built and its files pushed to the `gh-pages` branch.** It contains two real Rootless packages (`com.ynoez.audit` and `com.ynoez.noir`) plus `Packages`, compressed indexes and `Release`. The GitHub Pages site itself is not active yet (the public Pages URL currently returns 404), so the source is not ready to add in Sileo. Enable Pages in repository Settings → Pages, selecting branch `gh-pages` and folder `/(root)`, then verify the HTTPS `Release` URL before installing.

## Free tweaks and source repositories

Use SILEO-SOURCES.md for upstream repositories. Packages remain hosted by their original developers unless their licenses explicitly allow redistribution and the package has been checked. Free does not automatically mean safe, maintained or compatible.

The first candidate list includes free/rootless projects such as Jond-ie's repository. Items are marked as candidates until their current package metadata and iOS 15.8.8 behavior are checked. Do not install every tweak at once.

## Original theme: ynoez noir

A pure black (#000000) and white (#FFFFFF) SnowBoard theme is being built in `packages/ynoez-noir/`. It targets 28 common apps, uses 180×180 artwork for Plus-size devices, and ships as the Rootless package `com.ynoez.noir`. SnowBoard is a dependency. Its artwork is generated reproducibly during the APT build.

## Video catalog

The original RUIYA video is from February 2022. Its transcript includes AppData, App Store++, SnowBoard, Springtomize 5, Shadow and other names, but some names are unclear and the video is not evidence of current compatibility. See catalog.json. Unidentified names remain unidentified rather than guessed.

## Original SnowBoard theme

- [ynoez noir](packages/ynoez-noir/README.md) — 28 monochrome icons, absolute black background and white glyphs.

## Original packages

- [ynoez audit](packages/ynoez-audit/README.md) — read-only device diagnostics.
- [ynoez toolbox](packages/ynoez-toolbox/README.md) — status, storage, packages and jailbreak-health reports; read-only.

## Performance and debloat policy

A tweak that only shortens an animation is not automatically a faster phone. We will not claim extra FPS, RAM, battery life or charging speed without repeatable measurements on the target device.

- Prefer reversible settings and per-feature toggles.
- Never disable thermal protections, update services, security checks, cellular/Wi-Fi daemons or system processes blindly.
- Avoid RAM cleaners that constantly kill background processes.
- Avoid stacking multiple SpringBoard hooks, themes or jailbreak-detection bypasses.
- Keep an uninstall/recovery path and change one thing at a time.

See PERFORMANCE.md and DEVELOPMENT.md.

## Repository structure

- catalog.json — machine-readable package and compatibility catalog.
- SILEO-SOURCES.md — upstream free/community sources.
- PERFORMANCE.md — safe optimization/debloat policy and test method.
- DEVELOPMENT.md — how original ynoez packages are built and published.
- .github/workflows/ — catalog validation and APT publishing automation.

## License and redistribution

Original ynoez code will be open source. Third-party packages will not be mirrored unless the upstream license and author permit redistribution. Paid packages, cracked packages and binaries of unclear origin are excluded.
