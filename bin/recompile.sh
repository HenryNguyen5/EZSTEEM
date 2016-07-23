#!/bin/bash
#made by steemit user omotherhen
cd ~/steem
git fetch
git checkout v0.12.1
rm -f CMakeCache.txt
make -s clean > /dev/null
cmake -DCMAKE_BUILD_TYPE=Release-DLOW_MEMORY_NODE=ON .
make --silent 
clear
echo -e "\e[5mDone!\e[25m"
exit 0

