#!/bin/sh
# Stop unpredictible behavior
set -o errexit # Exit on most errors
set -o nounset # Disallow expansion of unset variables
set -o pipefail # Use last non-zero exit code in a pipeline

# Define constants
readonly PLAYBOOK_ACCOUNT="airtonix"
readonly PLAYBOOK_REPO="boxfiles"
readonly PLAYBOOK_BRANCH="master"

function log() {
    local prefix='[DOTFILES-INSTALL]'
    local timestamp=`date +%y/%m/%d_%H:%M:%S`
    echo $prefix $timestamp :: "${*}"
}

function info() {
    [[ ! -z "${VERBOSE}" ]] && log "${*}"
}

readonly BOXFILES_TMP_STORAGE=$(mktemp -d -t $account-$repo-$branch-XXXXXX)
readonly BOXFILES_SOURCEFILE="${BOXFILES_TMP_STORAGE}/boxfiles.zip"
readonly BOXFILES_INSTALL_TARGET=$HOME/.dotfiles
readonly BOXFILES_INSTALL_CMD=run.sh

info "
  BOXFILES_TMP_STORAGE: ${BOXFILES_TMP_STORAGE}
  BOXFILES_SOURCEFILE: ${BOXFILES_SOURCEFILE}
  BOXFILES_INSTALL_TARGET: ${BOXFILES_INSTALL_TARGET}
"

function Download {
  local Url=$1
  local File=$2
  log "Downloading ${Url} to ${File}"
  [ -z "${BOXFILES_NODOWNLOAD}" ] && curl -L $Url --output $File
  info $(ls -a1 $(dirname ${File}))
}

function Unzip {
  local File=$1
  local Destination=${2:-pwd}
  log "Unzipping ${File} to ${Destination}"
  [ -z "${BOXFILES_NOUNZIP}" ] && \
    mkdir -p $Destination && \
    unzip $File -d $BOXFILES_TMP_STORAGE && \
    mv $BOXFILES_TMP_STORAGE/*/* $Destination
  info Files unzipped: $(find "$Destination" -type f | wc -l)
}

function Setup {
  local Current=$(pwd)
  local Source=$1
  log "Setup ${Source}"
  cd $Source
  [ -z "${BOXFILES_NOSETUP}" ] && \
  [ -f "${BOXFILES_INSTALL_CMD}" ] && \
    chmod +x $BOXFILES_INSTALL_CMD && \
    $BOXFILES_INSTALL_CMD

  cd $Current
}

function Clean {
  local Target=$1
  log "Clean ${Target}"
  [ -z "${BOXFILES_NOCLEAN}" ] && \
    [ -d "$Target" ] &&
    rm -rf $Target
}

log "Start"

Download "https://github.com/${PLAYBOOK_ACCOUNT}/$PLAYBOOK_REPO/archive/$PLAYBOOK_BRANCH.zip" $BOXFILES_SOURCEFILE
Clean $BOXFILES_INSTALL_TARGET
Unzip $BOXFILES_SOURCEFILE $BOXFILES_INSTALL_TARGET
Setup $BOXFILES_INSTALL_TARGET

log "Done"
