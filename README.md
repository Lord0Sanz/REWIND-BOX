# Rewind Box

A cassette player-styled music player built with Godot 4. Scans your local music library and plays it back with walkman aesthetics — spinning reels, an LCD display, and full theme support.

---

## Features

- **Music Library** — Automatically scans your system `Music` folder for MP3, OGG, and WAV files
- **Cassette Animation** — Reels spin while music is playing
- **Custom Themes** — Full color customization via `theme.json`
- **Keyboard Shortcuts** — Space, arrow keys, Enter, and Ctrl +/- for all controls
- **Draggable Window** — Right-click and drag to reposition
- **Zoom** — Resize the player from 128px to 512px with Ctrl + / Ctrl -
- **Loop Mode** — Repeat the current track
- **LCD Display** — Scrolling song title with elapsed time and track info

---

## Controls

### Keyboard

| Key | Action |
|-----|--------|
| Space | Play / Pause |
| Right Arrow | Next track |
| Left Arrow | Previous track |
| Up Arrow | Volume up |
| Down Arrow | Volume down |
| Enter | Toggle loop |
| Ctrl + | Zoom in |
| Ctrl - | Zoom out |
| Esc | Quit |

### Mouse

| Action | Input |
|--------|-------|
| Play / Pause | Left cassette button |
| Next / Previous | Middle cassette buttons |
| Volume Up / Down | Right cassette buttons |
| Toggle Loop | Rightmost cassette button |
| Move Window | Right-click and drag |
| Quit | Esc or right-click menu |

---

## Custom Themes

Rewind Box supports full visual customization through a `theme.json` file.

### File Location

Place `theme.json` in the `ui/` folder alongside the executable:

```
RewindBox.exe
ui/
  theme.json
  body.png
  cassette_bg.png
  ...
```

### Format

```json
{
  "body":             { "r": 0.2, "g": 0.2, "b": 0.2, "a": 1.0 },
  "logo":             { "r": 1.0, "g": 0.8, "b": 0.2, "a": 1.0 },
  "cassette_bg":      { "r": 0.9, "g": 0.7, "b": 0.4, "a": 1.0 },
  "cassette_mid":     { "r": 0.6, "g": 0.4, "b": 0.2, "a": 1.0 },
  "cassette_inner":   { "r": 0.3, "g": 0.2, "b": 0.1, "a": 1.0 },
  "ring_a":           { "r": 0.8, "g": 0.6, "b": 0.3, "a": 1.0 },
  "ring_b":           { "r": 0.8, "g": 0.6, "b": 0.3, "a": 1.0 },
  "btn_play_bg":      { "r": 0.1, "g": 0.1, "b": 0.1, "a": 1.0 },
  "btn_play_icon":    { "r": 1.0, "g": 1.0, "b": 1.0, "a": 1.0 },
  "ui_back_panel":    { "r": 0.0, "g": 0.0, "b": 0.0, "a": 0.85 },
  "ui_color":         { "r": 0.0, "g": 1.0, "b": 0.0, "a": 1.0 }
}
```

All color values are floats from `0.0` to `1.0`. To apply a new theme, edit the file and restart the player.

---

## Project Structure

```
RewindBox/
  project.godot
  main.gd
  ui/
    body.png
    logo.png
    cassette_bg.png
    cassette_mid.png
    cassette_inner.png
    ring_a.png
    ring_b.png
    btn_play_bg.png
    btn_loop_bg.png
    btn_next_bg.png
    btn_prev_bg.png
    btn_vol_up_bg.png
    btn_vol_down_bg.png
    btn_play_icon.png
    btn_loop_icon.png
    btn_next_icon.png
    btn_prev_icon.png
    btn_vol_up_icon.png
    btn_vol_down_icon.png
    theme.json
  playlist/
```

---

## Building from Source

**Requirements:** Godot 4.x

```bash
git clone https://github.com/Lord0Sanz/RewindBox.git
cd RewindBox
godot project.godot
```

To build a binary, go to **Project > Export**, add a preset for your target platform, and export.

---

## Reporting Issues

Before opening a new issue, check the [existing issues](https://github.com/Lord0Sanz/RewindBox/issues) to avoid duplicates. When reporting a bug, include:

- OS version
- Godot version (if building from source)
- Steps to reproduce
- Screenshot or video if applicable

---

## License

MIT License. See [LICENSE](LICENSE) for details.

You may use, modify, and distribute this software freely, including for commercial purposes, as long as the original copyright notice is retained.

---

## Credits

| Role | Name |
|------|------|
| Developer | [Shubhayu15](https://github.com/Shubhayu15) |
| Studio | [PROJEKTSANSSTUDIOS](https://github.com/Lord0Sanz) |
| Engine | [Godot Engine](https://godotengine.org) (MIT licensed) |
