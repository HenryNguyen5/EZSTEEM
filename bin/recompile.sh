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

$pnkl "---------------------------------------------------------------------------------------"
$pnkl "----------------------------WELCOME TO EZSTEEM RECOMPILE-------------------------------"
$pnkl "---------------------------------------------------------------------------------------"
$whtl

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

#determine how many cores to use when building the miner
myMemTotal=$(awk '/MemTotal/' /proc/meminfo|awk '{print $2}')
myCoreCount=2

if [ "$myMemTotal" -lt  "4028944" ] ; then
   myCoreCount=1
else
   if [ "$myMemTotal" -gt  "6093327" ] ; then
      myCoreCount=4
   fi
fi



cd "$myBaseDir/steem"
sudo -s git fetch
sudo -s git checkout v0.13.0
sudo -s git submodule update --recursive
sudo -s git cherry-pick 2096e96eb97e4c85c0c9445ff8f0156c5ac2a620
sudo -s git cherry-pick a8f34fe0e85aba4613037d895b02f3a108229b11
sudo -s rm -f CMakeCache.txt
sudo -s make -s clean > /dev/null
sudo -s cmake -DCMAKE_BUILD_TYPE=Release -DLOW_MEMORY_NODE=ON .
sudo -s make --silent -j "$myCoreCount"

clear
$pnkl "---------------------------------------------------------------------------------------"
$pnkl "-----------------------------------------Done!-----------------------------------------"
$pnkl "---------------------------------------------------------------------------------------"
$whtl
exit 0

