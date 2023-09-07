#!/bin/zsh

# This script systematically validates that an account exists locally, checks for it on JAMF, and creates one if it's missing. 
# Doing so requires "admin" (the 2nd token user) to be available. If it's not there, this doesn't accommodate for it.

# Log Location.
logfile="/var/log/randomize_manually_created_user_password.log"

# JAMF binary assigned to variable.
jamfbinary=$(/usr/bin/which jamf)

# JSS Parameter Variables.
default_pass="" # Encrypted Default user Password
api_pass="" # Encrypted apiUser Password
api_user="" #API Username

# Get unique identifier of the machine.
udid=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID:/ { print $3 }')

# Function for decrypting strings.
function DecryptString() {
    # Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
    echo "${1}" | /usr/bin/openssl enc -md md5 -aes256 -d -a -A -S "${2}" -k "${3}"
}

# These variables are blank until successful.
username=""
password=""

# Decrypt the passwords used in this script.
default_pwd=$(DecryptString "$default_pass" "")
api_pwd=$(DecryptString "$api_pass" "")

# See if the password for Admin is already saved in JAMF.
xml=$(curl -s -k -u "${api_user}:${api_pwd}" -H "Content-Type: text/xml" -X GET "https://[YOUR_DOMAIN]/JSSResource/computers/udid/$udid")

# Store some of the usernames and passwords from JAMF to variables. 
# xpath syntax changed with big sur, so an if statement is required to grab it from the right spot.
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

# Create new password using randomize and base64. We won't call this for a while, but it's now available.
new_password=$(/usr/bin/openssl rand -base64 9) 

# Create the log, post the date.
echo "Policy last run on $(date)" > $logfile

# If the password isn't blank (has a value) on JAMF, note in the log.
if ! [[ $password == "" ]]; then
    echo "Local Admin Password has a value on JAMF already for $username." >> $logfile
else
    echo "Looks like the password is blank, or nonexistent." >> $logfile
fi

# Check if admin is available locally.
echo "Preparing to check for admin user profile locally..." >> $logfile

# If local admin does or doesn't exist, log it.
exists=$(dscl . list /Users | grep admin) # Checks for admin on the local machine.

if [[ $exists == "admin" ]]; then  # Pop the results in the log. Not acting on it yet.
    echo "admin user DOES exist locally on the device already." >> $logfile
else
    echo "admin user DOES NOT exist locally on the device already." >> $logfile
fi

# ... [The rest of the script continues here]

