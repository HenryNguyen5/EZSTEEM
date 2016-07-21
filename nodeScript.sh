#!/bin/bash
#made by steemit user omotherhen
#This is a script for a first time setup of a node, done in a VM for a fresh install of Ubuntu 16.04
#base install for steem node
cd ~
sudo apt-get update 
sudo apt-get -y upgrade 
sudo apt-get -y install unzip cmake g++ python-dev autotools-dev libicu-dev build-essential libbz2-dev libboost-all-dev libssl-dev libncurses5-dev doxygen libreadline-dev dh-autoreconf  
git clone https://github.com/steemit/steem && cd steem && git checkout v0.11.0 && git submodule update --init --recursive && cmake -DCMAKE_BUILD_TYPE=Release-DLOW_MEMORY_NODE=ON . && make
clear

cd ~/steem/programs/steemd
./steemd &
PID=$!
sleep 3
kill $PID

echo "Modifying your ~/steem/programs/steemd/witness_node_data_dir/config.ini file"
cd  ~/steem/programs/steemd/witness_node_data_dir/

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

echo "Boot-strapping blockchain for fast setup, then starting the miner!"
cd ~/steem/programs/steemd/witness_node_data_dir/blockchain/database/ && wget http://einfachmalnettsein.de/steem-blocks-and-index.zip && unzip -o steem-blocks-and-index.zip && cd ../../../ && ./steemd --replay

#TODO
#Setup automatic backup of blockchain for future compiling
