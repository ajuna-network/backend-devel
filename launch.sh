#!/bin/bash
./ajuna --dev --tmp &
sleep 5
./integritee-service init-shard
./integritee-service shielding-key
./integritee-service signing-key
./integritee-service -r 3485 run --dev --skip-ra
