#!/bin/bash
#
# This script removes a stack and ensures that the networks attached to the stack have been shut down.
# If the network check is not performed, an attempt to create a new stack with the same name will result in an error as
# stack networks are not shut down with the stack itself, but removed soon after. This is an issue because deploying a
# stack will attempt to make a new network, which will still exist as it hasn't shut down yet (~20 seconds).
# Networks should ideally not be shared between stacks (other than the global networks).
#
# Parameters:
#   - stack_name  Name of the stack to remove.
#

# Logging constants.
INFO="[\e[94mINFO\e[39m]"
WARN="[\e[93mWARN\e[39m]"
ERROR="[\e[91mERROR\e[39m]"

if [[ $# -ne 1 ]] then
    echo "Incorrect number of arguments (expected 1, received $#)."\
         "Expected a stack generic name." >&2
    echo "Example usage: $0 proxy" >&2
    exit 1
fi

stack_name="${2}"

# Take down the stack.
docker stack rm "${stack_name}"

echo -e "${INFO} Stack '${stack_name}' has been removed"

# Check once a second whether a network entry exists for the stack given.
# If a network doesn't exist, Docker doesn't return any text when the command is executed.
# A stack name should only exist within a network name if it is stack specific.
attempts_remaining=20
retry_wait_sec=1
allotted_time=$((attempts_remaining * retry_wait_sec))

# Keep looping until either the stack has had its networks destroyed, or a limit occurs.
echo -e "${INFO} Waiting for networks to shutdown"
while ! [[ -z $(docker network ls --filter label=com.docker.stack.namespace="${stack_name}" -q) ]]; do

    # Only check for a certain amount of time, or it may get stuck forever.
    attempts_remaining=$((attempts_remaining - 1))
    if [[ ${attempts_remaining} -lt 0 ]]; then
        echo -e "${ERROR} Exceeded the allotted amount of time to wait for the shutdown to complete (${allotted_time} sec)" >&2
        exit 1
    fi

    # Wait for an allotted amount of time before trying again.
    sleep ${retry_wait_sec}
done