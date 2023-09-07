#!/bin/bash

#########################
## Shutdown the instance
## via cron, but only if
## no one is logged in
##
## By: Shlomo Dubrowin
## Date: Jun 20, 2018
#########################

#########################
## Variables
#########################
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"
TAG="$( basename "$0" )"
TUSER="ubuntu"
#IDLEMIN="5"
IDLEMIN="15"

CONFIG="/home/$TUSER/.$( basename "$0" )"
#CONFIG="/home/ubuntu/.daily-shutdown.sh"
DEBUG="Y"

#########################
## Functions
#########################
function Debug {
        if [ "$DEBUG" == "Y" ]; then
                if [ ! -z "$CRON" ]; then
                        # Cron, output only to log
                        #echo -e "$( date +"%b %d %H:%M:%S" ) $1" >> $LOG
                        logger -t $TAG "$$ running $SECONDS secs: $1"
                else
                        # Not Cron, output to CLI and log
                        logger -t $TAG "$$ running $SECONDS secs: $1"
                        echo -e "$( date +"%b %d %H:%M:%S" ) $$ running $SECOINDS secs: $1" 
                fi
        fi
}

#########################
## Main Code
#########################
#STATUS=`w | grep -c $TUSER`

## Check No Off Configuration
#########################

#Debug "CONFIG $CONFIG"
#Debug "Pre NOOFF $NOOFF"
if [ -f $CONFIG ]; then
	source $CONFIG
	#Debug "NOOFF $NOOFF"
	NOOFFSTART=`echo $NOOFF | cut -d - -f 1`
	NOOFFEND=`echo $NOOFF | cut -d - -f 2`
	#Debug "NOOFFSTART $NOOFFSTART NOOFFEND $NOOFFEND"
	OFFSTART=`date --date="$NOOFFSTART" +"%s"`
	OFFEND=`date --date="$NOOFFEND" +"%s"`
	OFFNOW=`date +"%s"`
	#Debug "OFFSTART $OFFSTART OFFNOW $OFFNOW OFFEND $OFFEND"
	if [ $OFFSTART -lt $OFFNOW ] && [ $OFFNOW -lt $OFFEND ]; then
        	Debug "We are in the Configured No Off Period ($NOOFF) in $CONFIG. Exiting"
	else
        	Debug "Not in Configured No Off Period ($NOOFF) from $CONFIG. Fire away"
	fi
else
	Debug "$CONFIG file not found, skipping"
fi

## Main Check
#########################
Debug "Idle Minutes set to IDLEMIN $IDLEMIN"

SCREENSTAT=`w | grep ":pts" -c`

if [ $SCREENSTAT -gt 0 ]; then
	Debug "Screen Detected, limiting to screen sessions"
	STAT=`w | grep "^$TUSER" | grep ":pts" | grep -v days | sort -n -k 5 | awk '{print $5}' | head -n 1`
	STATUS=`echo $STAT | cut -d \. -f 1 | cut -d \: -f 1`
	SEC=`echo $STAT | grep "s$" -c`
	TUSERCNT=`w | grep ":pts" | grep -c "^$TUSER"`
else
	STAT=`w | grep "^$TUSER" | grep -v days | sort -n -k 5 | awk '{print $5}' | head -n 1`
	STATUS=`echo $STAT | cut -d \. -f 1 | cut -d \: -f 1`
	SEC=`echo $STAT | grep "s$" -c`
	TUSERCNT=`w | grep -c "^$TUSER"`
fi

if [ "$STATUS" -ge "$IDLEMIN" ] || [ -z "$STAT" ]; then
        if [ "$STATUS" == "0" ]; then
                Debug "STATUS is set specifically to 0 ($STATUS), therefore, not shutting down"
        else
                # "user attached, not shutting down"
                Debug "No users (user: $TUSER) found logged in (login count: $TUSERCNT), shutting down the instance for the night (STATUS: $STATUS) (STAT: $STAT)"
                sleep 0
                shutdown -h now
        fi
else
        # "user NOT attached, would shut down"
        w | grep $TUSER > /tmp/$TAG.$$.log
        Debug "User (user: $TUSER) found logged in (login count: $TUSERCNT), NOT shutting down yet for the night (STATUS: $STATUS) (STAT: $STAT) (Details in /tmp/$TAG.$$.log)"
fi

#if [ "$STATUS" -eq "0" ]; then
	## "user attached, not shutting down"
	#logger -t $TAG "No users ($TUSER) found logged in, shutting down the instance for the night ($STATUS)"
	#shutdown -h now
#else
	## "user NOT attached, would shut down"
	#w | grep $TUSER > /tmp/$TAG.$$.log
	#logger -t $TAG "User ($TUSER) found logged in, NOT shutting down yet for the night ($STATUS)"
#fi
