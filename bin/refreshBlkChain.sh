#!/bin/bash
#made by steemit users @omotherhen and @gikitiki

clear

pnkl="echo -e \e[95m"
whtl="echo -e \e[97m"
redl="echo -e \e[91m"

pnk="\e[95m"
wht="\e[97m"
red="\e[91m"
e="echo -e"

$pnkl "---------------------------------------------------------------------------------------"
$pnkl "------------------------WELCOME TO EZSTEEM BLOCKCHAIN RESYNC---------------------------"
$pnkl "---------------------------------------------------------------------------------------"
$whtl

#check if a configuration file exists for ezsteem and whether it can be modified
myConfig="/etc/ezsteem.conf"

if [ ! -e $myConfig ]; then
   touch "$myConfig"
fi
if [ ! -w "$myConfig" ]; then
   echo "Can not write to $myConfig"
   echo "Please run script using : "
   echo "sudo bash ${0}"
   exit 1
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


$pnkl "Boot-strapping blockchain for fast setup, then starting the miner!"
$whtl
cd "myBaseDir/steem/programs/steemd/witness_node_data_dir/blockchain/database/" && rm -f *.zip && wget http://einfachmalnettsein.de/steem-blocks-and-index.zip && unzip -o steem-blocks-and-index.zip
rm -f steem-blocks-and-index.zip

clear
$pnkl "---------------------------------------------------------------------------------------"
$pnkl "-----------------------------------------Done!-----------------------------------------"
$pnkl "---------------------------------------------------------------------------------------"
$whtl
