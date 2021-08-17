#!/bin/bash

curl -s https://raw.githubusercontent.com/KiFoundation/ki-networks/v0.1/Testnet/kichain-t-2/genesis.json > $HOME/testnet/kid/config/genesis.json
peers="454d1bfb5db8082dadf5dcf81c200f0d37c1ac72@51.195.101.107:26656,1515ae1aa715905145ae1c5a0346f552ca0cea7d@172.105.190.70:26656,61d3d19da658c304d899db8e736e67ae1c0e9b2b@51.77.34.110:26656,130e9a709647f9efa2c780be174d69ad1f7949f1@65.21.247.250:26656,bf8077c39cd50aa5f71d90b4397504db8ef2f78f@65.21.155.101:26656"
seeds="815d447b182bbfcf729ac016bc8bb44aa8e14520@94.23.3.107:27756"
echo $peers
echo $seeds
sed -i.bak -e "s/^seeds *=.*/seeds = \"$seeds\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/testnet/kid/config/config.toml
sed -i -e 's/^\(timeout_commit *=\).*/\1 "5s"/' $HOME/testnet/kid/config/config.toml

sudo tee <<EOF >/dev/null /etc/systemd/system/kichain.service
[Unit]
Description=Kichain Cosmos daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/go/bin/kid start --home $HOME/testnet/kid/
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

sudo systemctl restart systemd-journald

if [ ! -d $HOME/kichain.tar.gz ]; then
	tar cvzf kichain.tar.gz $HOME/testnet/
fi

sudo systemctl daemon-reload
sudo systemctl enable kichain
sudo systemctl start kichain
