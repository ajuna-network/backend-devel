#!/bin/sh
./ngrok start --log=stdout --config=/proxy/ngrok-backend.yml ajuna-node ajuna-worker &
