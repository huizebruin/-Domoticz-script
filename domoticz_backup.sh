#!/bin/bash

# LOCAL/FTP/SCP/MAIL PARAMETERS
SERVER="192.168.178.129"               # IP-adres:Port van je FTP server
USERNAME="wobbe"             # Gebruikersnaam voor FTP
PASSWORD="Molenweg55"             # Wachtwoord voor FTP
DESTDIRNAS="/Download/"           # Locatie op je FTP voor de Backup
DOMO_IP="192.168.178.234"              # IP adres van je Domoticz server
DOMO_PORT="8080"            # Poort van je Domoticz server
    ### END OF USER CONFIGURABLE PARAMETERS
    TIMESTAMP=`/bin/date +%Y%m%d%H%M%S`
    BACKUPFILE="domoticz_$TIMESTAMP.db" # backups will be named "domoticz_YYYYMMDDHHMMSS.db.gz"
    BACKUPFILEGZ="$BACKUPFILE".gz
    ### Stop Domoticz, create backup, ZIP it and start Domoticz again
    ##service domoticz.sh stop
    /usr/bin/curl -s http://$DOMO_IP:$DOMO_PORT/backupdatabase.php > /tmp/$BACKUPFILE
    service domoticz.sh start
    gzip -9 /tmp/$BACKUPFILE
    ### Send to Network disk through FTP
    curl -s --disable-epsv -v -T"/tmp/$BACKUPFILEGZ" -u"$USERNAME:$PASSWORD" "ftp://192.168.178.129/../Download/Domoticz/"				
    ### Remove temp backup file
    /bin/rm /tmp/$BACKUPFILEGZ
    ### Done!
    
