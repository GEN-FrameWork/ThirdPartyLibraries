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

sudo insmod ./rp1_ws281x_pwm.ko pwm_channel=2
sudo dtoverlay -d . rp1_ws281x_pwm
sudo pinctrl set 18 a3 pn
sudo ./homeserver

exit 0
