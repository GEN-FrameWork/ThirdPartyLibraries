#!/bin/bash
# Cross-build rp1_ws281x_pwm.ko + .dtbo on WSL Debian 13 for Raspberry Pi 5 (rpi-2712).
# Uses latest linux-headers-*+rpt-rpi-2712 from archive.raspberrypi.com (trixie).
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")/../rpi_5/rp1_ws281x_pwm" && pwd)"
OUT_DIR="$(cd "$(dirname "$0")/rp1_ws281x_pwm" && pwd)"
WORKDIR="${WORKDIR:-/tmp/ws281x_rpi5_build}"
BASE="https://archive.raspberrypi.com/debian"
# Pin to current Trixie meta target (update if Pi kernel advances)
KVER="${KVER:-6.18.50+rpt-rpi-2712}"
KVER_COMMON="${KVER_COMMON:-6.18.50+rpt-common-rpi}"
KBUILD_PKG="${KBUILD_PKG:-linux-kbuild-6.18.50+rpt}"
BASE_PKG="${BASE_PKG:-linux-base-6.18.50+rpt-rpi-2712}"

echo "==> Source: $SRC_DIR"
echo "==> Output: $OUT_DIR"
echo "==> Kernel flavor: $KVER"

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR/debs" "$WORKDIR/root"
cd "$WORKDIR/debs"

curl -fsSL -o Packages.gz "$BASE/dists/trixie/main/binary-arm64/Packages.gz"
gunzip -kf Packages.gz
curl -fsSL -o Packages_amd64.gz "$BASE/dists/trixie/main/binary-amd64/Packages.gz"
gunzip -kf Packages_amd64.gz

pick() {
  local name="$1" pkgs="$2"
  awk -v n="$name" '
    BEGIN{RS=""; FS="\n"}
    {
      pkg=""; fn=""
      for(i=1;i<=NF;i++){
        if($i ~ /^Package: /) pkg=substr($i,10)
        if($i ~ /^Filename: /) fn=substr($i,11)
      }
      if(pkg==n){ print fn; exit }
    }' "$pkgs"
}

H1=$(pick "linux-headers-${KVER}" Packages)
H2=$(pick "linux-headers-${KVER_COMMON}" Packages)
KB=$(pick "$KBUILD_PKG" Packages_amd64)
[ -n "$KB" ] || KB=$(pick "$KBUILD_PKG" Packages)
LB=$(pick "$BASE_PKG" Packages)

echo "headers: $H1"
echo "common:  $H2"
echo "kbuild:  $KB"
echo "base:    $LB"
for f in "$H1" "$H2" "$KB" "$LB"; do
  if [ -z "$f" ]; then
    echo "ERROR: could not resolve a required package path" >&2
    exit 1
  fi
  bn=$(basename "$f")
  echo "Downloading $bn ..."
  curl -fsSL -o "$bn" "$BASE/$f"
done

sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  device-tree-compiler bc flex bison libssl-dev python3 >/dev/null

for deb in *.deb; do
  echo "Extract $deb"
  dpkg-deb -x "$deb" "$WORKDIR/root"
done

KBUILD="$WORKDIR/root/lib/modules/${KVER}/build"
if [ ! -d "$KBUILD" ]; then
  # Some packages only install under /usr/src
  ALT="$WORKDIR/root/usr/src/linux-headers-${KVER}"
  if [ -d "$ALT" ]; then
    mkdir -p "$WORKDIR/root/lib/modules/${KVER}"
    ln -sfn "$ALT" "$KBUILD"
  fi
fi

if [ ! -e "$KBUILD/Makefile" ]; then
  echo "ERROR: kernel build tree not found at $KBUILD" >&2
  find "$WORKDIR/root" -maxdepth 5 -type d -name "linux-headers-*" -o -name "${KVER}" 2>/dev/null | head -40
  exit 1
fi

# Debian header packages hardcode absolute /usr/src and /usr/lib paths. Symlink the
# extracted trees there so the cross build can find common headers + kbuild tools.
echo "==> Linking extracted headers into /usr/src and /usr/lib"
sudo mkdir -p /usr/src /usr/lib
sudo ln -sfn "$WORKDIR/root/usr/src/linux-headers-${KVER}" "/usr/src/linux-headers-${KVER}"
sudo ln -sfn "$WORKDIR/root/usr/src/linux-headers-${KVER_COMMON}" "/usr/src/linux-headers-${KVER_COMMON}"
for d in "$WORKDIR/root/usr/lib"/linux-kbuild-*; do
  [ -d "$d" ] || continue
  sudo ln -sfn "$d" "/usr/lib/$(basename "$d")"
done
# Prefer the real /usr/src tree as KBUILD once linked
KBUILD="/usr/src/linux-headers-${KVER}"

echo "==> KBUILD=$KBUILD"
ls -la "$KBUILD" | head
ls -la "/usr/src/linux-headers-${KVER_COMMON}" | head

BUILD_DIR="$WORKDIR/module"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp -a "$SRC_DIR"/. "$BUILD_DIR"/
cd "$BUILD_DIR"
# Drop stale Debian12 objects if any were copied from Resources
rm -f ./*.o ./*.ko ./*.mod ./*.mod.c ./*.order ./*.symvers .*.cmd 2>/dev/null || true

echo "==> Building device tree overlay"
chmod +x dts.sh
./dts.sh
ls -la rp1_ws281x_pwm.dtbo

echo "==> Building kernel module (cross aarch64)"
make -C "$KBUILD" M="$BUILD_DIR" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules

echo "==> Module info"
modinfo ./rp1_ws281x_pwm.ko | sed -n '1,20p'

echo "==> Installing artifacts into Resources/rp1_ws281x_pwm"
mkdir -p "$OUT_DIR"
cp -f rp1_ws281x_pwm.ko rp1_ws281x_pwm.dtbo "$OUT_DIR"/
# Keep sources in sync copy of built tree markers (optional)
cp -f rp1_ws281x_pwm.mod.c modules.order Module.symvers "$OUT_DIR"/ 2>/dev/null || true

# Also refresh rpi_5 tree copies so source+artifacts live together
cp -f rp1_ws281x_pwm.ko rp1_ws281x_pwm.dtbo "$SRC_DIR"/

echo "==> DONE"
ls -la "$OUT_DIR"/rp1_ws281x_pwm.ko "$OUT_DIR"/rp1_ws281x_pwm.dtbo
modinfo "$OUT_DIR"/rp1_ws281x_pwm.ko | grep -E 'vermagic|filename|name'
