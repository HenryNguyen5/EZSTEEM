#!/bin/bash
sudo apt-get -y install byobu 
cp -r /var/EZSTEEM/byobuConf/.byobu ~
BYOBU_WINDOWS=ezsteem byobu 
