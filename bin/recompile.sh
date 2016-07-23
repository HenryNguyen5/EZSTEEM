#!/bin/bash
#made by steemit user omotherhen
cd ~/steem
git fetch
git checkout v0.12.1
rm -f CMakeCache.txt
make -s clean > /dev/null
cmake -DCMAKE_BUILD_TYPE=Release-DLOW_MEMORY_NODE=ON .
echo -e "\e[5mCompiling your Steem installation, this may take a while"   
make -s
echo -e "\e[25mDone!"
exit 0

