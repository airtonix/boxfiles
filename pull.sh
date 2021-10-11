#!/bin/sh
# Stop unpredictible behavior
set -o errexit # Exit on most errors
set -o nounset # Disallow expansion of unset variables

# Define constants
PLAYBOOK_ACCOUNT="airtonix"
PLAYBOOK_REPO="boxfiles"
PLAYBOOK_BRANCH="master"

log () {
    prefix='[DOTFILES-INSTALL]'
    timestamp=$(date +%y/%m/%d_%H:%M:%S)
    echo "$prefix $timestamp :: ${*}"
}

info () {
    [ -n "${VERBOSE}" ] && log "${*}"
}

BOXFILES_TMP_STORAGE=$(mktemp -d -t "${PLAYBOOK_ACCOUNT}-${PLAYBOOK_REPO}-${PLAYBOOK_BRANCH}-XXXXXX")
BOXFILES_SOURCEFILE="${BOXFILES_TMP_STORAGE}/boxfiles.zip"
BOXFILES_INSTALL_TARGET=$HOME/.dotfiles
BOXFILES_INSTALL_CMD=run.sh

info "
  BOXFILES_TMP_STORAGE: ${BOXFILES_TMP_STORAGE}
  BOXFILES_SOURCEFILE: ${BOXFILES_SOURCEFILE}
  BOXFILES_INSTALL_TARGET: ${BOXFILES_INSTALL_TARGET}
"

Download () {
  Url=$1
  File=$2
  log "Downloading ${Url} to ${File}"
  [ -z "${BOXFILES_NODOWNLOAD}" ] && curl -L $Url --output $File
  info "$(ls -a1 "$(dirname ${File})")"
}

Unzip () {
  File=$1
  Destination=${2:-pwd}
  log "Unzipping ${File} to ${Destination}"
  [ -z "${BOXFILES_NOUNZIP}" ] && \
    mkdir -p "${Destination}" && \
    unzip "${File}" -d "${BOXFILES_TMP_STORAGE}" && \
    mv "${BOXFILES_TMP_STORAGE}/*/*" "${Destination}"
  info "Files unzipped: $(find "${Destination}" -type f | wc -l)"
}

Setup () {
  Current=$(pwd)
  Source=$1
  log "Setup ${Source}"
  cd "${Source}"
  [ -z "${BOXFILES_NOSETUP}" ] && \
  [ -f "${BOXFILES_INSTALL_CMD}" ] && \
    chmod +x $BOXFILES_INSTALL_CMD && \
    $BOXFILES_INSTALL_CMD

  cd "${Current}"
}

Clean () {
  Target=$1
  log "Clean ${Target}"
  [ -z "${BOXFILES_NOCLEAN}" ] && \
    [ -d "$Target" ] &&
    rm -rf "${Target}"
}

log "Start"

Download "https://github.com/${PLAYBOOK_ACCOUNT}/$PLAYBOOK_REPO/archive/$PLAYBOOK_BRANCH.zip" "$BOXFILES_SOURCEFILE"
Clean "$BOXFILES_INSTALL_TARGET"
Unzip "$BOXFILES_SOURCEFILE" "$BOXFILES_INSTALL_TARGET"
Setup "$BOXFILES_INSTALL_TARGET"

log "Done"
