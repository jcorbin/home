-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- ── Wayland ──────────────────────────────────────────────────────────────
-- Force the native Wayland backend (talks wl_data_device directly), not
-- XWayland. This is the whole point of the ghostty→wezterm trial: a clipboard
-- that isn't behind GTK4's stale local cache.
config.enable_wayland = true

-- ── Font ─────────────────────────────────────────────────────────────────
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 12

-- ── Window / chrome ──────────────────────────────────────────────────────
-- niri is a tiling WM and owns the frame; draw no titlebar or CSD buttons,
-- but still allow compositor resize. (ghostty shows no chrome here either.)
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'NeverPrompt'

config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- Matches ghostty's background-opacity 0.85. Note: wezterm has no Wayland
-- background-blur knob (only macos_window_background_blur), so ghostty's
-- background-blur-radius has no equivalent here — transparency only.
config.window_background_opacity = 0.85

config.scrollback_lines = 10000

-- ── Tab bar ──────────────────────────────────────────────────────────────
-- We never spawn in-app tabs (see keys below), so with this the bar never
-- appears — matching ghostty's chrome-free single pane.
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- ── Keybinds: let the window manager own window/tab/split/pane management ──
-- Mirror of the ghostty config's philosophy. We drop ALL of wezterm's default
-- bindings (which include tab/pane/window creation and navigation), then add
-- back only the genuinely terminal-level keys — copy/paste, search, copy-mode,
-- font zoom, and scrollback.
config.disable_default_key_bindings = true
config.keys = {
  { key = 'c',        mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v',        mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  { key = 'f',        mods = 'CTRL|SHIFT', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'x',        mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },

  -- font zoom (matches the neovide C-= / C-- / C-0 muscle memory)
  { key = '=',        mods = 'CTRL',       action = act.IncreaseFontSize },
  { key = '-',        mods = 'CTRL',       action = act.DecreaseFontSize },
  { key = '0',        mods = 'CTRL',       action = act.ResetFontSize },

  -- scrollback
  { key = 'PageUp',   mods = 'SHIFT',      action = act.ScrollByPage(-1) },
  { key = 'PageDown', mods = 'SHIFT',      action = act.ScrollByPage(1) },
}

-- ── Shell ────────────────────────────────────────────────────────────────
-- Do NOT spawn a login shell.
--
-- The Wayland session (uwsm/compositor) already owns login/session/env setup;
-- a terminal emulator should run *inside* that scope,
-- not open a fresh login scope beneath it.
--
-- wezterm's default prefixes argv[0] with '-' to force a login shell,
-- which re-runs ~/.{zprofile,zlogin} which may re-trigger session launch.
--
-- Naming the program explicitly launches it as a plain interactive shell;
-- argv[0] = 'zsh', no leading dash, matching ghostty/alacritty behavior and
-- operator expectations.
config.default_prog = { os.getenv 'SHELL' or 'zsh' }

-- ── Launcher menu ────────────────────────────────────────────────────────
-- neovim? more like neoshell
-- config.default_prog = { '/usr/bin/nvim' }

config.launch_menu = {
  { args = { 'htop' } },
  { label = 'NeoVim',  args = { 'nvim' } },
  { label = 'Zsh',     args = { 'zsh' } },
  { label = 'IPython', args = { 'ipython' } },
  { label = 'Bash',    args = { 'bash' } },
}

-- ── Colors ───────────────────────────────────────────────────────────────
-- noctalia-managed: its "wezterm" template regenerates colors/Noctalia.toml
-- from the active scheme (Carbonfox), so wezterm tracks scheme changes the way
-- ghostty did via `theme = noctalia`. Don't add a config.colors block — it
-- would override this and break the sync.
config.color_scheme = 'Noctalia'

return config
