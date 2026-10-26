#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi

# Overlay first, so pwm@98000 is compatible before the driver probes.
# Both steps are skipped when they are already active: insmod then prints
# "File exists" and, with set -e, the script would stop before homeserver.
if ! sudo dtoverlay -l 2>/dev/null | grep -q 'rp1_ws281x_pwm'; then
  sudo dtoverlay -d . rp1_ws281x_pwm
fi

if ! grep -q '^rp1_ws281x_pwm ' /proc/modules; then
  sudo insmod ./rp1_ws281x_pwm.ko pwm_channel=2
fi

sudo pinctrl set 18 a3 pn
sudo ./homeserver

exit 0
