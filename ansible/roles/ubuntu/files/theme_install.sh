#!/bin/bash
#
# Install themes to existing user accounts
#

WALLPAPER="/usr/share/backgrounds/MAG2022_wallpaper.jpeg"
USER_ICON="/usr/share/pixmaps/faces/MAG2022_face.png"

USERS=$(find /home -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)

for user in $USERS; do
    cp ${USER_ICON} /home/${user}/.face
    sudo -u ${user} dbus-launch gsettings set org.gnome.desktop.background picture-uri file://${WALLPAPER}
done
