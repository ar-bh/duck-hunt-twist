# Duck Hunt Twist

A Duck Hunt–style game built in **Godot 4.6**.

## How to play

1. Open the project in Godot and press **F5**.
2. Click **Start** on the menu.
3. Watch the intro dog run in from the left, then jump behind the bushes.
4. Click falling birds to keep them in the air (+1 score).
5. Miss a bird and the dog pops up from the grass (−1 score).
6. Beat your session high score before you quit.

## Controls

- **Left click** — hit a bird (plays a whoosh sound)
- **Start** — begin the game
- **Quit** — exit

## Scoring

| Event | Points |
|-------|--------|
| Bird clicked | +1 |
| Bird caught by dog | −1 |

High score is tracked for the current session only.

## Project structure

```
game/
  main.tscn / main.gd   — menu, intro, spawning, score, popup dog
  bird.tscn / bird.gd   — falling birds, click detection, whoosh sfx
  dog.tscn              — popup dog sprite
assets/
  sounds/               — intro music, whoosh, etc.
  background.png        — game background
```

## Tuning

In `game/main.gd`:

- `DOG_SPEED` — intro dog walk speed (adjust to match intro audio)
- `DOG_START_X` / `DOG_TARGET_X` — where the intro dog starts and stops
- `SPAWN_MIN_INTERVAL` / `SPAWN_MAX_INTERVAL` — bird spawn rate

## Time tracking

This project includes the **Godot Super-Wakatime** addon for [Hackatime](https://hackatime.hackclub.com). Configure your API key in `~/.wakatime.cfg` with the Hack Club API URL.

## Requirements

- Godot 4.6+
- GL Compatibility renderer
