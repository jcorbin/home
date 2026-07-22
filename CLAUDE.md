# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This git repository **is** the user's live `$HOME` (`/home/jcorbin`). It is not a
"dotfiles repo" checked out somewhere separate and symlinked — files are tracked in
place, so **any edit here changes the running environment immediately**. There is no
build step and no test suite; "installing" a change means editing the real file.

Tracking strategy (`.gitignore`): **ignore everything (`/*`), then whitelist** the
handful of paths worth tracking. Consequences:

- A newly created file is invisible to git until its path is explicitly whitelisted
  in `.gitignore`. When adding config for a new tool, add the `!`-rule first, then
  `git status` will show it.
- `git add -A` / `git add .` are safe *because* of the ignore-all default, but still
  prefer `git add <path>` or the `ap` alias (`add -p`).
- Only ~400 files are tracked out of a home directory containing far more.

## Branch model (important)

Branches form a **rebase-based stack**, lowest (most public) to highest (most local):

```
main            public, shared to GitHub (remote `github`, also `nas`)
 └─ prime       personal, cross-machine (not for GitHub)
     └─ local   general local-machine layer
         └─ local.<host>   host-specific (e.g. local.raidho for machine "raidho")
             └─ actual     the branch actually checked out in $HOME
wip             throwaway / experiments, rebased or discarded freely
```

`actual` currently points at the same commit as `local.<host>` for this machine
(`local.raidho`). Commits are placed at the layer matching their audience and then
the stack is **rebased** upward — `prime` onto `main`, `local.<host>` onto `local`,
etc. This keeps machine- and privacy-specific changes from leaking down to `main`/GitHub.

**Where to commit:** default to the currently checked-out branch (`actual`). Only a
change that is genuinely public and machine-agnostic belongs on `main`.

### Commit message conventions

- `LOCAL.<host>: ...` — host-specific change that must never rebase below `local.<host>`
  (e.g. `LOCAL.raidho: kanshi: add main eDP-1 config`).
- `WIP ...` — work in progress, expected to be squashed/reworded/dropped on rebase.
- `TODO <area>: ...` — a placeholder/reminder commit (e.g. `TODO nvim: pipenv`).
- Otherwise use a `topic: summary` form (`niri: nudge more toolkits`).

Rebase is the workflow: `rebase.autosquash=true`, `rebase.updaterefs=true`,
`branch.autosetuprebase=always`. Fixups are expected — use the `fit`
(`commit --fixup`) and `sit` (`commit --squash`) aliases, then rebase.

## Git config is central

`.gitconfig` is the most heavily-used part of this repo. Before running raw git,
check for an alias — many verbs are two letters. Highlights:

- Logs: `lg`/`lgg`/`lgf` (author format), `lb`/`lbg` (brief), `lob` (brief + body).
  Custom pretty formats: `brief`, `briefbody`, `author`, `authorbody`.
- Commit: `ci` `cia` `ciam` `cim` `doh` (amend --no-edit) `fit` `sit` `mark`.
- Rebase: `rb` `rc` (continue) `ra` (abort) `rs` (skip) `re` (edit-todo) `redo` (reset HEAD^).
- `delta` is the pager; `dsplit`/`dlog`/`dshow` force side-by-side.

Custom git subcommands live in `.local/bin/` (on `PATH`, invoked as `git <name>`):
`git-branch-base` (resolves a branch's upstream base for rebasing),
`git-rewrite-branch` (autosquash-rebase a branch onto its base),
`git-current-branch`, `git-setup-worktree-push` +
`githook-update-worktree-*` (lets a remote `$HOME` auto-checkout on push via
`receive.denyCurrentBranch=ignore`).

Remotes are other machines/servers (`nas`=soft-serve, `doral`, `ct`, `github`), each
holding parallel copies of these branches.

## Layout & where things live

- **Shell env**: `.profile` holds shell-agnostic environment, sourced by both bash and
  zsh. It loads modular fragments from `.profile.d/` (one concern per file: `golang`,
  `rust`, `nodejs`, `path_cleanup`, `term`, `pager`, …).
- **Zsh**: `.zshenv`/`.zprofile`/`.zshrc` load modules from `.zsh/rc.d/` (`prompt`,
  `completion`, `fzf`, `highlighting`, `zoxide`, `vi-mode-cursor`, …); functions in
  `.zsh/func/`. Bash: `.bash_profile`/`.bashrc`. Shared aliases: `.aliases`.
- **Neovim** (`.config/nvim/`): Lua config, `lazy.nvim` plugin manager
  (`lazy-lock.json` pins versions). Entry `init.lua`; plugins one-per-file under
  `lua/plugins/`; personal helpers under `lua/my/`; LSP server configs in `lsp/`.
  A unified `.vimrc` exists for hosts without neovim.
- **Wayland desktop**: compositor configs for `niri` (primary), `river`, `sway` under
  `.config/`; `noctalia/` is a Quickshell-based desktop shell (largest config tree);
  plus `kanshi` (output profiles), `waybar`, `wofi`/`uwofi`, `wlogout`, `swayidle`.
- **Terminals**: `ghostty`, `alacritty`, `foot`, `wezterm`, `kitty`, plus `tmux`.
- **Custom scripts** (`.local/bin/`): `home-install`/`home-bootstrap` (provision a
  machine from this repo), `home-backup`, `alter` (manage secondary "alter" user
  accounts + sudoers), `power-profile`, `recshot`, `river-config-input`, `run`.
- **`pkgs/`**: locally-patched Arch `PKGBUILD` recipes (e.g. `niri-shm` = niri + a PR
  patch). Built/installed via the AUR helper `paru`, not by this repo directly.
- **`TODO.md`**: running personal backlog.

## Colors / terminfo

The color scheme is `darkula` (a darkened JetBrains Dracula). 24-bit color relies on
`$TERM` adjustment in `.profile.d/term` and compiling `.terminfo.src/`. Editing a
colorscheme means touching several coordinated places: `.dircolors/`, the pager
config, zsh highlighting, and the nvim/vim `termguicolors` setup.
