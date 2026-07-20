# niri-shm — niri with SHM screencast (PR #1791)

Locally-patched build of the official Arch `niri` package that layers
[niri PR #1791 "Support shm sharing"](https://github.com/YaLTeR/niri/pull/1791)
(tracking issue [#455](https://github.com/YaLTeR/niri/issues/455)) onto the
`26.04` release.

## Why

Stock niri exposes PipeWire screencast frames as **DMA-BUF only**. Apps whose
capturer accepts **SHM (system-memory) buffers only** — notably **Zoom** — can't
negotiate a common format, so PipeWire fails with `no more input formats` and the
shared video is **black**. (Discord works because it speaks DMA-BUF.) PR #1791
adds an SHM fallback so SHM-only consumers work.

Diagnosis details: it's a producer/consumer format mismatch, confirmed in the
niri journal (`niri::screencasting::pw_utils`) — Zoom offers `BGRx/RGBx/RGBA`
with *no modifier*; niri only offers `BGRx` + DMA-BUF modifiers.

## Contents

- `PKGBUILD` — official 26.04 PKGBUILD + patch step, `pkgrel=2`.
- `pr1791-shm.diff` — PR #1791 combined diff (single file: `src/screencasting/pw_utils.rs`; no Cargo.lock/toml changes).

## Build & install

```sh
makepkg -f --nocheck          # builds; package lands in $PKGDEST (/home/packages)
sudo pacman -U /home/packages/niri-26.04-2-x86_64.pkg.tar.zst
# then log out / back in — the running compositor keeps the old binary until a
# fresh niri session.
```

Verify after relogin: start a Zoom screen share and watch
`journalctl --user -f | grep pw_utils` — it should reach `Streaming` instead of
`Error("no more input formats")`.

## Keeping it / updating

- `pkgrel=2` keeps `pacman -Syu` from silently downgrading to repo `26.04-1`.
  To pin harder, add `IgnorePkg = niri` to `/etc/pacman.conf` (and remember to
  lift it later).
- **When niri releases a version newer than 26.04:** bump `pkgver`, refresh the
  source tarball `sha512sums`/`b2sums` (`makepkg -g`), re-fetch the PR diff
  (`curl -fsSL https://github.com/YaLTeR/niri/pull/1791.diff -o pr1791-shm.diff`),
  and confirm it still applies (`patch -Np1 --dry-run -i pr1791-shm.diff` inside
  the extracted source). If PR #1791 has merged upstream by then, drop this
  build and go back to the stock package.

## Caveat

With SHM working, full-**monitor** sharing is solid; single-**window** capture in
Zoom on niri can still be flaky — prefer sharing a whole output.
