# ynoez package development

## Build target

- Device: iPhone8,2 (iPhone 6s Plus)
- iOS: 15.8.8
- Jailbreak: Dopamine Rootless
- Theos package scheme: rootless
- Package architecture: iphoneos-arm64
- Install prefix: /var/jb
- Minimum target: iOS 15.0

Theos documentation: https://theos.dev/docs/rootless

## Package quality gate

Every original ynoez tweak must include:
1. source code and a clear open-source license;
2. package control metadata with a unique com.ynoez.* identifier;
3. declared dependencies and conflicts;
4. a reversible uninstall path;
5. a documented feature and limitations;
6. static build checks;
7. a device test record for iPhone8,2 / iOS 15.8.8 before being labelled verified.

No package may disable thermal safeguards, remove unknown launch daemons, alter security/update services, or delete system components automatically.

## Planned original packages

| Package ID | Name | Purpose | Status |
|---|---|---|---|
| com.ynoez.audit | ynoez audit | Read-only device/storage/package report | Source committed; CI build pending |
| com.ynoez.noir | ynoez noir | Pure black/white 16-icon SnowBoard theme | Source committed; CI build pending |
| com.ynoez.core | ynoez core | Shared preferences and diagnostics | Planned |
| com.ynoez.performance | ynoez performance | Reversible responsiveness controls | Planned |
| com.ynoez.debloat | ynoez debloat | Opt-in cleanup with backup/restore | Planned |
| com.ynoez.customize | ynoez customize | Lightweight SpringBoard options | Planned |

These are project plans, not existing installable packages. No .deb is published yet.

## ynoez noir theme

The theme source lives in `packages/ynoez-noir/`. Its Python/Pillow generator writes 16 180×180 PNG app icons into the SnowBoard `.theme/IconBundles` directory. The package metadata declares `com.spark.snowboard` as a dependency. It installs under the Rootless theme path in `/var/jb/Library/Themes`.

The theme is appearance-only. It does not claim performance or battery gains. App bundle IDs can vary; unsupported icons remain unchanged.

## APT repository publishing

1. Build and review a package. The workflow builds both `com.ynoez.audit` and `com.ynoez.noir` from source.
2. Put the authorized .deb under ios-tweaks/pool/.
3. Run the GitHub Actions workflow "Publish ynoez APT repository".
4. The workflow generates Packages, Packages.gz and Release and publishes the repository files to the gh-pages branch.
5. In GitHub repository Settings → Pages, select "Deploy from a branch", branch gh-pages, folder /(root).
6. Verify the Release and Packages URLs load over HTTPS before adding the source in Sileo.

The workflow intentionally fails when no .deb exists. This prevents publishing a fake/empty repository. It does not build third-party packages or mirror third-party repositories.
