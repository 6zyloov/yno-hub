# ynoez audit 0.1.0

A first original ynoez package: a read-only diagnostics command for jailbroken iPhones.

## What it reports

- hardware identifier and CPU architecture;
- iOS version and kernel version;
- presence of the Rootless prefix;
- available storage at the jailbreak prefix (or root filesystem fallback);
- installed Debian package count.

## What it does not do

It does not delete files, kill processes, disable daemons, change preferences, access private user data, or make network requests. It is a diagnostic baseline for later performance and debloat work, not a performance booster.

## Run

After installation from Sileo, open a terminal app and run:

    ynoez-audit

Target package architecture: iphoneos-arm64 (Dopamine Rootless).
