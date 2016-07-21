#!/bin/bash
#made by steemit user omotherhen
cd ~/steem
git pull && rm -f CMakeCache.txt && make clean 
cmake -DCMAKE_BUILD_TYPE=Release-DLOW_MEMORY_NODE=ON . && make
clear

cd ~/steem/programs/steemd
./steemd --replay
