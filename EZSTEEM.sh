#!/bin/bash
#Main interface for all scripts used in setup and mining
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











clear

pnkl="echo -e \e[95m"
whtl="echo -e \e[97m"
redl="echo -e \e[91m"

pnk="\e[95m"
wht="\e[97m"
red="\e[91m"
e="echo -e"

#sudo cp ./onStart/EZSTEEM.service /etc/systemd/system
#sudo systemctl enable EZSTEEM.service
#sudo chmod u+x ./EZSTEEM.sh

$pnkl "---------------------------------------------------------------------------------------"
$pnkl "------------------------------WELCOME TO EZSTEEM SUITE---------------------------------"
$pnkl "---------------------------------------------------------------------------------------"
echo
$whtl "What would you like to do today?"
echo

$e "$pnk 1) $wht Do a full install for mining Steem"
$e "$pnk 2) $wht (FOR CLONED MINERS ONLY!!) Configure your steem miner for the cloned machine"
$e "$pnk 3) $wht Do a full install for running a Steem Node"
$e "$pnk 4) $wht Recompile your Steem miner or Steem Node with the latest version of Steem"
$e "$pnk 5) $wht Redownload a blockchain and bootstrap your Steem Miner or Steem Node"
$e "$pnk 6) $wht Start mining or start your node!"
$e "$pnk 0) $wht Exit"

echo

choice=""
while true 
do
  read -p "Enter your choice here: " choice
  echo $choice | grep -q "^[0-7]"
  if [ $? -eq 0 ] 
   then
   break
  fi
done


case $choice in

  1) echo "Full install for mining Steem selected"
    bash ./bin/minerScript.sh
  ;;
  2) echo "Cloned machine configuration selected"
    bash ./bin/clonedMiner.sh
  ;;
  3) echo "Full install for running a Steem node selected"
    bash ./bin/nodeScript.sh
  ;;
  4) echo "Steem recompile selected"
    bash ./bin/recompile.sh
  ;;
  5) echo "Blockchain redownload && bootstrap selected"
    bash ./bin/refreshBlkChain.sh
  ;;
  6) cd "$myBaseDir/steem/programs/steemd"
      ./steemd
  ;;
  7)
  ;;
  0) echo "Exiting..."
     exit 0 
  ;;
  esac
exit 0
