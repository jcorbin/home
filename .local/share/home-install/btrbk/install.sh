#!/usr/bin/env bash

# btrbk install script
# Automates the installation steps from INSTALL.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

CONF_FILE="/etc/btrbk/btrbk.conf"

sudo_env() {
    if [[ $EUID -ne 0 ]]; then
      sudo "$@"
    else
      "$@"
    fi
}

# Step 1: Install packages
install_packages() {
    log_info "Installing packages: btrbk mbuffer"
    sudo_env pacman -S --needed --noconfirm btrbk mbuffer
    log_success "Packages installed"
}

# Step 2: Setup SSH directory and key
setup_ssh() {
    log_info "Setting up SSH directory and key"
    sudo_env install -d /etc/btrbk/ssh -m 0700

    if [[ ! -f /etc/btrbk/ssh/id_ed25519 ]]; then
        log_info "Generating ed25519 SSH key"
        sudo_env ssh-keygen -t ed25519 -f /etc/btrbk/ssh/id_ed25519 -C "root+btrbk@$(hostname)" -N ""
        log_success "SSH key generated"
    else
        log_warn "SSH key already exists, skipping generation"
    fi

    # Copy public key to clipboard if wl-copy available
    if command -v wl-copy >/dev/null 2>&1; then
        sudo_env cat /etc/btrbk/ssh/id_ed25519.pub | wl-copy
        log_success "Public key copied to clipboard"
    else
        log_warn "wl-copy not available, public key:"
        sudo_env cat /etc/btrbk/ssh/id_ed25519.pub
    fi

    echo
    log_warn "MANUAL STEP REQUIRED: Authorize the above public key on your NAS"
    log_warn "Add it to ~/.ssh/authorized_keys on the NAS for the backup user"
    read -rp "Press Enter after authorizing the key on the NAS..."
}

# Step 3: Install and configure mount unit
setup_mount() {
    log_info "Setting up btrfs pool mount unit"

    local mount_file="${SCRIPT_DIR}/mnt-btr_pool.mount"
    if [[ ! -f "$mount_file" ]]; then
        log_error "Mount unit template not found: $mount_file"
        exit 1
    fi

    # Get the UUID of the btrfs pool
    log_info "Detecting btrfs pool UUID..."
    local uuid
    uuid=$(findmnt -n -o UUID -T /mnt/btr_pool 2>/dev/null || true)

    if [[ -z "$uuid" ]]; then
        log_warn "Could not auto-detect UUID. Available btrfs filesystems:"
        findmnt -t btrfs -o TARGET,UUID,FSTYPE
        read -rp "Enter the UUID for the btrfs pool: " uuid
    fi

    if [[ -z "$uuid" ]]; then
        log_error "UUID is required"
        exit 1
    fi

    log_info "Using UUID: $uuid"
    sed "s/FIXME/$uuid/g" "$mount_file" \
        | sudo_env tee /etc/systemd/system/mnt-btr_pool.mount

    sudo_env systemctl daemon-reload
    sudo_env systemctl enable --now mnt-btr_pool.mount

    # Verify mount
    if findmnt /mnt/btr_pool >/dev/null; then
        log_success "Mount active at /mnt/btr_pool"
    else
        log_error "Mount failed"
        exit 1
    fi
}

# Step 4: Create snapshots subvolume
create_snapshots_subvolume() {
    log_info "Creating snapshots subvolume"
    if [[ ! -d /mnt/btr_pool/@snapshots ]]; then
        sudo_env btrfs subvolume create /mnt/btr_pool/@snapshots
        log_success "Created /mnt/btr_pool/@snapshots"
    else
        log_warn "Subvolume /mnt/btr_pool/@snapshots already exists"
    fi
}

