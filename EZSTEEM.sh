#!/bin/bash
#Main interface for all scripts used in setup and mining
#made by steemit users @omotherhen and @gikitiki

#check if a configuration file exists for ezsteem and whether it can be modified
myConfig="/etc/ezsteem.conf"

if [ ! -e $myConfig ]; then
   myBaseDir="/var/EZSTEEM" 
fi

#source the config file
. "$myConfig"




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
  0) echo "Exiting..."
     exit 0 
  ;;
  esac
exit 0
