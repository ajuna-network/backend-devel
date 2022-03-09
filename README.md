# Connect Four Demo

Builds two docker images, and composes them into one contaier. One being the `ajuna-node` and the other being the `worker` built in simulation mode(SW).

### Prerequistes
- Docker v20.10.12+
- Docker Compose v2.2.3+
- The above are included with Docker Desktop(Windows/OSX)
- Intel Host (unfortunately the worker build will fail on M1)

### Build
Within root folder of repository

`docker-compose up -d` as daemon or `docker-compose up`

The RPC port 9944 for `ajuna-node` is exposed.

### Run Connect Four Demo script
To attach to the running `worker` container:

`docker exec -it worker-node-connect-four-worker-1 /bin/bash`

To run the demo:
`./demo_connect_four.sh`

### Stop
Within root folder of repository

`docker-compose down` if running in daemon mode


