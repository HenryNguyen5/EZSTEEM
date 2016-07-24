#!/bin/bash
#made by steemit user @omotherhen and @gikitiki
#This is a script for a first time setup of a miner, done in a VM for a fresh install of Ubuntu 16.04
#base install for steem miner
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
$pnkl "------------------------------WELCOME TO EZSTEEM MINER---------------------------------"
$pnkl "---------------------------------------------------------------------------------------"
$whtl

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



cd "$myBaseDir"
sudo apt-get -y install openssh-server 
sudo apt-get update 
sudo apt-get -y upgrade 
sudo apt-get -y install zip unzip cmake g++ python-dev autotools-dev libicu-dev build-essential libbz2-dev libboost-all-dev libssl-dev libncurses5-dev doxygen libreadline-dev dh-autoreconf screen 
git clone https://github.com/steemit/steem && cd steem && git checkout v0.12.1 && git submodule update --init --recursive && cmake -DCMAKE_BUILD_TYPE=Release-DLOW_MEMORY_NODE=ON . && make
clear


#needed for vanitygen, creating private keys
sudo apt-get -y install libpcre3-dev 
cd "$myBaseDir" 
git clone https://github.com/samr7/vanitygen 
cd vanitygen && make 
ranStr=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 2 | head -n 1) 
echo "Generating private key for your miners..." 
privKey=$(./vanitygen "1$ranStr" | grep Privkey) 
formattedPrivKey=${privKey#* } 
clear

cd "$myBaseDir"
#arrays for storing valid miner names and their private keys
declare -a minerArr
declare -a witnessArr


$pnkl "How many threads do you want to mine on?"
$whtl"  This is the number of CPU cores you have."
echo "  If you have hyperthreading on, then it is double the amount of cores"
read cores
mining_threads="mining-threads = $cores"

echo
$e "$pnk How many steem accounts would you like to make? $wht"
read acc
i="0"
while [ $i -lt $acc ]
do
 echo
 $pnkl "Enter in a name for Miner $i "
 $e "$wht	MAKE SURE YOU DO NOT ENTER IN THE SAME NAME TWICE"
 echo " Usernames must be all lowercase and start with a lower case letter and contain no special characters/spaces"
 echo " In addition to above restrictions, usernames must be 3+ characters, can't start with a number"
 echo " . and - to create segments greater than two letters and less than 16 characters is allowed"
 $pnkl
#the user will specify a name for the miner.  Check it meets criteria
while true;
do
   myTest="PASS"
   read -p "Enter in a name for Miner $i : " name
   if grep -q "^[a-z][-a-z0-9.]\{2,14\}[a-z0-9]$" <<< "$name" ;
      then
         #If the name contains a . The segment has to be three alphanum characters
         if ! grep -q "^[a-z][a-z0-9]\{2,2\}" <<< "$name" ;
         then
            $whtl "The first character is a letter, the next two must be alphanum"
            myTest="FAIL"
         fi
         #If the name contains a . The segment has to be three alphanum characters
         if grep -q "[.]" <<< "$name" ;
         then
            if ! grep -q "[.][a-z0-9]\{3,14\}" <<< "$name" ;
            then
               $whtl "You must have at least 3 alphanum characters after a period"
               myTest="FAIL"
            fi
         fi
         #If the name contains a - The segment has to be three alphanum characters
         if grep -q "[-]" <<< "$name" ;
         then
            if ! grep -q "[-][a-z0-9]\{3,14\}" <<< "$name" ;
            then
                $whtl "You must have at least 3 alphanum characters after a dash"
               myTest="FAIL"
            fi
         fi
   else
       $whtl "TRY AGAIN: Please check the naming rules."
      myTest="FAIL"
   fi
   if [ $myTest == "PASS" ] ;
   then
      break;
   fi
done
 
 wget -q  https://steemd.com/@$name
 wgetStatus=$?
 rm -f @*
 if [ $wgetStatus -gt 0 ]
  then
  $whtl "Name available! Miner account $i is: $name"
  minerArr[$i]="miner = [\"$name\",\"$formattedPrivKey\"]"
  witnessArr[$i]="witness = \"$name\""
  i=$[$i+1]
 else
  $whtl "Name : $name is taken, try another name"
 fi
done

i="0"
echo
$pnkl "Here are your witness + miner accounts and their corresponding WIF Key"
while [ $i -lt $acc ]
do
 $e "$pnk Witnesses: $wht ${witnessArr[$i]}"
 $e "$pnk Miner account names and their private key: $wht ${minerArr[$i]}"
 i=$[$i+1]
done

cd "$myBaseDir/steem/programs/steemd"
./steemd &
PID=$!
sleep 3
kill $PID
sleep 1

echo
$pnkl "Modifying your $myBaseDir/steem/programs/steemd/witness_node_data_dir/config.ini file"
$whtl

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


#Replace "# witness = "
#with contents of witnessArr[], with each index being on a new line"
str=""
witness_count=${#witnessArr[*]}
index=0
while [ "$index" -lt "$witness_count" ]
do
	str+="${witnessArr[$index]}\n"
	index=$[$index+1]
done
sed -i "s/# witness =/&\n$str/" config.ini


#Replace "#  miner = "
#with contents of minerArr[], with each index being  on a new line"

str=""
miner_count=${#minerArr[*]}
index=0
while [ "$index" -lt "$miner_count" ]
do
	str+="${minerArr[$index]}\n"
	index=$[$index+1]
done
sed -i "s/# miner =/&\n$str/" config.ini


#Replace "# mining-threads"
#with contents of $mining_threads
sed -i "s/# mining-threads =/$mining_threads/" config.ini

$e "$pnk Boot-strapping blockchain for fast setup, then starting the miner! $wht"
cd "$myBaseDir/steem/programs/steemd/witness_node_data_dir/blockchain/database/" && wget http://einfachmalnettsein.de/steem-blocks-and-index.zip && unzip -o steem-blocks-and-index.zip && rm -f steem-blocks-and-index.zip && cd ../../../ 

$pnkl "---------------------------------------------------------------------------------------"
$pnkl "------------------------------------Starting Miner-------------------------------------"
$pnkl "---------------------------------------------------------------------------------------"
$whtl
./steemd --replay

#TODO
#Setup automatic backup of blockchain for future compiling
