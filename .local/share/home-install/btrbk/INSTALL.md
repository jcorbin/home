# First install on `raidho`

By hand, no notes.

Then captured these artifacts after the fact.

# Second install on `cavil`

Recorded these notes while picking thru the first session's artifacts:

1. `sudo pacman -S btrbk mbuffer`
2. `sudo install -d /etc/btrbk/ssh -m 0700`
3. `sudo ssh-keygen -t ed25519 -f /etc/btrbk/ssh/id_ed25519 -C "root+btrbk@$(hostname)"`
4. `sudo cat /etc/btrbk/ssh/id_ed25519.pub | wl-copy` then authorize on nas
5. `sudo install -m 0644 mnt-btr_pool.mount /etc/systemd/system/mnt-btr_pool.mount` XXX fix the uuid ; TODO template
6. `systemctl daemon-reload && systemctl enable --now mnt-btr_pool.mount` verify /mnt/btr_pool/
7. `sudo btrfs subvolume create /mnt/btr_pool/@snapshots` XXX or other name to taste if flat btrfs layout
8. `sudo install -m 0644 btrbk.conf /etc/btrbk/btrbk.conf` XXX edit wrt FIXME ; TODO template
9. `sudo btrbk run` and verify first backup
10. Operationalize:
```
sudo install -m 0755 btrbk-lan-gate /usr/local/bin/btrbk-lan-gate
sudo install -m 0755 -d /etc/systemd/system/btrbk.service.d
sudo install -m 0755 -d /etc/systemd/system/btrbk.timer.d
sudo install -m 0644 btrbk.service.d_pool-and-nas.conf /etc/systemd/system/btrbk.service.d/pool-and-nas.conf
sudo install -m 0644 btrbk.timer.d_hourly.conf /etc/systemd/system/btrbk.timer.d/hourly.conf
```
then `systemctl daemon-reload && systemctl enable --now btrbk.timer` and verify `systemctl list-timers`  / watch `systemctl status btrbk.service` for next run

TODO port all of the above into an install script
