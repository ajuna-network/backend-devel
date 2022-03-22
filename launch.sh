#!/bin/bash
./ajuna --dev --tmp --unsafe-ws-external --unsafe-rpc-external &
./integritee-service init-shard
./integritee-service shielding-key
./integritee-service signing-key
./integritee-service --ws-external run --dev --skip-ra
