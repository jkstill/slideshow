#!/usr/bin/env bash

# assumes ubuntu 24.4 and Wayland

BRIGHTNESS=40 # percent

logFile='/tmp/slideshow-login.log'
touch $logFile || echo "failed to create logfile at "$(date '+%Y-%m-%d_%H-%M-%S') >> /dev/stderr
> $logFile

logger () {
	echo "$(date '+%Y-%m-%d_%H-%M-%S'):$*" >> $logFile
}

logger "created logfile at $logFile"


# set monitor brightness to 40%
# use 'sudo ddcutil detect' to see if the monitor can be controlled
ddcutil setvcp 10 $BRIGHTNESS
logger "ddcutil: monitor brightness to $BRIGHTNESS%"

ME=$(whoami)

#: <<'NOT-TESTED'

trapcmds () {
	typeset SIGTEXT=${1:-'UNKNOWN'}
	typeset SIGNUM=${2:-1}

	echo "trapped $SIGTEXT"
	echo sorry, you are trapped
	return
}

caughtINT () {
	trapcmds SIGINT 2
	return
}

caughtTERM () {
	trapcmds SIGTERM 15
	return
}

caughtHUP () {
	loadConfig SIGHUP 1
	return
}
#NOT-TESTED

logger "created traps"

logger "gsettings to disable screen saver and no blanking" 

# Disable automatic screen blank
gsettings set org.gnome.desktop.session idle-delay 0

# Disable automatic suspend
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

# Disable screensaver
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false

# Disable screen dimming
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false

while :
do

	logger "checking DISPLAY: $DISPLAY" 

	if [ -z "$DISPLAY" ] || [ -z "$WAYLAND_DISPLAY" ]; then
		logger "DISPLAY: $DISPLAY"
		logger "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
		logger "DISPLAY not setup"
		logger "exit with break"
		#break
	fi

	logger "display:${ME}:${DISPLAY}"
	logger "display:${ME}:${WAYLAND_DISPLAY}"

	logger "start:${ME}:NA"

	#/usr/bin/feh --auto-rotate --hide-pointer --borderless --quiet --slideshow-delay 10 --image-bg black --fullscreen --auto-zoom --randomize --recursive ~/slides
	#/usr/bin/feh --auto-rotate --hide-pointer --borderless --quiet --slideshow-delay 10 --image-bg black --fullscreen --auto-zoom --randomize --recursive ~/slides
 	#/usr/bin/feh --auto-rotate --hide-pointer --quiet --slideshow-delay 10 --image-bg black --fullscreen --auto-zoom --randomize --recursive ~/slides
	/usr/bin/feh \
		--cache-size 2048  \
		--hide-pointer \
		--borderless \
		--quiet \
		--slideshow-delay 10 \
		--image-bg black \
		--fullscreen \
		--auto-zoom \
		--randomize \
		--recursive \
		--draw-tinted \
		-d --draw-exif \
		/home/slideshow/slides \
		>> $logFile 2>&1

	RC=$?

	#[[ $RC -eq 131 ]] && break
	logger "RC: $RC"

	# uncomment the break to allow exiting script
	# break

	logger "end:${ME}:${RC}"

done

