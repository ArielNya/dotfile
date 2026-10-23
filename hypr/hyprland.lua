-- Celeste rice — Hyprland (Lua config, Hyprland 0.55+)
-- Palette: base #0d0b1a · overlay #2a2350 · cobalt #4a6cf7 · violet #9a6bff · magenta #e05fd0

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

local terminal = "kitty"
local mod = "SUPER"

-- pgrep keeps it to one copy of each
local function autostart()
    hl.exec_cmd("pgrep -x hyprpaper || hyprpaper")
    hl.exec_cmd("pgrep -x qs || pgrep -x quickshell || qs")
end

-- At login the config is read before the Wayland socket exists, so wait for start
hl.on("hyprland.start", autostart)
-- On hyprctl reload the compositor is already up: restart anything that died
if os.getenv("WAYLAND_DISPLAY") then autostart() end

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(4a6cf7ff)", "rgba(9a6bffff)", "rgba(e05fd0ff)" }, angle = 45 },
            inactive_border = "rgba(2a2350cc)",
        },
        layout = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding = 12,
        active_opacity = 1.0,
        inactive_opacity = 0.94,

        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            vibrancy = 0.2,
        },

        shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = "rgba(9a6bff44)",
            color_inactive = "rgba(0d0b1a88)",
        },
    },

    animations = { enabled = true },

    dwindle = {
        preserve_split = true,
    },

    input = {
        kb_layout = "br",
        follow_mouse = 1,
        scroll_method = "2fg",
        touchpad = { natural_scroll = true },
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        background_color = "rgb(0d0b1a)",
    },
})

-- 3-finger swipe switches workspaces
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.curve("snap", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "snap", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "snap" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "smooth" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "smooth", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "snap", style = "slidefade 15%" })

-- Blur Quickshell surfaces (bar, launcher, power menu, notifications, cheatsheet)
hl.layer_rule({ match = { namespace = "^quickshell.*$" }, blur = true, ignore_alpha = 0 })

-- Apps may not maximize themselves on open; it would cover the other tiles
hl.window_rule({ name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize" })

-- --- Floating ---
-- Floating windows get a magenta border so they read as lifted over the tiles
hl.window_rule({ match = { float = true }, border_color = "rgba(e05fd0ff)" })

-- Small utility windows and dialogs float, centered
local utilities = "^(pavucontrol|org.pulseaudio.pavucontrol|nm-connection-editor|blueman-manager)$"
hl.window_rule({ match = { class = utilities }, float = true, center = true, size = { 900, 600 } })
hl.window_rule({ match = { class = "^(org.gnome.Calculator|xdg-desktop-portal-gtk)$" }, float = true, center = true })
hl.window_rule({ match = { title = "^(Open File|Save As|Open Folder|File Upload)(.*)$" }, float = true, center = true })

-- Picture-in-Picture stays on every workspace
hl.window_rule({
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    size = { 480, 270 },
})

-- --- Binds ---
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + Space", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd("qs ipc call power toggle"))
hl.bind(mod .. " + slash", hl.dsp.exec_cmd("qs ipc call cheatsheet toggle"))
hl.bind(mod .. " + V", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.center())
end)
hl.bind(mod .. " + C", hl.dsp.window.center())
hl.bind(mod .. " + SHIFT + P", hl.dsp.window.pin())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))

local directions = { left = { -40, 0 }, right = { 40, 0 }, up = { 0, -40 }, down = { 0, 40 } }
for key, d in pairs(directions) do
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = key }))
    -- Floating: move / resize with the keyboard (hold to repeat)
    hl.bind(mod .. " + ALT + " .. key, hl.dsp.window.move({ x = d[1], y = d[2], relative = true }), { repeating = true })
    hl.bind(mod .. " + CTRL + " .. key, hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }), { repeating = true })
end

-- Scratchpad: a hidden workspace that pops over everything
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

for i = 1, 9 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
