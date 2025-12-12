#!/bin/sh

export XDG_SESSION_TYPE=x11

# Start D-Bus if not running already
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

dbus-update-activation-environment --all &

# Blue Light Filter
redshift -P -O 4000 &

xrandr --output HDMI1 --mode 1920x1080 &

# Increase input rate
xset r rate 225 35 &

# Window Transparency, Blur, Shadow and Animations
# The .config/picom.conf does only enable opacity
picom --daemon &

sxhkd &

# Set Wallpaper
xwallpaper --maximize "$HOME/stow/swaybg-wallpaper.jpg" &

init_wallpaper &
setup_bindings() {
  setxkbmap -layout us,br -option grp:switch,ctrl:nocaps
}

setup_bindings &

conky_bar() {
  conky | dwm-statusbar
}

conky_bar &

# When dwm gets recompiled, it's binary has a different sha1sum that can be used
# to relaunch dwm automatically if the hash changes while dwm is already running
# This prevents closing all applications and see changes immediately. However,
# this will break the layout where all applications were
initialize_dwm() {
  new_csum=$(sha1sum "$(which dwm)")
  while true; do
    if [ "$csum" != "$new_csum" ]; then
      csum=$new_csum
      dbus-launch ssh-agent dwm
    else
      exit 0
    fi
    new_csum=$(sha1sum "$(which dwm)")
    sleep 0.5
  done
}

initialize_dwm
