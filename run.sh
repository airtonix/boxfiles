#!/bin/sh
# Stop unpredictible behavior
set -o errexit # Exit on most errors
set -o nounset # Disallow expansion of unset variables

. ./lib.sh

setup_ansible () {
  setup_file=get_setupfile
  echo "== Setup =="
  echo "> ${setup_file}";
  $setup_file
}

install_requirements () {
  echo "== Requirements =="
  ansible-playbook \
    --verbose \
    playbooks/galaxy.yml
}

list_tags () {
  playbook_file=$(get_playbook_file)
  echo "== Tags: ${playbook_file} =="
  ansible-playbook --list-tags $playbook_file 2>&1 |
    grep "TASK TAGS" |
    cut -d":" -f2 |
    awk '{sub(/\[/, "")sub(/\]/, "")}1' |
    sed -e 's/,//g' |
    xargs -n 1 |
    sort -u |
    column
}

run_playbook () {
  echo "== Provision: ${OSINFO_PLATFORM} =="
  # playbook=$(get_playbook_file)
  ansible-playbook \
    --verbose \
    --ask-become-pass \
     \
    "${@:-}"
}

print_help () {
  echo """
  == Help ==

  ./run.sh [command] [args]

  -- Commands --
  provision|start         install all the things
  info                    print environment info
  setup                   setup ansible and dependencies
  requiremenst|deps       setup dependencies
  tags                    list all the tags in the playbook
  help                    this text.

  -- Args --

  provision --tags=
  """
}

provision () {
  [ -z "${SKIP_SETUP:-}" ] && setup_ansible
  [ -z "${SKIP_DEPS:-}" ] && install_requirements
  run_playbook "playbooks/workstation-${OSINFO_PLATFORM}.yml" "${@:-}"
}

main () {
    local operation="${1:-}"
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
        help)
            print_help
        ;;
        setup)
            setup_ansible
            install_requirements
        ;;
        requirements|deps)
            install_requirements
        ;;
        tags)
            list_tags
        ;;
        tagged)
            provision --tags ${args[@]:-}
        ;;
        *)
            provision ${args[@]:-}
        ;;
    esac
}


# Run the script
main "$@"
