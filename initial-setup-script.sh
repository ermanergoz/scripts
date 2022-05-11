#!/bin/bash

read -s -p "Enter username: " user_name
read -s -p "Enter sudo password: " sudo_password

log_file_path=/home/$user_name/Desktop/initial-setup-script.log 

print_seperator() {
	echo >> $log_file_path
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> $log_file_path
	echo >> $log_file_path
}

log_sudo_command_output() { 
	echo $sudo_password | sudo -S $@ &>> $log_file_path
	echo "'$@' executed with root privileges" >> $log_file_path
	print_seperator
}

log_command_output() { 
	$@ &>> $log_file_path
	echo "'$@' executed" >> $log_file_path
	print_seperator
}

echo "Update and upgrade"
log_sudo_command_output "apt-get update"
log_sudo_command_output "apt-get upgrade"

echo "Remove telemetry and make them stay that way"
log_sudo_command_output "apt purge ubuntu-report popularity-contest apport whoopsie apport-symptoms"
log_sudo_command_output "apt-mark hold ubuntu-report popularity-contest apport whoopsie apport-symptoms"

echo "Install applications. Might take a while"
log_sudo_command_output "snap install libreoffice"
log_sudo_command_output "snap install vlc"
log_sudo_command_output "snap install android-studio --classic"
log_sudo_command_output "snap install clion --classic"
log_sudo_command_output "snap install phpstorm --classic"
log_sudo_command_output "snap install intellij-idea-community --classic"
log_sudo_command_output "snap install qbittorrent-arnatious"
log_sudo_command_output "snap install opera"
log_sudo_command_output "snap install apple-music-for-linux"
log_sudo_command_output "snap install code --classic"
log_sudo_command_output "apt-get install git"
log_sudo_command_output "apt-get install tlp"
log_sudo_command_output "apt-get install grsync"
log_sudo_command_output "apt-get install adb"
log_sudo_command_output "apt-get install filezilla"
log_sudo_command_output "apt-get install protonvpn"
log_sudo_command_output "apt-get install mplayer"
log_sudo_command_output "apt-get install feh"
log_sudo_command_output "apt-get install simple-scan"

echo "Make Desktop actually usable"
log_sudo_command_output "apt-get install nemo"
log_sudo_command_output "add-apt-repository universe"
log_sudo_command_output "apt update"
log_sudo_command_output "apt install dconf-cli dconf-editor"
log_sudo_command_output "apt install gnome-shell-extensions"

log_command_output "gsettings set org.gnome.desktop.background show-desktop-icons false"
log_command_output "xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search"

log_command_output "mkdir ~/.config/autostart"

echo "[Desktop Entry]
Type=Application
Exec=nemo-desktop
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Nemo Desktop
Name=Nemo Desktop
Comment[en_US]=
Comment=" > /home/$user_name/.config/autostart/nemo-desktop.desktop

echo "Don't forget to turn off the Desktop icons from the Extensions app! Sometimes Desktop icons can be on top each other."
read -p "Press enter to continue"

while true; do
	read -p "Do you wish to download and add the scrips to autostart?" yn
	case $yn in
	[Yy]* ) 
        	git -C ~/ clone https://github.com/ermanergoz/scripts.git
       	chmod +x ~/scripts/*.sh
        
      		echo "[Desktop Entry]
Type=Application
Exec=/home/$user_name/scripts/automate-gnome-night-light.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=automate-gnome-night-light
Name=automate-gnome-night-light
Comment[en_US]=
Comment=" > /home/$user_name/.config/autostart/automate-gnome-night-light.sh.desktop

		echo "[Desktop Entry]
Type=Application
Exec=/home/$user_name/scripts/kill-bluetooth.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=kill-bluetooth
Name=kill-bluetooth
Comment[en_US]=
Comment=" > /home/$user_name/.config/autostart/kill-bluetooth.sh.desktop

         break;;
         
		[Nn]* ) break;;
		* ) echo "Just answer yes or no.";;
	esac
done

log_sudo_command_output "apt-get update"
log_sudo_command_output "apt-get upgrade"
log_sudo_command_output "apt autoremove --purge"
log_sudo_command_output "apt autoclean"
log_sudo_command_output "apt clean"

read -p "All done! Press enter to restart the computer"
reboot

