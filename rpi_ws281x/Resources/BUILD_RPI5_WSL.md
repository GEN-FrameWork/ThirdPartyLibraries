# Build `rp1_ws281x_pwm` (.ko + .dtbo) on WSL Debian 13

Cross-compiles the Raspberry Pi 5 kernel module against **Raspberry Pi OS Trixie** headers (`*-rpt-rpi-2712`) from `archive.raspberrypi.com`.

## Prerequisites (WSL distro `Debian13`)

- `crossbuild-essential-arm64` (already used for `aarch64-linux-gnu-gcc`)
- Network access to download kernel header `.deb`s
- Passwordless `sudo` for `apt` + `/usr/src` symlinks

## Build

```bash
wsl -d Debian13 -- bash /mnt/e/Projects/GEN_FrameWork/ThirdPartyLibraries/rpi_ws281x/Resources/build_rpi5_module_wsl.sh
```

Outputs (overwrite):

- `Resources/rp1_ws281x_pwm/rp1_ws281x_pwm.ko`
- `Resources/rp1_ws281x_pwm/rp1_ws281x_pwm.dtbo`
- Same files also copied under `rpi_5/rp1_ws281x_pwm/`

Default target vermagic: `6.18.50+rpt-rpi-2712` (latest meta `linux-headers-rpi-2712` at script pin time).

## Match the Pi kernel

On the Raspberry Pi 5:

```bash
uname -r
```

If it is **not** `6.18.50+rpt-rpi-2712`, rebuild with the matching version, e.g.:

```bash
KVER=6.12.47+rpt-rpi-2712 \
KVER_COMMON=6.12.47+rpt-common-rpi \
KBUILD_PKG=linux-kbuild-6.12.47+rpt \
BASE_PKG=linux-base-6.12.47+rpt-rpi-2712 \
  bash Resources/build_rpi5_module_wsl.sh
```

(Package names must exist under `dists/trixie` on the Raspberry Pi archive.)

## Driver source note

`rp1_ws281x_pwm.c` uses `LINUX_VERSION_CODE` so `.remove` is `void` on Linux ≥ 6.11 (required for Debian 13 / 6.12+ headers) and `int` on older kernels.

## Load on the Pi / CM5 (GPIO 18 example)

```bash
uname -r   # must match .ko vermagic
# Confirm new overlay (must mention pwm@98000 and rp1_dma, NOT ws281x_pwm@98000 under /rp1 alone)
dtc -I dtb -O dts ./rp1_ws281x_pwm.dtbo | head -40

ls /proc/device-tree/__symbols__/rp1_dma   # required for runtime dtoverlay

# Overlay first, then module (so probe binds to the updated pwm@98000 node)
sudo dtoverlay -v -d . rp1_ws281x_pwm
sudo insmod ./rp1_ws281x_pwm.ko pwm_channel=2
sudo pinctrl set 18 a3 pn
ls -l /dev/ws281x_pwm
```

The overlay **retargets stock** `/rp1/pwm@98000` (does not add a sibling node). Runtime apply needs symbol `rp1_dma` in `/proc/device-tree/__symbols__/`.

If `dtoverlay` still fails with `(kernel)`:

```bash
dmesg | tail -40
# Optional: load at boot instead of runtime
sudo cp ./rp1_ws281x_pwm.dtbo /boot/firmware/overlays/
# add to /boot/firmware/config.txt:  dtoverlay=rp1_ws281x_pwm
# and load the .ko via /etc/modules-load.d/ or homeserver.sh before use
```

Also remove any `dtoverlay=pwm` / `dtoverlay=pwm-2chan` from `config.txt` (conflicts with PWM0).
