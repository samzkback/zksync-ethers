#!/bin/bash

echo "Install required tools"

curl https://binaries.soliditylang.org/linux-amd64/solc-linux-amd64-v0.8.20+commit.a1b79de6 -o /usr/local/bin/solc
chmod +x /usr/local/bin/solc
apt-get update && apt-get install -y jq

echo "Clone the matter-labs/era-contracts repository"
git clone https://github.com/matter-labs/era-contracts.git era-contracts
pushd era-contracts

echo "Install dependencies"
yarn install


echo "Generate ABIs"
solc --base-path l1-contracts/  \
  --include-path ./node_modules/ \
  -o l1-abi \
  --abi \
  l1-contracts/contracts/zksync/interfaces/IZkSync.sol \
  l1-contracts/contracts/bridge/interfaces/IL1Bridge.sol \
  l1-contracts/contracts/bridge/interfaces/IL2Bridge.sol

solc --base-path system-contracts \
  -o system-contracts-abi \
  --abi \
  system-contracts/contracts/interfaces/IContractDeployer.sol \
  system-contracts/contracts/interfaces/IEthToken.sol \
  system-contracts/contracts/interfaces/IL1Messenger.sol \
  system-contracts/contracts/interfaces/INonceHolder.sol \
  system-contracts/contracts/interfaces/IPaymasterFlow.sol

mkdir abi /abi
mv l1-abi/* system-contracts-abi/* abi

contracts="IZkSync.abi IL1Bridge.abi IL2Bridge.abi IContractDeployer.abi IEthToken.abi IL1Messenger.abi INonceHolder.abi IPaymasterFlow.abi"

for filename in $contracts; do
    jq '.' "abi/$filename" > "/abi/${filename%.abi}.json"
done

echo "Folder content"
ls /abi