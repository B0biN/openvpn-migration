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
logs="/home/root/vpn_migration/_logs/migration.log"

# new vpn user's files directory
new_vpn_files="/home/root/vpn_migration/vpn_files"

# date
d="[`date '+%F %T'`]"

## functions
# backup function
do_backup () {
  echo "$d Vytvarim zalohu" >> $logs
  echo "Vytvarim zalohu."
  mkdir -p $backup_destination/current/etc
  mkdir -p $backup_destination/current/usr/sbin/openvpn
  cp -r $backup_source1 $backup_destination/current/etc
  cp -r $backup_source2 $backup_destination/current/usr/sbin/openvpn
#  echo "1" > $backup_destination/.status
  echo "$d Zaloha byla uspesne vytvorena" >> $logs
  echo "Zaloha byla uspesne vytvorena."
}

check_backup () {
  if [ ! -d $backup_destination/current ]; then
    do_backup
  else
	echo "$d Zaloha jiz existuje... storno." >> $logs
	echo "Zaloha jiz existuje... storno."
  fi
}

# set binary file function 
binary_file_is () {
  if [ "$cpu_type" = "mips" ]; then
    bin_file_is="/home/root/vpn_migration/binaries/mips/openvpn"
	echo "$d Hardware je mips" >> $logs
	echo "Hardware je mips."
  else
    bin_file_is="/home/root/vpn_migration/binaries/arm71/openvpn"
	echo "$d Hardware je arm71" >> $logs
	echo "Hardware je mips arm71."
  fi
}

# check openvpn running
openvpn_running () {
  if [ -f /var/run/openvpn.client.pid ]; then
	openvpn_pid=$(cat /var/run/openvpn.client.pid)
	echo "$d OpenVPN bezi (pid id: $openvpn_pid)" >> $logs
	echo "OpenVPN bezi (pid id: $openvpn_pid)."
	openvpn_running="1"
	do_migrate="0"
  else
	echo "$d OpenVPN neni spusteny" >> $logs
	echo "OpenVPN neni spusteny."
	openvpn_running="0"
	do_migrate="1"
  fi
}

# parse name of client's filename from client.conf
get_client_filename () {
  if [ -f $new_vpn_files/client.conf ]; then
	client_crt=$(cat $new_vpn_files/client.conf | grep client | grep .crt | sed "s/.*\///")
	client_key=$(cat $new_vpn_files/client.conf | grep client | grep .key | sed "s/.*\///")
  else
	echo "$d Spatny format nebo neexistujici soubor client.conf" >> $logs
	echo "Spatny format nebo neexistujici soubor client.conf."
	exit
  fi
}

# check new vpn user's files
check_new_vpn_files () {
  if [ -f $new_vpn_files/ca.crt ] && [ -f $new_vpn_files/ta.key ]; then
    echo "$d Uzivatelske soubory pro OpenVPN existuji" >> $logs
	echo "Uzivatelske soubory pro OpenVPN existuji."
	do_migrate="1"
  else
    echo "$d Nektere soubory neexistuji zkontroluj adresar $new_vpn_files." >> $logs
	echo "Nektere soubory neexistuji zkontroluj adresar $new_vpn_files."
	do_migrate="0"
	exit
  fi
}

stop_openvpn () {
  if [ "$openvpn_running" = "1" ]; then
	echo "$d Zastavuji proces OpenVPN (pid id: $openvpn_pid)" >> $logs
	echo "Zastavuji proces OpenVPN (pid id: $openvpn_pid)"
	/etc/init.d/openvpn stop
	openvpn_running="0"
  else
	echo "$d OpenVPN nebezi." >> $logs
	echo "OpenVPN nebezi."
	exit
  fi
}

rm_and_cp_files () {
  if [ "$openvpn_running" = "0" ]; then
	echo "$d Mazu a kopiruji nove soubory" >> $logs
	echo "Mazu a kopiruji nove soubory."
	rm -r /etc/openvpn/*
	cp $new_vpn_files/* /etc/openvpn/
	rm /usr/sbin/openvpn
	cp $bin_file_is /usr/sbin/
	chmod +x /usr/sbin/openvpn
	/etc/init.d/openvpn start
  else
	echo "$d OpenVPN stale bezi" >> $logs
	echo "OpenVPN stale bezi."
	exit
  fi
}


run_migration () {
  if [ "$do_migrate" = "1" ]; then
	echo "$d Spoustim migraci" >> $logs
	echo "Spoustim migraci OpenVPN."
	echo $do_migrate
	stop_openvpn
	rm_and_cp_files
  else
    echo "$d Neco neni v poradku... migrace pozastavena!" >> $logs
	echo "Neco neni v poradku... migrace pozastavena!"
	exit
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
#get_client_filename
check_new_vpn_files
#pokracujeme
#echo $do_migrate
run_migration


