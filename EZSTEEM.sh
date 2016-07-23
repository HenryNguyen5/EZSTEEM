#!/bin/bash
#Main interface for all scripts used in setup and mining
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
$e "$pnk 2) $wht (FOR CLONED MINRES ONLY!!) Configure your steem miner for the cloned machine"
$e "$pnk 3) $wht Do a full install for running a Steem Node"
$e "$pnk 4) $wht Recompile your Steem miner or Steem Node with the latest version of Steem"
$e "$pnk 5) $wht Redownload a blockchain and bootstrap your Steem Miner or Steem Node"
echo

choice=""
while true 
do
  echo $choice | grep -q "^[1-5]"
  if [ $? -eq 0 ] 
   then 
   break
  fi
  read -p "Enter your choice here: " choice 
done

case $choice in

  1) echo "Full install for mining Steem selected"
  ;;
  2) echo "Cloned machine configuration selected"
  ;;
  3) echo "Full install for running a Steem node selected"
  ;;
  4) echo "Steem recompile selected"
  ;;
  5) echo "Blockchain redownload && bootstrap selected"
  ;;
  
  esac
