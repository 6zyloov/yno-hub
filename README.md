# yno hub — Anime Crusaders X

**Release 4.0.3 · 17 November 2026**

Standalone Lua hub for Anime Crusaders X, with a compact dark-blue interface and game-specific workflows. The visual direction takes inspiration from LixHub's compact control layout without copying its protected backend or artwork.

## Loader

Execute in Solara while Anime Crusaders X is open:

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
~~~

- [Raw Lua source](https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua)
- [Repository](https://github.com/6zyloov/yno-hub)
- [Usage guide](docs/usage.md)
- [Feature/validation matrix](docs/feature-matrix.md)
- [Changelog](CHANGELOG.md)

## Interface

Sidebar: **Overview, Game, Story, Quests, Macro, Unit Hunt, Rewards, Performance and Settings**. The Game page is arranged as two compact columns — Game and Wave Actions — with small switches and direct controls, rather than a large generic card dashboard.

The window supports drag, search, RightShift show/hide, minimize to a floating y button, and Unload. It uses the anime image at assets/yno-background.jpg when Solara filesystem/custom-asset functions are available.

## What the modules do

| Module | Function |
|---|---|
| Game | Optional UI automation for Vote Start, Skip Wave, Next after detected victory, and Replay after detected defeat. |
| Story | Runs the visible Play → Story selection flow for world, act/World Skip, difficulty and Matchmaking/Select Stage. |
| Quests | Opens All, Daily, Infinite, Story, Event or Guide and clicks Claim All when the game exposes it. |
| Macro | Opens the game's own Smart Macro, chooses This Stage/Loop/Routine, starts it, and exposes visible controls for native Macro options. |
| Unit Hunt | Enters the event, scans with Q, approaches visible Capture prompts and uses E. PERFECT assist is experimental. |
| Rewards | Login tracks, Hesia, YouTube Reward, King's Index and Blank Token shop helpers. |
| Performance | Local Low Effects, Hide Attack Effects, FPS cap and restore. |
| Settings | UI report, Solara self-check, preferences, Stop All and Unload. |

## Farming design

The game's built-in Smart Macro is the actual farming engine. It handles unit placement, upgrades, abilities and selling using the slots and placement configuration saved in Anime Crusaders X. The yno hub is an interface controller for that system; it does not replace the native strategy engine.

Configure Macro → Units → Slots and Macro → Units → Placement first. Then select **This Stage**, **Loop** or a configured **Routine** under Macro → Run.

Quest progress itself still comes from game activity. The hub can open categories and collect completed rewards; it does not fabricate kills, stages, currency or server inventory.

## Rewards and event facts

- **Twenty One:** Anniversary Login Day 1, while that track is available.
- **Phoenix:** complete all ten Guide Quests and claim Guide Quests Complete!.
- **Shadow (Atomic)** and **Lao (Heart):** 30 Blank Tokens each; these are not free.
- **Unit Hunt:** a separate capture collection, not the Tower Defense roster.

See the [usage guide](docs/usage.md) for exact steps and limitations.

## Runtime safety and compatibility

The script interacts through visible PlayerGui controls, ordinary Solara mouse/key input, normal Humanoid movement and enabled ProximityPrompts. It does not call private RemoteEvents/RemoteFunctions, edit server inventory/currency, or attempt anti-cheat bypass.

Solara's public API documentation: https://solara.gg/docs/

## Validation status

The repository runs:
1. Lua 5.4 syntax validation (luac5.4 -p);
2. static release/wiring checks for required modules, duplicate local functions, stale helpers and prohibited remote invocation patterns.

**No live Roblox/Solara match was executed in this development environment.** Passing syntax/static CI does not prove every in-game button label, menu hierarchy, or capture-bar variant matches the current client. Story, rewards and Unit Hunt flows therefore report missing controls rather than claiming success when a target is not found. The PERFECT helper remains experimental.
