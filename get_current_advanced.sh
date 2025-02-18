#!/bin/bash
SHELL=/bin/sh PATH=/bin:/sbin:/usr/bin:/usr/sbin 

# Advanced verion (not shown in the youtube-video) for the use with
# a Raspberry-Pi-(HQ-)Cam.

# For the determination of sunset and sunrise:
# sunwait by risacher (GPL-3.0 license)
# https://github.com/risacher/sunwait
# SUNSTATUS:
# 0   day
# 1   night - daylight      Top of sun just below the horizon. Default.
# 2   night - civil         Civil Twilight.         -6 degrees below horizon.
# 3   night - nautical      Nautical twilight.     -12 degrees below horizon.

SUNSTATUS=0

/usr/local/bin/sunwait poll exit daylight 50.0034N 8.2719E
SUNWAIT_EXIT=$?

if [ $SUNWAIT_EXIT -eq 3 ]; then
	SUNSTATUS=1
fi

/usr/local/bin/sunwait poll exit civil 50.0034N 8.2719E
SUNWAIT_EXIT=$?

if [ $SUNWAIT_EXIT -eq 3 ]; then
	SUNSTATUS=2
fi

/usr/local/bin/sunwait poll exit nautical 50.0034N 8.2719E
SUNWAIT_EXIT=$?

if [ $SUNWAIT_EXIT -eq 3 ]; then
	SUNSTATUS=3
fi


if [ $SUNSTATUS -eq 3 ]; then
    # Nautische Nachteinstellungen
    if ! pgrep -x "libcamera-still" > /dev/null; then
        timeout 118 libcamera-still -n --shutter 100000000 --width 4056 --height 2282 --quality 100 --awbgains 3.5,1.5 --ev 0 -o /home/pi/Timelapse/imgs/tl_`date +%Y-%m-%d_%H-%M-%S`.jpg
    fi
    sleep 0.8
    mv /home/pi/Timelapse/imgs/* /media/salastore/99Aufnahmen/Timelapse/imgs/
elif [ $SUNSTATUS -eq 2 ]; then
    # Zwischen nautischer Nacht und Civil
    if ! pgrep -x "libcamera-still" > /dev/null; then
        timeout 90 libcamera-still -n --shutter 6000000 --width 4056 --height 2282 --quality 100 --awbgains 3.5,1.5 --ev 0 -o /home/pi/Timelapse/imgs/tl_`date +%Y-%m-%d_%H-%M-%S`.jpg
    fi
    sleep 0.8
    mv /home/pi/Timelapse/imgs/* /media/salastore/99Aufnahmen/Timelapse/imgs/
elif [ $SUNSTATUS -eq 1 ]; then
    # Zwischen Civil und Daylight
    if ! pgrep -x "libcamera-still" > /dev/null; then
        timeout 20 libcamera-still -n --shutter 1200000 --width 4056 --height 2282 --quality 100 --awbgains 3.5,1.5 --ev 0 -o /home/pi/Timelapse/imgs/tl_`date +%Y-%m-%d_%H-%M-%S`.jpg
    fi
    sleep 0.8
    mv /home/pi/Timelapse/imgs/* /media/salastore/99Aufnahmen/Timelapse/imgs/
else
    # Tageinstellungen
    start_time=$(date +%s%N)
    for ((i=0;i<8;i++)); do
        if ! pgrep -x "libcamera-still" > /dev/null; then
            timeout 15 libcamera-still -n -t 500 --width 4056 --height 2282 --quality 100 --awbgains 3.5,1.5 --ev 1 -o /home/pi/Timelapse/imgs/tl_`date +%Y-%m-%d_%H-%M-%S`.jpg
        fi
        mv /home/pi/Timelapse/imgs/* /media/salastore/99Aufnahmen/Timelapse/imgs/

	if ((i < 7)); then
		# Berechne die Zeit für den nächsten Zyklus
		next_time=$((start_time + (i+1)*15000000000))
		current_time=$(date +%s%N)
		sleep_time=$(( (next_time - current_time) / 1000000000 ))

		if (( sleep_time > 0 )); then
		sleep $sleep_time
		fi
	fi
    done

fi
