#!/bin/bash
#needed for vanitygen, creating private keys
sudo apt-get -y install libpcre3-dev  
cd ~ 
git clone https://github.com/samr7/vanitygen
cd vanitygen && make
ranStr=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 2 | head -n 1)
echo "Generating private key for your miners..."
privKey=$(./vanitygen "1$ranStr" | grep Privkey)
formattedPrivKey=${privKey#* }
clear

cd ~  
#arrays for storing valid miner names and their private keys
declare -a minerArr
declare -a witnessArr

echo "How many threads do you want to mine on?"
echo "This is the number of CPU cores you have, unless you have hyperthreading on, then it is double the amount of cores"
read cores
mining_threads="mining-threads = $cores"


echo "Creating four miner accounts..."
i="0"
while [ $i -lt 4 ]
do
 echo
 echo "Enter in a name for Miner$i"
 echo "MAKE SURE YOU DO NOT ENTER IN THE SAME NAME TWICE"
 echo "Usernames must be all lowercase and start with a lower case letter and contain no special characters/spaces"

 read name
 wget -q  https://steemd.com/@$name  
 wgetStatus=$?
 rm -f @*
 if [ $wgetStatus -gt 0 ] 
  then
  echo "Name available! Miner account $i is: $name"
  minerArr[$i]="miner = [\"$name\",\"$formattedPrivKey\"]"
  witnessArr[$i]="witness = \"$name\""
  i=$[$i+1]
 else 
  echo "Name taken or invalid, try another name" 
 fi
done

i="0"
echo "Here are your witness + miner accounts and their corresponding WIF Key"
while [ $i -lt 4 ]
do
 echo 
 echo "Witnesses: ${witnessArr[$i]}"
 echo "Miner account names and their private key: ${minerArr[$i]}"
 i=$[$i+1]
done

echo "Modifying your ~/steem/programs/steemd/witness_node_data_dir/config.ini file"
cd  ~/steem/programs/steemd/witness_node_data_dir/

#TODO
#in config.ini replace "# seed-node = "
#with 
#"seed-node = 212.117.213.186:2016
# seed-node = 185.82.203.92:2001
# seed-node = 52.74.152.79:2001
# seed-node = 52.63.172.229:2001
# seed-node = 104.236.82.250:2001
# seed-node = 104.199.157.70:2001
# seed-node = steem.kushed.com:2001
# seed-node = steemd.pharesim.me:2001
# seed-node = seed.steemnodes.com:2001
# seed-node = steemseed.dele-puppy.com:2001
# seed-node = seed.steemwitness.com:2001
# seed-node = seed.steemed.net:2001
# seed-node = steem-seed1.abit-more.com:2001
# seed-node = steem.clawmap.com:2001
# seed-node = 52.62.24.225:2001
# seed-node = steem-id.altexplorer.xyz:2001
# seed-node = 213.167.243.223:2001
# seed-node = 162.213.199.171:34191
# seed-node = 45.55.217.111:12150
# seed-node = 212.47.249.84:40696
# seed-node = 52.4.250.181:39705
# seed-node = 81.89.101.133:2001
# seed-node = 46.252.27.1:1337 "

#Replace "# rpc-endpoint = "
#with    "rpc-endpoint = 127.0.0.1:8090"

#Replace "# witness = "
#with contents of witnessArr[], with each index being on a new line"

#Replace "#  miner = "
#with contents of minerArr[], with each index being  on a new line"

#Replace "# mining-threads"
#with contents of $mining_threads
