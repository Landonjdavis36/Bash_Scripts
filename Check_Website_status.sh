#!/bin/bash
WEBSITE="http://example.com"
STATUS=$(curl -s -o /dev/null -w '%{http_code}' $WEBSITE)
if [ "$STATUS" -eq "200" ]; then
    osascript -e 'display notification "Website is up." with title "Website Status"'
else
    osascript -e 'display notification "Website is down." with title "Website Status"'
fi
