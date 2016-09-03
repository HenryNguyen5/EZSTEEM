#!/bin/bash
clear

pnkl="echo -e \e[95m"
whtl="echo -e \e[97m"
redl="echo -e \e[91m"

pnk="\e[95m"
wht="\e[97m"
red="\e[91m"
e="echo -e"

#check if a configuration file exists for ezsteem and whether it can be modified
myConfig="/etc/ezsteem.conf"

if [ ! -e $myConfig ]; then
   touch "$myConfig"
   if [ ! -w "$myConfig" ]; then
      echo "Can not write to $myConfig"
      echo "Please run script using : "
      echo "sudo bash ${0}"
      exit 1
   fi
fi

#source the config file
. "$myConfig"

$pnkl "---------------------------------------------------------------------------------------"
$pnkl "----------------------------WELCOME TO EZSTEEM BYOBU SETUP------------------------------"
$pnkl "---------------------------------------------------------------------------------------"
$whtl
echo

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
   read -p "Would you like to be able to be able to run EZSTEEM from any directory? [y or N] : " myResponse
   case "$myResponse" in
      [Yy]* ) echo "export PATH=\"$myBaseDir/EZSTEEM:\$PATH\"" >> ~/.bashrc; break;;
      [Nn]* ) break;;
      * ) echo "Please answer y or n";;
   esac
done

sudo apt-get -y install byobu 
cp -r "$myBaseDir/byobuConf/.byobu" ~
