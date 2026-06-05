# Tutorials

## Testing maps offline

To test a map offline, load any SR mod (e.g. SR Speedrun) and use `/devmap <mapname>` in the console to load your map directly without going through the server.

---

## Using the SR API

Maps interact with SR through the API modules. Depending on the game mode you're building for, import the relevant module and call its functions from your map script.

See the [Documentation](../README.md) for all available modules and functions.

---

## Developer mode

Enabling developer mode gives you in-game debug information such as entity names and other diagnostic overlays.

Use `/developer 1` in the console before loading a map.

---

## 3D entity visualization

For full 3D visualization of triggers and entities in-game, use the following launch configuration.

Create a shortcut to `iw3mp.exe` from your CoD4 folder, right-click it, open **Properties**, and set the **Target** field to:

```
"D:\Program Files (x86)\Activision\Cod4Mod\iw3mp.exe" +set fs_game "mods\sr_speedrun" +set logfile 2 +set monkeytoy 0 +set com_introplayed 1 +set developer 1 +set developer_script 1 +set thereisacow 1337 +set g_gametype "speedrun"
```

> Adjust the path and `fs_game` and `g_gametype` value to match your setup.

---

## Creating a trigger

![](https://i.imgur.com/ysXADDC.png)

Triggers are created in-game using bound keys. Set up your bindings in the multiplayer control menu before starting.

| Key | Action |
|-----|--------|
| Melee | Create a trigger |
| Use | Increase width |
| Grenade | Increase height |
| Smoke | Toggle collision |

Once saved, the generated script is written to `sr_dev/games_mp.log`.

---

## Getting a spawn position

![](https://i.imgur.com/tRgPvQI.png)

1. Stand upright at the desired spawn location.
2. Run `/centerview` and `/viewpos` in the console.
3. Open the full console with `Shift + console key` and copy the position line.

> Use `createSpawn` if the origin comes from an in-game position — it accounts for the 60-unit player height offset automatically.
> Use `createSpawnOrigin` if the origin comes from Radiant or `/debug_show_viewpos`.
