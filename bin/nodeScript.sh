#!/bin/bash
#made by steemit users omotherhen and gikitiki
#This is a script for a first time setup of a node, done in a VM for a fresh install of Ubuntu 16.04
#base install for steem node

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
$pnkl "----------------------------WELCOME TO EZSTEEM NODE SETUP------------------------------"
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


cd "$myBaseDir"
sudo -s apt-get -y install openssh-server 
sudo -s apt-get update 
sudo -s apt-get -y upgrade 
sudo -s apt-get -y install unzip cmake g++ python-dev autotools-dev libicu-dev build-essential libbz2-dev libboost-all-dev libssl-dev libncurses5-dev doxygen libreadline-dev dh-autoreconf screen  
sudo -s git clone https://github.com/steemit/steem 
cd steem 
sudo -s git checkout v0.12.2 
sudo -s git submodule update --init --recursive 
##sudo cmake -DCMAKE_BUILD_TYPE=Release -DLOW_MEMORY_NODE=ON . 
sudo cmake -DCMAKE_BUILD_TYPE=Release . 
sudo -s make -j "$myCoreCount"
sudo -s chown -R $USER $myBaseDir
clear

cd "$myBaseDir/steem/programs/steemd"
./steemd &
PID=$!
sleep 3
kill $PID
sleep 1
clear

$e "$pnk Modifying your $myBaseDir/steem/programs/steemd/witness_node_data_dir/config.ini file $wht"
cd  "$myBaseDir/steem/programs/steemd/witness_node_data_dir/"

#in config.ini replace "# seed-node = "

str="seed-node = 212.117.213.186:2016\n"
str+="seed-node = 185.82.203.92:2001\n"
str+="seed-node = 52.74.152.79:2001\n"
str+="seed-node = 52.63.172.229:2001\n"
str+="seed-node = 104.236.82.250:2001\n"
str+="seed-node = 104.199.157.70:2001\n"
str+="seed-node = steem.kushed.com:2001\n"
str+="seed-node = steemd.pharesim.me:2001\n"
str+="seed-node = seed.steemnodes.com:2001\n"
str+="seed-node = steemseed.dele-puppy.com:2001\n"
str+="seed-node = seed.steemwitness.com:2001\n"
str+="seed-node = seed.steemed.net:2001\n"
str+="seed-node = steem-seed1.abit-more.com:2001\n"
str+="seed-node = steem.clawmap.com:2001\n"
str+="seed-node = 52.62.24.225:2001\n"
str+="seed-node = steem-id.altexplorer.xyz:2001\n"
str+="seed-node = 213.167.243.223:2001\n"
str+="seed-node = 162.213.199.171:34191\n"
str+="seed-node = 45.55.217.111:12150\n"
str+="seed-node = 212.47.249.84:40696\n"
str+="seed-node = 52.4.250.181:39705\n"
str+="seed-node = 81.89.101.133:2001\n"
str+="seed-node = 46.252.27.1:1337\n"

sed -i "s/# seed-node =/&\n$str/" config.ini

#Replace "# rpc-endpoint = "
#with    "rpc-endpoint = 127.0.0.1:8090"
sed -i 's/# rpc-endpoint = /rpc-endpoint = 127.0.0.1:8090/' config.ini

$pnkl "Boot-strapping blockchain for fast setup, then starting the miner!"
$whtl
cd "$myBaseDir/steem/programs/steemd/witness_node_data_dir/blockchain/database/" && wget http://einfachmalnettsein.de/steem-blocks-and-index.zip && sudo -s unzip -o steem-blocks-and-index.zip && sudo -s rm -f steem-blocks-and-index.zip && cd ../../../

$pnkl "---------------------------------------------------------------------------------------"
$pnkl "------------------------------------Starting Node--------------------------------------"
$pnkl "---------------------------------------------------------------------------------------"
$whtl

./steemd --replay

#TODO
#Setup automatic backup of blockchain for future compiling
