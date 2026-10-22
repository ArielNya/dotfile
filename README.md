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

- **hypr/**: Hyprland config with a cobalt→violet→magenta border gradient, blur, violet-tinted shadows and snappy animations, plus hyprpaper
- **kitty/**: a 16-color terminal scheme built from the palette
- **quickshell/**
  - `Bar.qml`: workspace pills, clock, system tray, volume (scroll to change it, click to mute), battery (only on laptops) and a power button
  - `Launcher.qml`: an app launcher you can search
  - `Notifications.qml`: the notification daemon. Popups show in the top-right and close after 5s. Critical ones stay until you click them.
  - `PowerMenu.qml`: lock / logout / reboot / shutdown

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
| `SUPER + Q` | close window |
| `SUPER + V` / `F` | float / fullscreen |
| `SUPER + 1-9` | go to workspace |
| `SUPER + SHIFT + 1-9` | move window to workspace |
| `SUPER + drag` | move (left) / resize (right) |

## If something looks off

- **No wallpaper**: `hyprpaper.conf` uses the block syntax from hyprpaper 0.8. On an older hyprpaper, switch to the commented `preload`/`wallpaper` lines in that file.
- **Bar isn't blurred**: the `layerrule` lines use the classic syntax. If your Hyprland version changed its rule syntax, update those two lines.
- **QML errors**: run `qs` in a terminal to see them.
