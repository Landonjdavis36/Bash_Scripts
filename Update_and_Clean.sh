#!/bin/bash
softwareupdate -i -a
brew update && brew upgrade && brew cleanup
echo "System updated and cleaned."
