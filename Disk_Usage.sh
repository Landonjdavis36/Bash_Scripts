#!/bin/bash
MAX=90
USAGE=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')
if [ "$USAGE" -gt "$MAX" ]; then
    osascript -e 'display notification "Disk space running low!" with title "Disk Space Alert"'
fi
