#!/bin/bash
#made by steemit user omotherhen

echo "Boot-strapping blockchain for fast setup, then starting the miner!"
cd ~/steem/programs/steemd/witness_node_data_dir/blockchain/database/ && wget http://einfachmalnettsein.de/steem-blocks-and-index.zip && unzip -o steem-blocks-and-index.zip && cd ../../../ && ./steemd --replay

