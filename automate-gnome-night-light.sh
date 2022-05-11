#!/bin/bash

#Get sunrise and sunset times from weather.com. Change the link to your current location
tmpfile=~/automate-gnome-night-light-tmp.txt
wget -q "https://weather.com/weather/today/l/6e9b4f7d432c15a754cf903bdadf3b95725941f8e9f9854477f381580cc31928" -O "$tmpfile"

SUNR=$(grep SunriseSunset "$tmpfile" | grep -oE '((1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm]))' | head -1)
SUNS=$(grep SunriseSunset "$tmpfile" | grep -oE '((1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm]))' | tail -1)

sunrise_time=$(date --date="$SUNR" +%H%M)
sunset_time=$(date --date="$SUNS" +%H%M)

if [ $sunrise_time -eq 0000 -a $sunset_time -eq 0000 ] ; then
	#Set sunrise, sunset, and night times from here.
	#Don't add ":" between the hour and the minute.
	sunrise_time=740
	sunset_time=1745
fi

night_time=2200

rm ~/automate-gnome-night-light-tmp.txt

#Set the light temperatures from here. Lower value is warmer, higher value is cooler.
day_time_light_temperature=3000
evening_time_light_temperature=2600
night_time_light_temperature=2100

while true
	do
		sleep_time=1
		day_in_seconds=86400
		current_time=$(date +%k%M)
		current_time_in_seconds=$(date +%s)

		#To turn on the night light and keep it that way regardless.
		#If night light is turned off, it will be turn on again on the next stage of the day.
		#Comment this off if you want to be able to turn it off and keep it that way.
		gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

		if [ $current_time -gt $sunrise_time -a $current_time -lt $sunset_time ]; then
			#Day time
			gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature $day_time_light_temperature
			sleep_time=$(($(date -d $sunset_time +%s) - $current_time_in_seconds))
		elif [ $current_time -gt $sunset_time -a $current_time -lt $night_time ]; then
			#Evening
			gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature $evening_time_light_temperature
			sleep_time=$(($(date -d $night_time +%s) - $current_time_in_seconds))
		else
			#Night time
			gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature $night_time_light_temperature

			difference=$(($(date -d $sunrise_time +%s) - $current_time_in_seconds))
			if [ $difference -lt 0 ]; then
				sleep_time=$((day_in_seconds + difference))
			else
				sleep_time=$difference
			fi
		fi
	sleep $sleep_time
done
