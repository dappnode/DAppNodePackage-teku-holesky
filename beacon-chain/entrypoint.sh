#!/bin/bash

# Concatenate EXTRA_OPTS string
[[ -n $CHECKPOINT_SYNC_URL ]] && EXTRA_OPTS="--initial-state=$(echo $CHECKPOINT_SYNC_URL | sed 's:/*$::')/eth/v2/debug/beacon/states/finalized ${EXTRA_OPTS}"

case $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_HOLESKY in
"holesky-geth.dnp.dappnode.eth")
    HTTP_ENGINE="http://holesky-geth.dappnode:8551"
    ;;
"holesky-nethermind.dnp.dappnode.eth")
    HTTP_ENGINE="http://holesky-nethermind.dappnode:8551"
    ;;
"holesky-besu.dnp.dappnode.eth")
    HTTP_ENGINE="http://holesky-besu.dappnode:8551"
    ;;
"holesky-erigon.dnp.dappnode.eth")
    HTTP_ENGINE="http://holesky-erigon.dappnode:8551"
    ;;
*)
    echo "Unknown value for _DAPPNODE_GLOBAL_EXECUTION_CLIENT_HOLESKY: $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_HOLESKY"
    HTTP_ENGINE=$_DAPPNODE_GLOBAL_EXECUTION_CLIENT_HOLESKY
    ;;
esac

# MEVBOOST: https://docs.teku.consensys.net/en/latest/HowTo/Builder-Network/
if [ -n "$_DAPPNODE_GLOBAL_MEVBOOST_HOLESKY" ] && [ "$_DAPPNODE_GLOBAL_MEVBOOST_HOLESKY" == "true" ]; then
    echo "MEVBOOST is enabled"
    MEVBOOST_URL="http://mev-boost.mev-boost-holesky.dappnode:18550"
    EXTRA_OPTS="--builder-endpoint=${MEVBOOST_URL} ${EXTRA_OPTS}"
fi

exec /opt/teku/bin/teku \
    --network=holesky \
    --data-base-path=/opt/teku/data \
    --ee-endpoint=$HTTP_ENGINE \
    --ee-jwt-secret-file="/jwtsecret" \
    --p2p-port=$P2P_PORT \
    --rest-api-enabled=true \
    --rest-api-cors-origins="*" \
    --rest-api-interface=0.0.0.0 \
    --rest-api-port=$BEACON_API_PORT \
    --rest-api-host-allowlist="*" \
    --rest-api-docs-enabled=true \
    --metrics-enabled=true \
    --metrics-interface=0.0.0.0 \
    --metrics-port=8008 \
    --metrics-host-allowlist="*" \
    --log-destination=CONSOLE \
    --validators-proposer-default-fee-recipient="${FEE_RECIPIENT_ADDRESS}" \
    $EXTRA_OPTS
