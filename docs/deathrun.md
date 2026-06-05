# Deathrun

API for setting up deathrun maps.

## Map requirements

- Spawn
- End trigger
- Room order

## Functions

- [createNormalWays](#createnormalways)
- [createSecretWays](#createsecretways)
- [createEndMap](#createendmap)
- [createWay](#createway)
- [createTeleporter](#createteleporter)
- [order](#order)
- [changeWay](#changeway)
- [finishWay](#finishway)

---

### `sr\api\_deathrun::createNormalWays(<token>)`

Registers the normal ways for this map. Way names are separated by `;`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `token` | string | Semicolon-separated list of way names |

```c
sr\api\_deathrun::createNormalWays("Normal Way;");
```

---

### `sr\api\_deathrun::createSecretWays(<token>)`

Registers the secret ways for this map. Way names are separated by `;`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `token` | string | Semicolon-separated list of way names |

```c
sr\api\_deathrun::createSecretWays("Secret Way;");
```

---

### `sr\api\_deathrun::createEndMap(<origin>, <width>, <height>, <?way>)`

Creates an end-of-map trigger. If `way` is omitted, the trigger finishes any active way.

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | vector | Trigger center position |
| `width` | float | Trigger width |
| `height` | float | Trigger height |
| `way` | string | *(optional)* Specific way to finish on trigger |

```c
sr\api\_deathrun::createEndMap((0, 0, 0), 150, 100);
```

---

### `sr\api\_deathrun::createWay(<triggerOrigin>, <width>, <height>, <color>, <way>)`

Creates a trigger that changes the player's active way when entered.

| Parameter | Type | Description |
|-----------|------|-------------|
| `triggerOrigin` | vector | Trigger center position |
| `width` | float | Trigger width |
| `height` | float | Trigger height |
| `color` | string | Trigger zone color |
| `way` | string | Way ID to switch to |

```c
sr\api\_deathrun::createWay((0, 0, 0), 150, 100, "yellow", "normal_1");
```

---

### `sr\api\_deathrun::createTeleporter(<triggerOrigin>, <width>, <height>, <origin>, <angles>, <state>, <color>, <way>)`

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
sr\api\_deathrun::createTeleporter((0, 0, 0), 150, 100, (500, 0, 0), 90, "none", "blue", "secret_0");
```

---

### `<client> sr\api\_deathrun::order()`

Returns `true` if the player is allowed to enter the end room based on their current room progress. Use this to gate access to the final room.

```c
while (true)
{
    trig waittill("trigger", player);

    if (!player sr\api\_deathrun::order())
        continue;

    iPrintLnBold(player.name + "^4 has entered the ^2Knife Room");
    player finalRoom("knife_mp", 100);
    level.activ finalRoom("knife_mp", 100);
}
```

---

### `<client> sr\api\_deathrun::changeWay(<way>)`

Sets the player's active way.

| Parameter | Type | Description |
|-----------|------|-------------|
| `way` | string | Way ID to switch to |

```c
player sr\api\_deathrun::changeWay("secret_0");
```

---

### `<client> sr\api\_deathrun::finishWay(<way>)`

Marks a way as finished for the player.

| Parameter | Type | Description |
|-----------|------|-------------|
| `way` | string | Way ID to finish |

```c
player sr\api\_deathrun::finishWay("secret_0");
```