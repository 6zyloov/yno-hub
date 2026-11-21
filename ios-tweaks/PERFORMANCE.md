# ynoez — performance, battery and debloat

Target: iPhone 6s Plus · iOS 15.8.8 · Dopamine Rootless · A9.

## What we will optimize

1. **Responsiveness:** reduce unnecessary visual effects only where the change is reversible and measurable.
2. **Battery:** identify actual background drain; avoid always-on hooks and polling daemons.
3. **Storage:** remove user-selected caches and leftovers only when the owner can see what will be deleted.
4. **SpringBoard stability:** avoid duplicate hooks, overlapping control-center replacements and excessive themes.
5. **App behavior:** optional per-app controls instead of system-wide changes wherever possible.

## Safe baseline before tweaks

- Record battery usage in Settings → Battery over a representative day.
- Keep adequate free storage.
- Check Battery Health and peak-performance status; software tweaks cannot repair a worn battery.
- Remove unused tweaks and duplicate injection/bypass packages.
- Use Settings → Accessibility → Motion → Reduce Motion if preferred.
- Use Settings → Accessibility → Display & Text Size → Reduce Transparency if preferred.
- Change one tweak at a time; test respring, reboot/re-jailbreak, calls, camera, Wi-Fi, cellular, notifications and standby drain.

## Debloat: allowed vs. forbidden

**Potentially acceptable:** user-visible removal of unused app caches, optional visual effects, unused tweak add-ons and explicitly selected launch agents whose purpose and dependencies are known.

**Not acceptable as an automatic preset:** deleting Apple system apps, disabling unknown launch daemons, modifying thermal limits, killing security/update/network services, deleting language/system frameworks, or removing packages required by Dopamine/ElleKit/Sileo.

Every ynoez debloat action must show the exact target, explain the consequence, provide a backup/restore route and default to no destructive action.

## Avoid fake optimizers

- RAM cleaners and constant process killers can make iOS relaunch apps more often.
- CPU/GPU overclocking or thermal-protection bypasses risk instability and hardware damage.
- Faster animation settings change perceived speed, not processor performance.
- Charging tweaks cannot safely force unsupported charging power.
- Resolution/DPI values copied from another model can break the interface.

## Measurement protocol for original ynoez packages

Before/after on the same device and conditions:
- idle battery drop over a fixed interval;
- battery usage by app over a comparable period;
- SpringBoard crash/Safe Mode count;
- respring and cold-launch time;
- free storage before/after;
- reproducibility across at least three runs.

No performance claim is published without a recorded test method and result. A package that has not been tested on iPhone8,2 / iOS 15.8.8 is labelled **not device-tested**.
