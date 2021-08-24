ls /home/pi/Timelapse/tl_*.jpg > /home/pi/Timelapse/stills.txt
today=$(date -d "today 13:00" +"%Y-%m-%d")
mencoder -nosound -ovc x264 -lavcopts vcodec=mpeg4:vbitrate=8000000 -vf scale=1600:1200 -o /home/pi/Timelapse/vids/timelapse-weather_${today}.avi -mf type=jpeg:fps=50 mf://@/home/pi/Timelapse/stills.txt

ffmpeg -i /home/pi/Timelapse/vids/timelapse-weather_${today}.avi -c:v copy -an /home/pi/Timelapse/vids/timelapse-weather_${today}.mp4
ffmpeg -y -i /home/pi/Timelapse/vids/timelapse-weather_${today}.avi -b:v 5M -q:v 10 -vcodec libvpx -an /home/pi/Timelapse/vids/timelapse-weather.webm

cp /home/pi/Timelapse/vids/timelapse-weather_${today}.mp4 /var/www/html/timelapse-weather.mp4
cp /home/pi/Timelapse/vids/timelapse-weather.webm /var/www/html/timelapse-weather.webm
rm /home/pi/Timelapse/vids/timelapse-weather_${today}.avi
rm /home/pi/Timelapse/tl_*.jpg
