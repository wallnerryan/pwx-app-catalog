#!/bin/bash

# Based on https://docs.fluxcd.io/en/1.19.0/tutorials/get-started/

export GHUSER="YOURUSER"

./fluxctl install \
--git-user=${GHUSER} \
--git-email=${GHUSER}@users.noreply.github.com \
--git-url=git@github.com:${GHUSER}/flux-get-started \
--git-path=namespaces,workloads \
--namespace=flux | kubectl apply -f -

sleep 5

kubectl -n flux rollout status deployment/flux

sleep 5

./fluxctl identity --k8s-fwd-ns flux

