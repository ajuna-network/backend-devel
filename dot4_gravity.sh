#!/bin/bash

# setup:
# build ajuna node with skip-ias-check
#   cargo build --release --features solo,skip-ias-check
#
# run ajuna node
#   ./target/release/ajuna-solo  --dev --tmp --ws-port <NODEPORT>
#
# run worker inside the bin folder:
#   rm light_client_db.bin
#   rm -r shards
#   rm -r sidechain_db
#   export RUST_LOG=integritee_service=info,ita_stf=debug
#   ./integritee-service init-shard
#   ./integritee-service shielding-key
#   ./integritee-service signing-key
#   ./integritee-service -P <WORKERPORT> -p <NODEPORT> -r <REMOTE-ATTESTATION-PORT> run --dev --skip-ra
#
# then run this script

# usage:
#  export RUST_LOG=integritee-cli=info,ita_stf=info
#  ./dot4_gravity.sh -p <NODEPORT> -P <WORKERPORT> -m file
#
# if -m file is set, the mrenclave will be read from file  ~/mrenclave.b58


while getopts ":m:p:P:" opt; do
    case $opt in
        m)
            READMRENCLAVE=$OPTARG
            ;;
        p)
            NPORT=$OPTARG
            ;;
        P)
            RPORT=$OPTARG
            ;;
    esac
done

# using default port if none given as arguments
NPORT=${NPORT:-9944}
RPORT=${RPORT:-2000}

echo "Using node-port ${NPORT}"
echo "Using trusted-worker-port ${RPORT}"

BALANCE=1000

CLIENT="./integritee-cli -p ${NPORT} -P ${RPORT} -u ws://ajuna-node"

if [ "$READMRENCLAVE" = "file" ]
then
    read MRENCLAVE <<< $(cat ~/mrenclave.b58)
    echo "Reading MRENCLAVE from file: ${MRENCLAVE}"
else
    # this will always take the first MRENCLAVE found in the registry !!
    read MRENCLAVE <<< $($CLIENT list-workers | awk '/  MRENCLAVE: / { print $2; exit }')
    echo "Reading MRENCLAVE from worker list: ${MRENCLAVE}"
fi
[[ -z $MRENCLAVE ]] && { echo "MRENCLAVE is empty. cannot continue" ; exit 1; }

echo ""
echo "* Create account for Alice"
ACCOUNTALICE=//Alice
echo "  Alice's account = ${ACCOUNTALICE}"
echo ""

echo "* Create account for Bob"
ACCOUNTBOB=//Bob
echo "  Bob's account = ${ACCOUNTBOB}"
echo ""

echo "* Issue ${BALANCE} tokens to Alice's account"
${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct set-balance ${ACCOUNTALICE} ${BALANCE}
echo ""
sleep 1

echo "* Issue ${BALANCE} tokens to Bob's account"
${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct set-balance ${ACCOUNTBOB} ${BALANCE}
echo ""
sleep 1

echo "Queue Game for Alice (Player 1)"
${CLIENT} queue-game ${ACCOUNTALICE}
echo ""

echo "Queue Game for Bob (Player 2)"
${CLIENT} queue-game ${ACCOUNTBOB}
echo ""

echo "Waiting for matchmaking and game to be created"
sleep 45
echo ""

echo "* Bomb phase starts"
echo "Turn for Alice (Player 1)"
${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct drop-bomb ${ACCOUNTALICE} 0 0
${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct drop-bomb ${ACCOUNTALICE} 0 1
${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct drop-bomb ${ACCOUNTALICE} 0 2
echo ""
echo "Turn for Bob (Player 2)"
${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct drop-bomb ${ACCOUNTBOB}   0 0
${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct drop-bomb ${ACCOUNTBOB}   0 1
${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct drop-bomb ${ACCOUNTBOB}   0 2
echo ""

echo "* Stone phase starts"
echo "** Turn 1"
echo "Turn for Bob (Player 2)" # triggers bomb(s)
${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct drop-stone ${ACCOUNTBOB} north 0
echo ""
echo "Turn for Alice (Player 1)" # triggers bomb(s)
${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct drop-stone ${ACCOUNTALICE} north 0
echo ""

for i in 2 3 4 5; do
    echo "** Turn $i"
    echo "Turn for Bob (Player 2)"
    ${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct drop-stone ${ACCOUNTBOB} west 2
    echo ""
    echo "Turn for Alice (Player 1)"
    ${CLIENT} trusted --mrenclave ${MRENCLAVE} --direct drop-stone ${ACCOUNTALICE} north 2
    echo ""
done

echo "* Game finishes"
echo "Board after end of game"
${CLIENT} trusted --mrenclave ${MRENCLAVE} get-board ${ACCOUNTBOB}
echo ""

echo "Wait for board to be cleared"
sleep 45

echo "Fetch board again to see it fail:"
${CLIENT} trusted --mrenclave ${MRENCLAVE} get-board ${ACCOUNTBOB}
echo ""
