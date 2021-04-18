#!/bin/bash

SHELL=/bin/sh PATH=/bin:/sbin:/usr/bin:/usr/sbin

for ((i=0;i<3;i++)); do
	wget http://192.168.178.XXX/capture -O /home/pi/Timelapse/tl_weather_`date +%Y-%m-%d_%H-%M-%S`.jpg

latest=$(ls /home/pi/Timelapse/tl_weather_*.jpg -rt1 | tail -1)
Watermarktext=$(ls /home/pi/Timelapse/tl_weather_*.jpg -rt1 | tail -1 | grep -o -e 'tl_weather_.*$')
Watermarklarge=$(ls /home/pi/Timelapse/tl_weather_*.jpg -rt1 | tail -1 | grep -o -e 'tl_weather_.*$' | rev|cut -c11-12|rev)

ps=$(wc -c <"$latest")
mn=10000

if [ $ps -le $mn ]; then
  curl "http://192.168.178.XXX/control?var=framesize&val=10"
  curl "http://192.168.178.XXX/control?var=raw_gma&val=0"
  curl "http://192.168.178.XXX/control?var=hmirror&val=1"
  curl "http://192.168.178.XXX/control?var=vflip&val=1"
  curl "http://192.168.178.XXX/control?var=dcw&val=0"
  sleep 5.0
  wget http://192.168.178.XXX/capture -O /home/pi/Timelapse/tl_weather_`date +%Y-%m-%d_%H-%M-%S`.jpg
  latest=$(ls /home/pi/Timelapse/tl_weather_*.jpg -rt1 | tail -1)
fi


if test -f "$latest"; then
  cp ${latest} /home/pi/Timelapse/weather_.jpg
fi


# Apply watermark text for website to the "weather_.jpg" image
  Fontsize=10
  Font="Arial.ttf"
  Fontcolour="white"

# Programmbeginn
  horizontal=`identify -verbose weather_.jpg | grep Geometry: | awk {'print $2'} |cut -d"x" -f 1`
  vertical=`identify -verbose weather_.jpg | grep Geometry: | awk {'print $2'} |cut -d"x" -f 2`
  Textdistancefromleft=40
  Textdistancefromtop=1160
  X=$Textdistancefromleft
  Y=$Textdistancefromtop
  convert -quality 50 -pointsize $Fontsize -fill $Fontcolour -draw "text $X, $Y '$Watermarktext'" "/home/pi/Timelapse/weather_.jpg"  "/home/pi/Timelapse/weather__.jpg"

# Apply watermark text for website to the "weather_.jpg" image
  Fontsizegr=50

  horizontal=`identify -verbose weather_.jpg | grep Geometry: | awk {'print $2'} |cut -d"x" -f 1`
  vertical=`identify -verbose weather_.jpg | grep Geometry: | awk {'print $2'} |cut -d"x" -f 2`
  convert -quality 50 -pointsize $Fontsizegr -fill $Fontcolour -draw "text $X, $Y '$Watermarklarge'" "/home/pi/Timelapse/weather_.jpg"  "/home/pi/Timelapse/weather_2.jpg"

cp /home/pi/Timelapse/weather__.jpg /var/www/html/weather.jpg
cp /home/pi/Timelapse/weather_2.jpg ${latest}
rm /home/pi/Timelapse/weather__.jpg

	sleep 17.6
done
exit