# Step 5: Install btrbk.conf
setup_btrbk_conf() {
    log_info "Setting up btrbk.conf"

    local conf_template="${SCRIPT_DIR}/btrbk.conf"
    if [[ ! -f "$conf_template" ]]; then
        log_error "btrbk.conf template not found: $conf_template"
        exit 1
    fi

    # Interactive configuration of btrbk.conf FIXME markers
    local tmp_conf
    tmp_conf=$(mktemp)
    cp "$conf_template" "$tmp_conf"

    # Replace FIXME markers interactively
    if grep -q "FIXME" "$tmp_conf"; then
        log_info "Configuring btrbk.conf FIXME markers:"
        
        # snapshot_dir
        local snapshot_dir
        read -rp "  Enter snapshot_dir (e.g. @snapshots): " snapshot_dir
        sed -i "s/snapshot_dir[[:space:]]*FIXME/snapshot_dir            $snapshot_dir/" "$tmp_conf"
        
        # target (remote path)
        local target_path
        read -rp "  Enter remote backup path (e.g. volume1/Backup/machine-name): " target_path
        sed -i "s|target[[:space:]]*ssh://nas.tail54020.ts.net/volume1/Backup/FIXME|target          ssh://nas.tail54020.ts.net/volume1/Backup/$target_path|" "$tmp_conf"
        
        # subvolume
        local subvolume
        read -rp "  Enter source subvolume (e.g. @home or @): " subvolume
        sed -i "s/subvolume[[:space:]]*FIXME/subvolume       $subvolume/" "$tmp_conf"
        
        log_success "FIXME markers configured"
    fi

    sudo_env install -m 0644 "$tmp_conf" "$CONF_FILE"
    rm -f "$tmp_conf"
    log_success "btrbk.conf installed"

    # Verify config
    log_info "Verifying btrbk config..."
    sudo_env btrbk -c "$CONF_FILE" list
}

# Step 6: Run initial backup
run_initial_backup() {
    log_info "Running initial backup (dry-run first)"
    sudo_env btrbk -c "$CONF_FILE" dryrun

    read -rp "Proceed with actual backup? (y/N): " -n 1 reply
    echo
    if [[ "$reply" =~ ^[Yy]$ ]]; then
        sudo_env btrbk -c "$CONF_FILE" run
        log_success "Initial backup completed"
    else
        log_warn "Skipped actual backup run"
    fi
}

# Step 7: Operationalize with systemd overrides
operationalize() {
    log_info "Installing systemd service/timer overrides"

    local override_dir="/etc/systemd/system/btrbk.service.d"
    sudo_env install -m 0755 -d "$override_dir"

    local timer_override_dir="/etc/systemd/system/btrbk.timer.d"
    sudo_env install -m 0755 -d "$timer_override_dir"

    # Service override
    local svc_override="${SCRIPT_DIR}/btrbk.service.d_pool-and-nas.conf"
    if [[ -f "$svc_override" ]]; then
        sudo_env install -m 0644 "$svc_override" "${override_dir}/pool-and-nas.conf"
        log_success "Installed btrbk service override"
    else
        log_warn "Service override template not found: $svc_override"
    fi

    # Timer override
    local timer_override="${SCRIPT_DIR}/btrbk.timer.d_hourly.conf"
    if [[ -f "$timer_override" ]]; then
        sudo_env install -m 0644 "$timer_override" "${timer_override_dir}/hourly.conf"
        log_success "Installed btrbk timer override"
    else
        log_warn "Timer override template not found: $timer_override"
    fi

    sudo_env systemctl daemon-reload
    sudo_env systemctl enable --now btrbk.timer

    log_success "btrbk.timer enabled and started"
    log_info "Timer status:"
    systemctl list-timers --all | grep btrbk || true
    log_info "Service status (will show on next run):"
    systemctl status btrbk.service --no-pager || true
}

# Step 8: Install btrbk-lan-gate script
install_lan_gate() {
    local script="${SCRIPT_DIR}/btrbk-lan-gate"
    if [[ -f "$script" ]]; then
        log_info "Installing btrbk-lan-gate"
        sudo_env install -m 0755 "$script" /usr/local/bin/btrbk-lan-gate
        log_success "btrbk-lan-gate installed to /usr/local/bin"
    else
        log_warn "btrbk-lan-gate script not found, skipping"
    fi
}

main() {
    log_info "Starting btrbk installation"

    install_packages
    setup_ssh
    setup_mount
    create_snapshots_subvolume
    setup_btrbk_conf
    run_initial_backup
    install_lan_gate
    operationalize

    log_success "btrbk installation complete!"
    log_info "Verify with: systemctl status btrbk.service && systemctl list-timers"
}

main "$@"
