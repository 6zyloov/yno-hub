# ynoez toolbox

A small Rootless command-line toolkit for Dopamine on iOS 15+.

Install from Sileo, then run `ynoez` in a terminal (NewTerm or SSH).

Commands:
- `ynoez status` — device, iOS, architecture and Rootless environment.
- `ynoez storage` — filesystem capacity and a short list of common data locations.
- `ynoez packages` — installed Debian package inventory.
- `ynoez health` — read-only checks for common jailbreak paths and crash-report counts.
- `ynoez help` — usage.

This first release is intentionally read-only. It does not delete caches, kill processes, disable daemons, edit preferences, contact a server, or claim to increase CPU/GPU performance. Review reports before deciding what to uninstall or change.
