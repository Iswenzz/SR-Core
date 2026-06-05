# BattleRoyale

API for setting up battle royale maps.

## Map requirements

- Spawn
- Zones
- Plane path, drop origin, and drop trigger
- Entities: weapons, ammo, grenades, specials

## RNG values

The `rng` parameter controls item rarity. Higher values are rarer.

| Constant | Value |
|----------|-------|
| `level.RNG_SMALL` | low |
| `level.RNG_NORMAL` | medium |
| (integer) | `1` (common) to `10` (rare) |

## Functions

- [createSpawn](#createspawn)
- [createLobbyBlocker](#createlobbyblocker)
- [createPlanePath](#createplanepath)
- [createPlaneDrop](#createplanedrop)
- [createPlaneDropTrigger](#createplanedroptrigger)
- [createPlaneDuration](#createplaneduration)
- [createZone](#createzone)
- [createZoneLevels](#createzonelevels)
- [createEntity](#createentity)
- [createEntities](#createentities)
- [createAmmo](#createammo)
- [createWeapon](#createweapon)
- [createSpecial](#createspecial)
- [createGrenade](#creategrenade)
- [removeAllMapTriggers](#removealltriggers)
- [removeAllSpawns](#removeallspawns)

---

### `sr\api\_battleroyale::createSpawn(<origin>, <angle>)`

Creates a spawn point in the lobby area.

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | vector | Spawn position |
| `angle` | float | Spawn facing angle (yaw) |

```c
sr\api\_battleroyale::createSpawn((0, 0, 0), 90);
```

---

### `sr\api\_battleroyale::createLobbyBlocker(<origin>, <width>, <height>)`

Creates a blocker in the lobby that is automatically removed when the game starts.

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | vector | Blocker position |
| `width` | float | Blocker width |
| `height` | float | Blocker height |

```c
sr\api\_battleroyale::createLobbyBlocker((100, 200, 300), 200, 300);
```

---

### `sr\api\_battleroyale::createPlanePath(<start>, <end>, <angle>)`

Adds a path to the pool of plane routes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `start` | vector | Path start position |
| `end` | vector | Path end position |
| `angle` | float | Plane facing angle (yaw) |

```c
sr\api\_battleroyale::createPlanePath((-1000, 0, 1000), (1000, 0, 1000), 90);
```

---

### `sr\api\_battleroyale::createPlaneDrop(<origin>)`

Sets the default drop origin used when a player is AFK or gets stuck.

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | vector | Default drop position |

```c
sr\api\_battleroyale::createPlaneDrop((0, 0, 1000));
```

---

### `sr\api\_battleroyale::createPlaneDropTrigger(<origin>, <radius>)`

Creates the trigger area where players can press F to drop from the plane.

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | vector | Trigger center position |
| `radius` | float | Trigger radius |

```c
sr\api\_battleroyale::createPlaneDropTrigger((0, 0, 1000), 5000);
```

---

### `sr\api\_battleroyale::createPlaneDuration(<seconds>)`

Sets how long the plane takes to travel its path.

| Parameter | Type | Description |
|-----------|------|-------------|
| `seconds` | float | Duration in seconds |

```c
sr\api\_battleroyale::createPlaneDuration(60);
```

---

### `sr\api\_battleroyale::createZone(<origin>)`

Adds a position to the pool of possible final zones.

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | vector | Zone center position |

```c
sr\api\_battleroyale::createZone((0, 0, 0));
```

---

### `sr\api\_battleroyale::createZoneLevels(<levels>)`

Defines the zone level count for this map, which controls how many shrink phases occur.

| Parameter | Type | Description |
|-----------|------|-------------|
| `levels` | int | Number of zone levels |

```c
sr\api\_battleroyale::createZoneLevels(3);
```

---

### `sr\api\_battleroyale::createEntity(<id>, <origin>)`

Spawns a registered battle royale entity at the given position.

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Entity ID (must be registered via `createWeapon`, `createAmmo`, etc.) |
| `origin` | vector | Spawn position |

```c
sr\api\_battleroyale::createEntity("m16", (0, 0, 0));
```

---

### `sr\api\_battleroyale::createEntities(<entities>)`

Spawns registered battle royale entities at the given positions.

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Entity ID (must be registered via `createWeapon`, `createAmmo`, etc.) |
| `origins` | array | Spawn positions |

```c
sr\api\_battleroyale::createEntities("m16", origins);
```

---

### `sr\api\_battleroyale::createAmmo(<id>, <model>, <sound>, <icon>, <count>, <rng>)`

Registers an ammo entity that can be spawned with `createEntity`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Unique ammo ID |
| `model` | string | Ammo model name |
| `sound` | string | Pickup sound alias |
| `icon` | string | HUD icon material |
| `count` | int | Clip size |
| `rng` | int | Rarity from `1` (common) to `10` (rare) |

```c
sr\api\_battleroyale::createAmmo("5_45", "sr_5_45", "amunition", "hud_icon_mag_5_56", 30, level.RNG_NORMAL);
```

---

### `sr\api\_battleroyale::createWeapon(<id>, <mag>, <sound>, <icon>, <weapon>, <rng>)`

Registers a weapon entity that can be spawned with `createEntity`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Unique weapon ID |
| `mag` | string | Magazine/ammo ID |
| `sound` | string | Pickup sound alias |
| `icon` | string | HUD icon material |
| `weapon` | string | Weapon item ID |
| `rng` | int | Rarity from `1` (common) to `10` (rare) |

```c
sr\api\_battleroyale::createWeapon("m16", "5_45", "weap_raise_plr", "hud_icon_m16a4", "m16_mp", level.RNG_NORMAL);
```

---

### `sr\api\_battleroyale::createSpecial(<id>, <model>, <sound>, <icon>, <rng>)`

Registers a special item entity (e.g. consumables) that can be spawned with `createEntity`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Unique special ID |
| `model` | string | Item model name |
| `sound` | string | Pickup sound alias |
| `icon` | string | HUD icon material |
| `rng` | int | Rarity from `1` (common) to `10` (rare) |

```c
sr\api\_battleroyale::createSpecial("bandage", "sr_bandage", "health_pickup_large", "hud_icon_band", level.RNG_NORMAL);
```

---

### `sr\api\_battleroyale::createGrenade(<id>, <sound>, <icon>, <weapon>, <rng>)`

Registers a grenade entity that can be spawned with `createEntity`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Unique grenade ID |
| `sound` | string | Pickup sound alias |
| `icon` | string | HUD icon material |
| `weapon` | string | Weapon item ID |
| `rng` | int | Rarity from `1` (common) to `10` (rare) |

```c
sr\api\_battleroyale::createGrenade("frag_grenade", "grenade_pickup", "hud_icon_grenade", "frag_grenade_mp", level.RNG_SMALL);
```

---

### `sr\api\_battleroyale::removeAllMapTriggers()`

Removes all triggers on the map. Use on stock maps to prevent trigger conflicts.

```c
thread sr\api\_battleroyale::removeAllMapTriggers();
```

---

### `sr\api\_battleroyale::removeAllSpawns()`

Removes all stock spawns. Use on stock maps to take full control of the lobby area.

```c
thread sr\api\_battleroyale::removeAllSpawns();
```