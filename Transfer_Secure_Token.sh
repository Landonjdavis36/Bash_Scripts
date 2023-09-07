#!/bin/bash

#=========================================================================    
#    
#Log Location.
#
#=========================================================================
logfile="/var/log/GiveAdminSecureToken.log"
#=========================================================================    
#    
#JAMF binary assigned to variable.
#
#=========================================================================
jamfbinary=$(/usr/bin/which jamf)

#========================================================================

api_pass="" # Encrypted apiUser Password
api_user="apiUser" #API Username

udid=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID:/ { print $3 }')

function DecryptString() {
    # Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
    echo "${1}" | /usr/bin/openssl enc -md md5 -aes256 -d -a -A -S "${2}" -k "${3}"
}

api_pwd=$(DecryptString "$api_pass" "" "")

xml=$(curl -s -k -u "${api_user}:${api_pwd}" -H "Content-Type: text/xml" -X GET "[YOUR_DOMAIN]/JSSResource/computers/udid/$udid")

#=========================================================================    
#    
#Store some of the usernames and passwords from JAMF to variables.
#xpath syntax changed with big sur, so an if statement is required to grab it from the right spot.
#
#=========================================================================
if [[ $(sw_vers -buildVersion) > "20A" ]]; then
    adminusername=$(echo $xml | xpath -q -e "//*[name='Local Admin Username']/value/text()")
    adminpassword=$(echo $xml | xpath -q -e "//*[name='Local Admin Password']/value/text()")
    username=$(echo $xml | xpath -q -e "//*[name='Manually Created User - Username']/value/text()")
    password=$(echo $xml | xpath -q -e "//*[name='Manually Created User - Password']/value/text()")
else
    adminusername=$(echo $xml | xpath "//computer/extension_attributes/extension_attribute[name='Local Admin Username']/value/text()" 2&> /dev/null)
    adminpassword=$(echo $xml | xpath "//computer/extension_attributes/extension_attribute[name='Local Admin Password']/value/text()" 2&> /dev/null)
    username=$(echo $xml | xpath "//computer/extension_attributes/extension_attribute[name='Manually Created User - Username']/value/text()" 2&> /dev/null)
    password=$(echo $xml | xpath "//computer/extension_attributes/extension_attribute[name='Manually Created User - Password']/value/text()" 2&> /dev/null)
fi

#Check if user is already a secure token holder
if dscl . -read /Users/$username AuthenticationAuthority | grep -q "SecureToken"; then
echo "User already has a secure token."
exit 0
fi

#Get current secure token holder username
secure_token_holder=$(dscl . -list /Users | grep -v _ | grep -v "guest" | while read user; do dscl . -read /Users/$adminusername AuthenticationAuthority | grep -q "SecureToken" && echo $adminusername; done)

#Give current user the secure token
sudo sysadminctl -secureTokenOn $username -password $password

#Verify that user now has a secure token
if dscl . -read /Users/$username AuthenticationAuthority | grep -q "SecureToken"; then
echo "Successfully gave $username a secure token."
else
echo "Failed to give $username a secure token."
fi
