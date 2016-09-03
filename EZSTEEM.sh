#!/bin/bash
#Main interface for all scripts used in setup and mining
#made by steemit users @omotherhen and @gikitiki

#check if a configuration file exists for ezsteem and whether it can be modified
myConfig="/etc/ezsteem.conf"
if [ ! -e $myConfig ]; then
   sudo -s touch "$myConfig"
fi

#source the config file
. "$myConfig"

#set the Base Directory to be the directory that EZSTEEM.sh is being run from
myNewBaseDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Auto update script on run
sudo -s git pull
clear

#check if the default path is set
if [ -z ${myBaseDir+x} ];
then
   #if not, add it to the configuration file
   echo "Updating config file with base directory path"
   sudo -s bash -c "echo myBaseDir=\"$myNewBaseDir\" >> $myConfig"
   #if it is not, then this is likely the first time running.
   #Change Ownership of the Base Directory
   myBaseDir="$myNewBaseDir"
   echo "Changing ownership of base directory"
   sudo -s chown -R $USER $myBaseDir
   
else
   #if it exists, set it to the directory where EZSTEEM.sh is being run from
   #check to see if they are the same
   if [ $myBaseDir != $myNewBaseDir ];
   then
      myBaseDir="$myNewBaseDir"
      sudo -s sed -i "s|myBaseDir=.*$|myBaseDir=$myBaseDir|" "$myConfig"
   fi
fi

#check if myConfigFile is set
if [ -z ${myConfigFile+x} ];
then
   sudo -s bash -c "echo myConfigFile=\"$myBaseDir/steem/programs/steemd/witness_node_data_dir/config.ini\" >> $myConfig"
fi

   sudo -s chown -R $USER $myBaseDir


clear

pnkl="echo -e \e[95m"
whtl="echo -e \e[97m"
redl="echo -e \e[91m"

pnk="\e[95m"
wht="\e[97m"
red="\e[91m"
e="echo -e"


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
$e "$pnk 7) $wht Set EZSTEEM to automatically run when user logs in."
$e "$pnk 8) $wht Start cli_wallet, start this before transferring Steem Power!"
$e "$pnk 9) $wht Transfer your mined Steem Power or modify/add your miners"
$e "$pnk 10) $wht Setup a screen split via Byobu"
$e "$pnk 0) $wht Exit"

echo

choice=""
while true 
do
  read -p "Enter your choice here: " choice
  echo $choice | grep -q "^[0-9]"
  if [ $? -eq 0 ] 
   then
   break
  fi
done


case $choice in

  1) echo "Full install for mining Steem selected"
    sudo -s bash  $myBaseDir/bin/minerScript.sh
  ;;
  2) echo "Cloned machine configuration selected"
    sudo -s bash $myBaseDir/bin/clonedMiner.sh
  ;;
  3) echo "Full install for running a Steem node selected"
    sudo -s bash $myBaseDir/bin/nodeScript.sh
  ;;
  4) echo "Steem recompile selected"
    sudo -s bash $myBaseDir/bin/recompile.sh
  ;;
  5) echo "Blockchain redownload && bootstrap selected"
    sudo -s bash $myBaseDir/bin/refreshBlkChain.sh
  ;;
  6) cd "$myBaseDir/steem/programs/steemd"
      sudo -s ./steemd
  ;;
  7) echo "Enabling EZSTEEM AutoRun"
    sudo -s bash $myBaseDir/bin/setautorun.sh
  ;;
  8) echo "Starting cli_wallet"
     cd $myBaseDir/steem/programs/cli_wallet && sudo -s ./cli_wallet -r -d 
  ;;
  9) echo "Starting ezWallet.js"
     clear
     sudo -s nodejs $myBaseDir/js/ezWalletMenu.js
  ;;
  10) echo "Setting up screen split"
     clear
     bash $myBaseDir/bin/byobuSetup.sh
  ;;
  0) echo "Exiting..."
     exit 0 
  ;;
  esac
exit 0
