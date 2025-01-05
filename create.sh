#!/bin/bash
#
################# STEP 1 ########################
#
# organize local folder and clone the source
mv barney "barney-$(date +'%Y%m%d%H%M%S')"
mkdir barney
cp -R source-coin/* barney/
#
#
################# STEP 2 ########################
# rename strings
find barney/ -type f -readable -writable -exec sed -i "s/Litecoin/Barneycoin/g" {} \;
find barney/ -type f -readable -writable -exec sed -i "s/LiteCoin/BarneyCoin/g" {} \;
find barney/ -type f -readable -writable -exec sed -i "s/LTC/BRN/g" {} \;
find barney/ -type f -readable -writable -exec sed -i "s/ltc/brn/g" {} \;
find barney/ -type f -readable -writable -exec sed -i "s/litecoin/barneycoin/g" {} \;
find barney/ -type f -readable -writable -exec sed -i "s/litecoind/barneycoind/g" {} \;
#
#
# rename files
find barney/ -type f -name "*Litecoin*" -exec rename 's/Litecoin/Barneycoin/g' {} \;
find barney/ -type f -name "*LiteCoin*" -exec rename 's/LiteCoin/BarneyCoin/g' {} \;
find barney/ -type f -name "*litecoin*" -exec rename 's/litecoin/barneycoin/g' {} \;
find barney/ -type f -name "*litecoind*" -exec rename 's/litecoind/barneycoind/g' {} \;
find barney/ -type f -name "*LTC*" -exec rename 's/LTC/BRN/g' {} \;
find barney/ -type f -name "*ltc*" -exec rename 's/ltc/brn/g' {} \;
#
#
# update all usage of counts.
#
find barney/ -type f -readable -writable -exec sed -i "s/lites/mBRN/g" {} \;
find barney/ -type f -readable -writable -exec sed -i "s/photons/uBRN/g" {} \;
find barney/ -type f -readable -writable -exec sed -i "s/liteoshi/sBRN/g" {} \;
#
# src/qt/bitcoinunits.cpp: TBC
#
#
#
#
################# STEP 3 ########################

# Change "magic number" in pch message to a unique value
sed -i '
s/pchMessageStart\[0\] = 0xfb;/pchMessageStart[0] = 0x64;/;
s/pchMessageStart\[1\] = 0xc0;/pchMessageStart[1] = 0x6f;/;
s/pchMessageStart\[2\] = 0xb6;/pchMessageStart[2] = 0x20;/;
s/pchMessageStart\[3\] = 0xdb;/pchMessageStart[3] = 0x79;/;
' barney/src/chainparams.cpp

# remove seednodes and dnsseeds (or later add your own)

sed -i '/vSeeds.emplace_back("testnet-seed.faithcointools.com");/d' barney/src/chainparams.cpp
sed -i '/vSeeds.emplace_back("seed-b.faithcoin.loshan.co.uk");/d' barney/src/chainparams.cpp
sed -i '/vSeeds.emplace_back("dnsseed-testnet.thrasher.io");/d' barney/src/chainparams.cpp
sed -i '/vSeeds.emplace_back("seed-a.faithcoin.loshan.co.uk");/d' barney/src/chainparams.cpp
sed -i '/vSeeds.emplace_back("dnsseed.thrasher.io");/d' barney/src/chainparams.cpp
sed -i '/vSeeds.emplace_back("dnsseed.faithcointools.com");/d' barney/src/chainparams.cpp
sed -i '/vSeeds.emplace_back("dnsseed.faithcoinpool.org");/d' barney/src/chainparams.cpp
sed -i '/vSeeds.emplace_back("dnsseed.koin-project.com");/d' barney/src/chainparams.cpp


####  --- TO DO ---> comment out chainparamsseeds.h (to be automated, do manually)
#

################# STEP 4 ########################
#
#change port number
find barney/ -type f -readable -writable -exec sed -i "s/9333/9666/g" {} \;



################# STEP 5 ########################
#
# Genesis Time
#
#
# Run the Python script and capture the output
output=$(python2 genesis.py -a scrypt -z "NY Times 05/Oct/2011 Steve Jobs, Apple’s Visionary, Dies at 56" -p "040184710fa689ad5023690c80f3a49c8f13f8d45b8c857fbcbc8bc4a8e4d3eb4b10f4d4604fa08dce601aaf0f470216fe1b51850b4acf21b179c45070ac7b03a9" -t 1317972665 -n 2084524493)

# Extract variables from the output
ALGORITHM=$(echo "$output" | grep -oP "algorithm: \K.*")
MERKLE_HASH=$(echo "$output" | grep -oP "merkle hash: \K.*")
PSZ_TIMESTAMP=$(echo "$output" | grep -oP "pszTimestamp: \K.*")
PUBKEY=$(echo "$output" | grep -oP "pubkey: \K.*")
TIME=$(echo "$output" | grep -oP "time: \K.*")
BITS=$(echo "$output" | grep -oP "bits: \K.*")
NONCE=$(echo "$output" | grep -oP "nonce: \K.*")
GENESIS_HASH=$(echo "$output" | grep -oP "genesis hash: \K.*")

# Now you can use the variables in your bash script
echo "Algorithm: $ALGORITHM"
echo "Merkle Hash: $MERKLE_HASH"
echo "Timestamp: $PSZ_TIMESTAMP"
echo "Pubkey: $PUBKEY"
echo "Time: $TIME"
echo "Bits: $BITS"
echo "Nonce: $NONCE"
echo "Genesis Hash: $GENESIS_HASH"
#
#
#
FILE_PATH="barney/src/chainparams.cpp"
#
#
sed -i "s|^const char\* pszTimestamp = .*;|const char* pszTimestamp = \"$PSZ_TIMESTAMP\";|" "$FILE_PATH"
sed -i "s/040184710fa689ad5023690c80f3a49c8f13f8d45b8c857fbcbc8bc4a8e4d3eb4b10f4d4604fa08dce601aaf0f470216fe1b51850b4acf21b179c45070ac7b03a9/$PUBKEY/" "$FILE_PATH"
sed -i "s/1317972665/$TIME/g" "$FILE_PATH"
sed -i "s/2084524493/$NONCE/g" "$FILE_PATH"
sed -i "s/0x1e0ffff0/$BITS/g" "$FILE_PATH"
sed -i "s/12a765e31ffd4059bada1e25190f6e98c99d9714d334efa41a195a7e7e04bfe2/$GENESIS_HASH/g" "$FILE_PATH"
sed -i "s/97ddfbbae6be97fd6cdf3e7ca13232a3afff2353e29badfab7f73011edd4ced9/$MERKLE_HASH/g" "$FILE_PATH"
#
#
# to do:
# vSeeds on chainparams.cpp (gets renamed and not removed?) check!!
#

################# FINAL STEP - BUILD ########################

# build
cd barney
./autogen.sh
./configure --with-incompatible-bdb
make -j
#make install
