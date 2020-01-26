#!/bin/bash
## These networks exist as global networks in the swarm, available to all stacks.
## They should be created at the same time as the swarm is instantiated for the first time, as they are used by all of
## the stacks.
##
## The subnets are created with a CIDR range of /8 to ensure that a large pool of addresses are available for the Swarm.
## Docker can be known for not cleaning up unused address, so this ensures there are always enough available.
## If the entire /8 range does eventually fill up, services will stop deploying and the network will have to be removed and recreated.
docker network create --subnet=11.0.0.0/8 --scope=swarm --driver=overlay proxy_ext
