#!/bin/bash
#made by steemit users @omotherhen and @gikitiki

#check if a configuration file exists for ezsteem and whether it can be modified
myConfig="/etc/ezsteem.conf"

if [ ! -e $myConfig ]; then
   myBaseDir="/var/EZSTEEM"
fi

#source the config file
. "$myConfig"

#check if the default path is set
if [ -z ${myBaseDir+x} ];
then
   echo "BaseDir is unset";
   InstallDefault="/var/EZSTEEM"
   read -p "Where would you like the Installation Directory? [$InstallDefault]: " myBaseDir
   myBaseDir="${myBaseDir:-$InstallDefault}"
   #update the config file
   echo "myBaseDir=\"$myBaseDir\"" >> $myConfig
fi

#make the base directory if it doesn't exist
mkdir -p "$myBaseDir"


#be polite  ask if they want ezsteem added to the path
while true; do
   read -p "CONFIRM : Enable EZSTEEM autorun? [y or N] : " myResponse
   case "$myResponse" in
      [Yy]* ) echo "\"$myBaseDir/firstTimeMiningInstall/EZSTEEM.sh\"" >> ~/.bashrc; break;;
      [Nn]* ) break;;
      * ) echo "Please answer y or n";;
   esac
done

