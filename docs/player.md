# Player

Client method extensions for controlling player movement physics.
All values are automatically adjusted for any active map modifiers.

All functions are called as methods on a player entity: `player sr\api\_player::functionName(...)`.

## Functions

- [setAntiElevator](#setantielevator)
- [setAntiLag](#setantilag)
- [setPlayerSpeed](#setplayerspeed)
- [setPlayerSpeedScale](#setplayerspeedscale)
- [setPlayerGravity](#setplayergravity)
- [setPlayerJumpHeight](#setplayerjumpheight)

---

### `<client> sr\api\_player::setAntiElevator(<state>)`

Enables or disables the anti-elevator system for this player.

| Parameter | Type | Description |
|-----------|------|-------------|
| `state` | bool | `true` to enable, `false` to disable |

```c
player sr\api\_player::setAntiElevator(true);
```

---

### `<client> sr\api\_player::setAntiLag(<state>)`

Enables or disables anti-lag for this player.

| Parameter | Type | Description |
|-----------|------|-------------|
| `state` | bool | `true` to enable, `false` to disable |

```c
player sr\api\_player::setAntiLag(true);
```

---

### `<client> sr\api\_player::setPlayerSpeed(<speed>)`

Sets the player's movement speed, adjusted for the current map modifiers.

| Parameter | Type | Description |
|-----------|------|-------------|
| `speed` | float | Target speed value |

```c
player sr\api\_player::setPlayerSpeed(300);
```

---

### `<client> sr\api\_player::setPlayerSpeedScale(<scale>)`

Sets the player's movement speed scale, adjusted for the current map modifiers.

| Parameter | Type | Description |
|-----------|------|-------------|
| `scale` | float | Target speed scale value |

```c
player sr\api\_player::setPlayerSpeedScale(1.2);
```

---

### `<client> sr\api\_player::setPlayerGravity(<gravity>)`

Sets the player's gravity, adjusted for the current map modifiers.

| Parameter | Type | Description |
|-----------|------|-------------|
| `gravity` | float | Target gravity value |

```c
player sr\api\_player::setPlayerGravity(500);
```

---

### `<client> sr\api\_player::setPlayerJumpHeight(<height>)`

Sets the player's jump height, adjusted for the current map modifiers.

| Parameter | Type | Description |
|-----------|------|-------------|
| `height` | float | Target jump height value |

```c
player sr\api\_player::setPlayerJumpHeight(70);
```