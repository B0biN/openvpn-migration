#!/bin/bash

## settings
# backup destination
backup_destination="/home/root/vpn_migration/_backup"

# custom backup file
custom_backup_file="CCcam.cfg"

# backup source
backup_source1="/etc/openvpn/ /etc/$custom_backup_file"
backup_source2="/usr/sbin/openvpn"

# backup status
#backup_status_file="$backup_destination/.status"
#backup_status=$(cat "$backup_status_file")

# kernel architecture (mips or armv71)
cpu_type=$(uname -m)

# binary location
bin_dir_location="/usr/sbin/"

# logfile
logs="/home/root/vpn_migration/_logs/backup.log"

# date
d="[`date '+%F %T'`]"

## functions
# backup function
do_backup () {
  echo "$d Creating backup" >> $logs
  mkdir -p $backup_destination/current/etc
  mkdir -p $backup_destination/current/usr/sbin/openvpn
  cp -r $backup_source1 $backup_destination/current/etc
  cp -r $backup_source2 $backup_destination/current/usr/sbin/openvpn
#  echo "1" > $backup_destination/.status
  echo "$d Backup successfully created" >> $logs
  echo "$d Backup successfully created"
}

check_backup () {
  if [ ! -d $backup_destination/current ]; then
    do_backup
  else
	echo "$d Backup successfully exist... canceled" >> $logs
	echo "Backup successfully exist... canceled."
  fi
}

# set binary file function 
binary_file_is () {
  if [ "$cpu_type" = "mips" ]; then
    bin_file_is="/home/root/vpn_migration/binaries/mips/openvpn"
  else
    bin_file_is="/home/root/vpn_migration/binaries/arm71/openvpn"
  fi
}

# check openvpn running
openvpn_running () {
  if [ -f /var/run/openvpn.client.pid ]; then
	openvpn_pid=$(cat /var/run/openvpn.client.pid)
	echo "$d OpenVPN is running (pid id: $openvpn_pid)" >> $logs
	echo "OpenVPN is running (pid id: $openvpn_pid)."
	openvpn_running="1"
  else
	echo "$d openvpn is not running" >> $logs
	echo "OpenVPN is not running."
	openvpn_running="0"
  fi
}

# pokracujeme function
pokracujeme () {
  echo $cpu_type
}

# load functions
check_backup
binary_file_is
openvpn_running
#echo $bin_file_is
echo $openvpn_running