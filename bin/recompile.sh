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


cd "$myBaseDir/steem"
git fetch
git checkout v0.12.1
rm -f CMakeCache.txt
make -s clean > /dev/null
cmake -DCMAKE_BUILD_TYPE=Release-DLOW_MEMORY_NODE=ON .
make --silent 
clear
echo -e "\e[5mDone!\e[25m"
exit 0

