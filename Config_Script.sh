#!/usr/local/bin/python3

#################################
# Configuration Script
# Created in June 2021
# by [REDACTED]
#################################

import os
import subprocess
from subprocess import Popen, PIPE, STDOUT
from datetime import datetime
from os import path
import time

# Variables
# get location of Jamf Binary
proc_get_jamf = subprocess.run(["/usr/bin/which", "jamf"], capture_output=True)
jamf_binary = proc_get_jamf.stdout.decode('ascii').rstrip()
log_file_path = "/var/log/timestamps.log"
error_log_file_path = "/var/log/config_setup_error.log"
config_version = "[REDACTED]"
dep_notify_cmd_file_path = "/var/tmp/depnotify.log"

# Logging Functions
# ... [Logging functions remain unchanged]

# DEPNotify Command Function
# ... [DEPNotify function remains unchanged]

# Install Function
# Installs programs using jamf policies, then verifies them
# Param: readable_name, install_trigger, install_path(optional), depnotify_string(Human readable)
def install(readable_name, install_trigger, install_path, depnotify_string):
    # ... [Install function remains unchanged]

# Cleanup function
# Get rid of splashbuddy and go back to the previous script to restart
def cleanup():
    # ... [Cleanup function remains unchanged]

# Begin logging
log_init()

# Install DEPNotify
install("[REDACTED]", "[REDACTED]", "[REDACTED]", "[REDACTED]")

#Initialize DEPNotify
# ... [Initialization remains unchanged]

# Disable sleep mode
# ... [Sleep mode function remains unchanged]

# List of programs to install
# This is the only part that should ever need to change except the config version in the previous line
# -----------------------------------------------------
install("[REDACTED]", "[REDACTED]", "[REDACTED]", "[REDACTED]")
# ... [Other installations remain unchanged]

# -------------------- system preferences---------------------------------
# ... [System preferences functions remain unchanged]

# -----------------------------------------------------
# ... [Re-enabling sleep mode remains unchanged]

# End logging and cleanup
log_end()
cleanup()
