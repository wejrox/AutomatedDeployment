#!/bin/bash
#
# Deploys a docker swarm stack.
# If an environment file is provided, it is sourced.
#
# Args:
# 1: Stack name to deploy.
# 2: (Optional) Path to an additional source file to get variables from.

# Logging constants.
INFO="[\e[94mINFO\e[39m]"
WARN="[\e[93mWARN\e[39m]"
ERROR="[\e[91mERROR\e[39m]"

if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
    echo -e "Expected 1 or 2 arguments, received $#." >&2
    echo -e "This script requires a stack name, and optionally an additional environment script to source." >&2
    echo -e "Example: $0 proxy ~/custom.env" >&2
    exit 1
fi

stack_name=${1}
custom_env_file="${2}"

# Source the custom environment file if requested, which can override the variables set up by the previous commands.
# Validate that the file exists, that it's actually a file and that it is executable.
if [[ ! -z "${custom_env_file}" ]]; then
    if [[ -f "${custom_env_file}" && -x "${custom_env_file}" ]]; then
        echo -e "${INFO} Sourced ${custom_env_file}."
        source "${custom_env_file}"
    else
        echo -e "${ERROR}: Environment file '${custom_env_file}' is one of the following: Non-existent, A directory," \
                "or Not executable."
        exit 1
    fi
fi

echo -e "${INFO} Sourced all environment files, deploying '${stack_name}' stack."

# Run deploy on the requested stack.
docker stack deploy --prune --with-registry-auth --resolve-image="always" --compose-file "${stack_name}/docker-compose.yml" "${stack_name}"
