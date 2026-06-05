# Map

Shared map utilities for all game modes.
Handles spawns, triggers, teleporters, death zones, and movement modifier helpers.

## Movement modifiers

Global movement settings are applied via dvars in your map script:

```c
setDvar("g_speed", 190);
setDvar("dr_jumpers_speed", 1.05);
setDvar("g_gravity", 800);
setDvar("jump_height", 39);
```

Use the `getSpeed`, `getMoveSpeedScale`, `getGravity`, and `getJumpHeight` helpers to convert values correctly when a modifier is active.

## Functions

- [createEndMap](#createendmap)
- [createTeleporter](#createteleporter)
- [createDeath](#createdeath)
- [createSpawn](#createspawn)
- [createSpawnOrigin](#createspawnorigin)
- [createTriggerFx](#createtriggerfx)
- [getSpeed](#getspeed)
- [getMoveSpeedScale](#getmovespeedscale)
- [getGravity](#getgravity)
- [getJumpHeight](#getjumpheight)
- [swapTargetname](#swaptargetname)
- [deleteEntities](#deleteentities)
- [noFallDamage](#nofalldamage)
- [cj](#cj)
- [slide](#slide)
- [disableXP](#disablexp)

---

### `sr\api\_map::createEndMap(<origin>, <width>, <height>)`

Creates an end-of-map trigger.

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | vector | Trigger center position |
| `width` | float | Trigger width |
| `height` | float | Trigger height |

```c
sr\api\_map::createEndMap((0, 0, 0), 150, 100);
```

---

### `sr\api\_map::createTeleporter(<triggerOrigin>, <width>, <height>, <origin>, <angles>, <state>, <color>)`

Creates a teleporter with a colored trigger zone.

| Parameter | Type | Description |
|-----------|------|-------------|
| `triggerOrigin` | vector | Trigger center position |
| `width` | float | Trigger width |
| `height` | float | Trigger height |
| `origin` | vector | Destination position |
| `angles` | float | Destination facing angle (yaw) |
| `state` | string | `"freeze"` to freeze the player on arrival, `"none"` for no freeze |
| `color` | string | Trigger zone color |

```c
sr\api\_map::createTeleporter((0, 0, 0), 150, 100, (500, 0, 0), 90, "none", "blue");
```

---

### `sr\api\_map::createDeath(<triggerOrigin>, <width>, <height>)`

Creates a trigger that kills the player on contact.

| Parameter | Type | Description |
|-----------|------|-------------|
| `triggerOrigin` | vector | Trigger center position |
| `width` | float | Trigger width |
| `height` | float | Trigger height |

```c
sr\api\_map::createDeath((0, 0, 0), 150, 100);
```

---

### `sr\api\_map::createSpawn(<origin>, <angles>)`

Creates a spawn point. The origin should include the 60-unit player height offset — use `/viewpos` while standing in-game to get this value.

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | vector | Spawn position (with player height offset) |
| `angles` | float | Spawn facing angle (yaw) |

```c
sr\api\_map::createSpawn((0, 0, 0), 90);
```

---

### `sr\api\_map::createSpawnOrigin(<origin>, <angles>)`

Creates a spawn point using a raw origin without the player height offset. Use this when the origin comes from Radiant or `/debug_show_viewpos`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | vector | Spawn position (without player height offset) |
| `angles` | float | Spawn facing angle (yaw) |

```c
sr\api\_map::createSpawnOrigin((0, 0, 0), 90);
```

---

### `sr\api\_map::createTriggerFx(<trigger>, <fx>)`

Attaches a visual effect to an existing trigger.

| Parameter | Type | Description |
|-----------|------|-------------|
| `trigger` | entity | The trigger entity |
| `fx` | string | Effect color or name |

```c
sr\api\_map::createTriggerFx(trigger, "blue");
```

---

### `sr\api\_map::getSpeed(<speed>)`

Converts a speed value to account for the map's active movement modifier.

| Parameter | Type | Description |
|-----------|------|-------------|
| `speed` | float | Base speed value |

```c
adjusted = sr\api\_map::getSpeed(190);
```

---

### `sr\api\_map::getMoveSpeedScale(<scale>)`

Converts a speed scale value to account for the map's active movement modifier.

| Parameter | Type | Description |
|-----------|------|-------------|
| `scale` | float | Base speed scale value |

```c
adjusted = sr\api\_map::getMoveSpeedScale(1.05);
```

---

### `sr\api\_map::getGravity(<gravity>)`

Converts a gravity value to account for the map's active movement modifier.

| Parameter | Type | Description |
|-----------|------|-------------|
| `gravity` | float | Base gravity value |

```c
adjusted = sr\api\_map::getGravity(800);
```

---

### `sr\api\_map::getJumpHeight(<height>)`

Converts a jump height value to account for the map's active movement modifier.

| Parameter | Type | Description |
|-----------|------|-------------|
| `height` | float | Base jump height value |

```c
adjusted = sr\api\_map::getJumpHeight(39);
```

---

### `sr\api\_map::swapTargetname(<from>, <to>)`

Renames all entities with targetname `from` to `to`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `from` | string | Current targetname |
| `to` | string | New targetname |

```c
sr\api\_map::swapTargetname("old_name", "new_name");
```

---

### `sr\api\_map::deleteEntities(<value>, <key>)`

Deletes all entities with the given key value.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | string | Value to match against |
| `key` | string | Key to match against |

```c
sr\api\_map::deleteEntities("platforms", "targetname");
```

---

### `sr\api\_map::noFallDamage()`

Disables fall damage for this map.

```c
sr\api\_map::noFallDamage();
```

---

### `sr\api\_map::cj()`

Flags this map as a CJ (counter-jump) map.

```c
sr\api\_map::cj();
```

---

### `sr\api\_map::slide(<speed>)`

Flags this map as a slide map with the given slide speed.

| Parameter | Type | Description |
|-----------|------|-------------|
| `speed` | float | Slide speed |

```c
sr\api\_map::slide(500);
```

---

### `sr\api\_map::disableXP()`

Disables XP gain on this map.

```c
sr\api\_map::disableXP();
```