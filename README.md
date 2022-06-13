# Backend development environment

Builds two docker images, and composes them into one network. One being the `ajuna-node` and the other being the `worker` built in simulation mode(SW).

## Prerequistes
- Docker v20.10.12+
- Docker Compose v2.2.3+
- The above are included with Docker Desktop(Windows/OSX)
- Intel Host (unfortunately the worker build will fail on M1)

## Setup

The node and worker are submodules, first initialise and update them:

`git submodule init`  
`git submodule update`

Please confirm that both repositories have cloned correctly before continuiing

The worker is proxied with `ngrok`, you can either connect to a TLS websocket server or plain socket.  You will need to supply your Auth Token from https://ngrok.com/ within the `.env` file.  Accounts are free, and the URL the worker is behind will appear in the start up log for the worker, something like this:

```
worker_1      | t=2022-05-09T11:52:49+0000 lvl=info msg="started tunnel" obj=tunnels name="command_line (http)" addr=https://localhost:2000 url=http://79b4-20-107-17-237.ngrok.io
worker_1      | t=2022-05-09T11:52:49+0000 lvl=info msg="started tunnel" obj=tunnels name=command_line addr=https://localhost:2000 url=https://79b4-20-107-17-237.ngrok.io
```

Logs can be viewed with:

`docker logs backend-devel_worker_1`

You can either take the TLS or plain connection.  You may also see other useful information such as the MRENCLAVE

## Build
Within root folder of repository

`docker-compose up -d` as daemon or `docker-compose up`

The RPC port 9944 for `ajuna-node` is exposed.

## Connect to running worker
To attach to the running `worker` container:

`docker exec -it backend-devel_worker_1 /bin/bash`

## Stop
Within root folder of repository

`docker-compose down` if running in daemon mode


