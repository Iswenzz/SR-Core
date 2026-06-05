# SR Core

![](https://i.imgur.com/1iYxwMa.jpg)

The foundation of the SR mod ecosystem — a powerful core framework for Call of Duty 4 providing the libraries, utilities, and systems that all SR mods are built on. SR-Core handles everything from low-level engine access and database connectivity to player movement, HUDs, game modes, and server administration.

## Event-Driven Architecture
At the heart of SR-Core is a callback-based event system. All modules are fully isolated and communicate exclusively through events, keeping the codebase decoupled and extensible.

## Administration
180+ built-in commands covering graphics, minigames, maps, players, and debugging. Servers can define admin roles and VIP tiers with granular permission control, and custom commands can be created and registered.

## Competitive Systems
Leaderboards, personal bests, ranking, match systems, and voting are all built in. Anti-cheat dedicated coverage for elevator exploits, lag switching, and low FPS abuse.

## Demo Playback
Every map and mode keeps a recording of its current world record, watchable directly in-game. Playback reproduces the full run including entities and chat messages, with slow motion and rewind controls to study any moment in detail.

## Movements
* 190 — Original CoD4 movements at 190 speed with 1.05 scale
* 210 — Original CoD4 movements at 210 speed with 1.12 scale
* Q3 — Quake 3 original movements
* Q3CPM — Quake 3 CPM movements
* Q3CPMW — Quake 3 CPM with rocket launcher and plasma gun
* CS — Counter-Strike bhop and surf physics
* Portal — Counter-Strike movements with a portal gun

## HUD
* CGAZ — A velocity optimisation display that shows the optimal strafe direction to maximise speed
* Crosshair — Switchable between CoD4 and Q3 crosshair styles
* Keys display — Q3-style key input visualiser
* Velocity meter — Displays current, average, and max velocity
* Ground time — Shows ground contact time, with options for raw time or average
* Spectator — Displays which players are currently spectating you
* FPS combo — Shows the FPS switch combo while you are playing
* Viewkick indicator — Toggleable damage feedback display
* Killcam — Playback of the kill sequence on death
* Hitmarker — Visual feedback when hitting a target

## FX
* Shaders — Post-processing shader support for custom visual effects
* Sprays — Project images or GIFs onto surfaces in the world
* Trails — A visual effect that follows the player through the map
* Trigger — Outlines the full boundary of a trigger volume in the world
* Music Sequences — Plays an animation with music, effects and shaders

## Minigames
* KillZone — A dedicated 1v1 arena where players go head to head
* Race — The lobby races through the map simultaneously
* Bomberman — A fun Bomberman-inspired minigame built inside CoD4

## Customization
Every player can tailor their look from top to bottom — weapons, characters, knives, knife skins, gloves, sprays, and trails are all individually customisable and visible to the whole server.

## Overlays
A scripted menu system allowing custom entries and actions to be registered and triggered in-game. Modules can hook into the overlay system without modifying core code.

## Documentation

| Module | Description |
|--------|-------------|
| [Tutorials](docs/tutorials.md) | Installation and tutorials on how to add maps using the SR API |
| [Map](docs/map.md) | Spawns, triggers, teleporters, and movement modifiers shared across all game modes |
| [Player](docs/player.md) | Player speed, gravity, jump height, and movement helpers |
| [Speedrun](docs/speedrun.md) | Ways, end triggers, and speedrun-specific map setup |
| [Deathrun](docs/deathrun.md) | Ways, rooms, teleporters, and deathrun-specific map setup |
| [BattleRoyale](docs/battleroyale.md) | Spawns, zones, plane paths, and entity definitions |
| [Q3](docs/q3.md) | Q3 weapons, perks, and section triggers |

## Contributors:
***Note:*** If you would like to contribute to this repository, feel free to send a pull request, and I will review your code. Also feel free to post about any problems that may arise in the issues section of the repository.
