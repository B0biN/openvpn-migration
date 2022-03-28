@ECHO OFF 
:: setings
set box_ip="192.168.88.109"
set plink="%USERPROFILE%\Documents\GIT\openvpn-migration\_tools\plink.exe"
set pscp="%USERPROFILE%\Documents\GIT\openvpn-migration\_tools\pscp.exe"
set source_dir="%USERPROFILE%\Documents\GIT\openvpn-migration"
set destination_dir="/home/root/openvpn-migration"
GOTO:MAIN

:: checking
:plink_check
ECHO [ Kontrola dostupnosti plink.exe ]
if exist %plink% (
    echo [ plink.exe existuje ]
    GOTO:pscp_check
    ) else (
    echo [ !!! plink.exe neexistuje, zkontrolujte nastaveni cesty k souboru plink.exe !!! ]
    GOTO:EOF
    )
:pscp_check
ECHO [ Kontrola dostupnosti pscp.exe ]
if exist %pscp% (
    echo [ pscp.exe existuje ]
    GOTO:ACTION
    ) else (
    echo [ !!! pscp.exe neexistuje, zkontrolujte nastaveni cesty k souboru pscp.exe !!! ]
    GOTO:EOF
    )

:: actions
:ACTION
ECHO [ Povoluji opraveneni pres SSH ]
echo yes | %plink% -ssh root@%box_ip% date
ECHO [ Vytvarim vzdalene adresare "openvpn-migration a _logs" ]
%plink% -ssh -batch root@%box_ip% mkdir -p %destination_dir% %destination_dir%/_logs
ECHO [ Kopiruji soubory "binaries" ]
%pscp% -scp -batch -r %source_dir%\binaries root@%box_ip%:%destination_dir%
ECHO [ Kopiruji soubory "vpn_files" ]
%pscp% -scp -batch -r %source_dir%\vpn_files root@%box_ip%:%destination_dir%
ECHO [ Kopiruji soubory "scripts" ]
%pscp% -scp -batch -r %source_dir%\scripts root@%box_ip%:%destination_dir%
ECHO [ Zmena kodovani pro "migration.sh" skript ]
%plink% -ssh -batch root@%box_ip% dos2unix %destination_dir%/scripts/migration.sh
ECHO [ Nastaveni execute pro "migration.sh" skript ]
%plink% -ssh -batch root@%box_ip% chmod +x %destination_dir%/scripts/migration.sh
ECHO [ Spoustim migracni skript "migration.sh" ]
%plink% -ssh -batch root@%box_ip% %destination_dir%/scripts/migration.sh &
GOTO:EOF

:test
ECHO [ Soucasna IP adresa ]
%plink% -ssh root@%box_ip% "ip addr | grep tun0 | grep inet | awk '{print $2}' | cut -d "/" -f 1"
GOTO:EOF

:MAIN
call:plink_check

:EOF
echo [ end ]
pause
exit /b