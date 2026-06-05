# Speedrun

API for setting up speedrun maps.

## Map requirements

- Spawn
- Ways: `normal_0` through `normal_6`, `secret_0` through `secret_6`
- End trigger
- Strip out anything not relevant to speedrunning: music, messages, rooms, traps, moving platforms, teleporter delays

## Functions

- [createNormalWays](#createnormalways)
- [createSecretWays](#createsecretways)
- [createEndMap](#createendmap)
- [createEndMapFromTarget](#createendmapfromtarget)
- [createEndMapFromTargetname](#createendmapfromtargetname)
- [createWay](#createway)
- [createWayFromTarget](#createwayfromtarget)
- [createWayFromTargetname](#createwayfromtargetname)
- [createTeleporter](#createteleporter)
- [changeWay](#changeway)
- [finishWay](#finishway)

---

### `sr\api\_speedrun::createNormalWays(<token>)`

Registers the normal ways for this map. Way names are separated by `;`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `token` | string | Semicolon-separated list of way names |

```c
sr\api\_speedrun::createNormalWays("Normal Way;Alternate Route;");
```

---

### `sr\api\_speedrun::createSecretWays(<token>)`

Registers the secret ways for this map. Way names are separated by `;`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `token` | string | Semicolon-separated list of way names |

```c
sr\api\_speedrun::createSecretWays("Secret Way;");
```

---

### `sr\api\_speedrun::createEndMap(<origin>, <width>, <height>, <?way>)`

Creates an end-of-map trigger. If `way` is omitted, the trigger finishes `normal_0`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | vector | Trigger center position |
| `width` | float | Trigger width |
| `height` | float | Trigger height |
| `way` | string | *(optional)* Specific way to finish on trigger |

```c
sr\api\_speedrun::createEndMap((0, 0, 0), 150, 100);
sr\api\_speedrun::createEndMap((0, 0, 0), 150, 100, "normal_1");
```

---

### `sr\api\_speedrun::createEndMapFromTarget(<target>, <?way>)`

Creates an end-of-map trigger using an existing map entity's targetname. If `way` is omitted, the trigger finishes `normal_0`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | string | Target entity name |
| `way` | string | *(optional)* Specific way to finish on trigger |

```c
sr\api\_speedrun::createEndMapFromTarget("test");
sr\api\_speedrun::createEndMapFromTarget("test", "normal_1");
```

---

### `sr\api\_speedrun::createEndMapFromTargetname(<targetname>, <?way>)`

Creates end-of-map triggers for all entities matching the given targetname. If `way` is omitted, the trigger finishes `normal_0`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `targetname` | string | Targetname to match |
| `way` | string | *(optional)* Specific way to finish on trigger |

```c
sr\api\_speedrun::createEndMapFromTargetname("test");
sr\api\_speedrun::createEndMapFromTargetname("test", "normal_1");
```

---

### `sr\api\_speedrun::createWay(<triggerOrigin>, <width>, <height>, <color>, <way>)`

Creates a trigger that changes the player's active way when entered.

| Parameter | Type | Description |
|-----------|------|-------------|
| `triggerOrigin` | vector | Trigger center position |
| `width` | float | Trigger width |
| `height` | float | Trigger height |
| `color` | string | Trigger zone color |
| `way` | string | Way ID to switch to (e.g. `"normal_1"`, `"secret_0"`) |

```c
sr\api\_speedrun::createWay((0, 0, 0), 150, 100, "yellow", "normal_1");
```

---

### `sr\api\_speedrun::createWayFromTarget(<target>, <color>, <way>)`

Creates a way trigger using an existing map entity's target.

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | string | Target entity name |
| `color` | string | Trigger zone color |
| `way` | string | Way ID to switch to |

```c
sr\api\_speedrun::createWayFromTarget("way_trig", "yellow", "normal_1");
```

---

### `sr\api\_speedrun::createWayFromTargetname(<targetname>, <color>, <way>)`

Creates way triggers for all entities matching the given targetname.

| Parameter | Type | Description |
|-----------|------|-------------|
| `targetname` | string | Targetname to match |
| `color` | string | Trigger zone color |
| `way` | string | Way ID to switch to |

```c
sr\api\_speedrun::createWayFromTargetname("way_trig", "yellow", "normal_1");
```

---

### `sr\api\_speedrun::createTeleporter(<triggerOrigin>, <width>, <height>, <origin>, <angles>, <state>, <color>, <way>)`

Creates a teleporter that optionally changes the player's active way on arrival.

| Parameter | Type | Description |
|-----------|------|-------------|
| `triggerOrigin` | vector | Trigger center position |
| `width` | float | Trigger width |
| `height` | float | Trigger height |
| `origin` | vector | Destination position |
| `angles` | float | Destination facing angle (yaw) |
| `state` | string | `"freeze"` to freeze the player on arrival, `"none"` for no freeze |
| `color` | string | Trigger zone color |
| `way` | string | Way ID to switch to on arrival |

```c
sr\api\_speedrun::createTeleporter((0, 0, 0), 150, 100, (500, 0, 0), 90, "none", "blue", "secret_0");
```

---

### `<client> sr\api\_speedrun::changeWay(<way>)`

Sets the player's active way.

| Parameter | Type | Description |
|-----------|------|-------------|
| `way` | string | Way ID to switch to (e.g. `"secret_0"`) |

```c
player sr\api\_speedrun::changeWay("secret_0");
```

---

### `<client> sr\api\_speedrun::finishWay(<way>)`

Marks a way as finished for the player.

| Parameter | Type | Description |
|-----------|------|-------------|
| `way` | string | Way ID to finish |

```c
player sr\api\_speedrun::finishWay("secret_0");
```