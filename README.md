# Celeste rice

A Hyprland + Quickshell setup themed after Celeste from Deadlock: a night-navy base, cobalt and electric-blue light streaks, and magenta/violet accents.

![wallpaper](wallpapers/celeste.jpg)

## Palette

| role | hex |
|---|---|
| base | `#0d0b1a` |
| surface | `#1a1530` |
| overlay | `#2a2350` |
| text | `#e6e1ff` |
| muted | `#8a84b0` |
| cobalt | `#4a6cf7` |
| electric | `#7fb2ff` |
| violet | `#9a6bff` |
| magenta | `#e05fd0` |
| coral | `#ec7a5c` |
| red | `#ff5c8a` |

In QML, every color comes from `quickshell/Theme.qml`.

## What's in it

- **hypr/**: Hyprland config. Tiling by default; floating windows get a magenta border, open centered, and can be moved and resized from the keyboard. Volume control, network/bluetooth settings, the calculator, file pickers and Picture-in-Picture (pinned) float on their own. Also includes a cobalt→violet→magenta border gradient, blur, violet-tinted shadows and snappy animations, plus hyprpaper
- **kitty/**: a 16-color terminal scheme built from the palette
- **quickshell/**
  - `Bar.qml`: workspace pills, clock, system tray, volume (scroll to change it, click to mute), battery (only on laptops) and a power button
  - `Launcher.qml`: an app launcher you can search
  - `Notifications.qml`: the notification daemon. Popups show in the top-right and close after 5s. Critical ones stay until you click them.
  - `PowerMenu.qml`: lock / logout / reboot / shutdown
  - `Cheatsheet.qml`: on-screen keybind list (`SUPER + /`). If you change binds in `hyprland.conf`, update its list too.

## Dependencies

`hyprland`, `hyprpaper`, `quickshell`, `kitty`, `pipewire` + `wireplumber`, `upower`, `ttf-jetbrains-mono-nerd`, and `hyprlock` for the Lock button.

Arch: `sudo pacman -S hyprland hyprpaper kitty pipewire wireplumber upower ttf-jetbrains-mono-nerd hyprlock`, then get `quickshell` from the AUR (`yay -S quickshell`).

Don't run another notification daemon (mako, dunst, swaync) alongside this one. Quickshell needs to own the notification service.

## Install

```sh
git clone https://github.com/ArielNya/dotfile ~/dotfile
cd ~/dotfile && ./install.sh
hyprctl reload   # or log out and back in
```

## Keybinds

| keys | action |
|---|---|
| `SUPER + Return` | kitty |
| `SUPER + Space` | launcher |
| `SUPER + Escape` | power menu |
| `SUPER + /` | keybind cheatsheet (Esc closes it) |
| `SUPER + Q` | close window |
| `SUPER + V` | float (and center) / tile |
| `SUPER + F` | fullscreen |
| `SUPER + C` | center floating window |
| `SUPER + SHIFT + P` | pin window to every workspace |
| `SUPER + ALT + arrows` | move floating window |
| `SUPER + CTRL + arrows` | resize window |
| `SUPER + S` / `SUPER + SHIFT + S` | show scratchpad / send window to it |
| `SUPER + 1-9` | go to workspace |
| `SUPER + SHIFT + 1-9` | move window to workspace |
| `SUPER + drag` | move (left) / resize (right) |

## If something looks off

- **No wallpaper**: `hyprpaper.conf` uses the block syntax from hyprpaper 0.8. On an older hyprpaper, switch to the commented `preload`/`wallpaper` lines in that file.
- **Bar isn't blurred, or `hyprctl reload` reports rule errors**: the `layerrule` and `windowrule` lines use the `<effect>, <match>` syntax from Hyprland 0.48–0.52. If your Hyprland uses the newer `match:` syntax, rewrite those lines.
- **QML errors**: run `qs` in a terminal to see them.
