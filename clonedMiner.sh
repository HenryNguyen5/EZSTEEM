#!/bin/bash
#Modifies config files for when user has n-2 miners to setup
cd ~/steem/programs/steemd/witness_node_data_dir
echo "Enter in how many threads you want to mine on this machine"
read threads
sed -i "s/mining-threads = [0-9]*/mining-threads = $threads/" config.ini
sed -i 's/witness = /# witness =/' config.ini
