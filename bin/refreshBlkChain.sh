#!/bin/bash
#made by steemit users @omotherhen and @gikitiki

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







echo "Boot-strapping blockchain for fast setup, then starting the miner!"
cd "myBaseDir/steem/programs/steemd/witness_node_data_dir/blockchain/database/" && rm -f *.zip && wget http://einfachmalnettsein.de/steem-blocks-and-index.zip && unzip -o steem-blocks-and-index.zip 

