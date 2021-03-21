#!/bin/sh
# Stop unpredictible behavior
set -o errexit # Exit on most errors
set -o nounset # Disallow expansion of unset variables
set -o pipefail # Use last non-zero exit code in a pipeline

source ./lib.sh

function setup_ansible () {
  osinformation

  files=(
    "${OSINFO_PLATFORM}_${OSINFO_ARCH}_${OSINFO_NAME}_${OSINFO_VERSION}"
    "${OSINFO_PLATFORM}_${OSINFO_ARCH}_${OSINFO_NAME}"
    "${OSINFO_PLATFORM}_${OSINFO_ARCH}"
    "${OSINFO_PLATFORM}"
  )

  for item in "${files[@]}"; do
    [ -f "setup_${item}.sh" ] \
      && {
        echo "Setting up ${item}";
        "./setup_${item}.sh";
        break;
      }
  done
}

function install_requirements () {
  ansible-playbook \
    --verbose \
    playbooks/galaxy.yml
}

function run_playbook () {
  ansible-playbook \
    --verbose \
    --ask-become-pass \
    playbooks/workstation-${OSINFO_PLATFORM}.yml \
    "${@:-}"
}

function main () {
    local operation="${1:-provision}"
    echo "operation: $operation"

    local count="${#@}"

    [ "$count" -gt "0" ] && shift 1;
    [ "$count" -gt "0" ] && args=("${@}");

    case $operation in
        info)
            echo "== Info =="
            osinformation
            echo """
    platform: ${OSINFO_PLATFORM}
        arch: ${OSINFO_ARCH}
        name: ${OSINFO_NAME}
     version: ${OSINFO_VERSION}
            """
        ;;
        setup)
            echo "== Debug =="
            setup_ansible
        ;;
        requirements)
            echo "== Requirements =="
            install_requirements
        ;;
        provision)
            echo "== Workstation: ${OSINFO_PLATFORM} =="
            setup_ansible
            install_requirements
            run_playbook "playbooks/workstation-${OSINFO_PLATFORM}.yml" ${args[@]:-}
        ;;
    esac
}


# Run the script
main "$@"
