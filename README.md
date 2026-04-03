<div align="center">

<img src="https://github.com/Lord0Sanz/REWIND-BOX/blob/main/rewindboxlogo.png" alt="Rewind Box Logo" width="120" />

# Rewind Box

**A cassette player-styled music player built with Godot 4**

Scans your local music library and plays it back with walkman aesthetics —
spinning reels, an LCD display, and full theme support.

<br>

[![License: MIT](https://img.shields.io/badge/License-MIT-black?style=flat-square)](LICENSE)
[![Godot 4](https://img.shields.io/badge/Godot-4.x-blue?style=flat-square&logo=godotengine&logoColor=white)](https://godotengine.org)
[![Platform](https://img.shields.io/badge/%20%7C%20Platform%20%7C%20Windows%20%7C%20Linux%20%7C%20-555?style=flat-square)]()

</div>

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
| `Space` | Play / Pause |
| `Right Arrow` | Next track |
| `Left Arrow` | Previous track |
| `Up Arrow` | Volume up |
| `Down Arrow` | Volume down |
| `Enter` | Toggle loop |
| `Ctrl +` | Zoom in |
| `Ctrl -` | Zoom out |
| `Esc` | Quit |

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
  "body":            { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "logo":            { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "cassette_bg":     { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "cassette_mid":    { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "cassette_inner":  { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "ring_a":          { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "ring_b":          { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_play_bg":     { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_play_icon":   { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_loop_bg":     { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_loop_icon":   { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_next_bg":     { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_next_icon":   { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_prev_bg":     { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_prev_icon":   { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_vol_up_bg":   { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_vol_up_icon": { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_vol_down_bg": { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "btn_vol_down_icon":{ "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 },
  "ui_back_panel":   { "r": 0.00, "g": 0.00, "b": 0.00, "a": 1.0 },
  "ui_color":        { "r": 1.00, "g": 1.00, "b": 1.00, "a": 1.0 }
}
```

All color values are floats from `0.0` to `1.0`. Edit the file and restart the player to apply changes.

---

## Project Structure

```
RewindBox/
├── project.godot
├── main.gd
├── ui/
│   ├── body.png
│   ├── logo.png
│   ├── cassette_bg.png
│   ├── cassette_mid.png
│   ├── cassette_inner.png
│   ├── ring_a.png
│   ├── ring_b.png
│   ├── btn_play_bg.png        btn_play_icon.png
│   ├── btn_loop_bg.png        btn_loop_icon.png
│   ├── btn_next_bg.png        btn_next_icon.png
│   ├── btn_prev_bg.png        btn_prev_icon.png
│   ├── btn_vol_up_bg.png      btn_vol_up_icon.png
│   ├── btn_vol_down_bg.png    btn_vol_down_icon.png
│   └── theme.json
└── /...
```

---

## Reporting Issues

Before opening a new issue, please check [existing issues](https://github.com/Lord0Sanz/RewindBox/issues) to avoid duplicates.

When reporting a bug, include:

- OS version
- Steps to reproduce
- Screenshot or video if applicable

---

## License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for details.

You may use, modify, and distribute this software freely — including for commercial purposes — as long as the original copyright notice is retained.

---

## Credits

<div align="center">

| Role | Name |
|------|------|
| Developer | [![Shubhayu15](https://img.shields.io/badge/Shubhayu15-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/Shubhayu15) |
| Studio | [![PROJEKTSANSSTUDIOS](https://img.shields.io/badge/PROJEKTSANSSTUDIOS-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/Lord0Sanz) |
| Engine | [![Godot Engine](https://img.shields.io/badge/Godot_Engine-478CBF?style=flat-square&logo=godotengine&logoColor=white)](https://godotengine.org) |

</div>
