#!/usr/bin/env bash

# --- Load configuration ------------------------------------------------------
_COMMON_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_COMMON_LIB_DIR/config.sh"

# --- Colours -----------------------------------------------------------------
RED=$'\033[0;31m'; YEL=$'\033[1;33m'; GRN=$'\033[0;32m'; BLU=$'\033[0;34m'; NC=$'\033[0m'
PASS="${GRN}✅${NC}"; WARN="${YEL}⚠️ ${NC}"; FAIL="${RED}❌${NC}"; INFO="${BLU}ℹ️ ${NC}"

# --- Helpers -----------------------------------------------------------------
step()  { echo -e "\n${BLU}▶ $1${NC}"; }
ok()    { echo -e "  ${PASS} $1"; }
warn()  { echo -e "  ${WARN} $1"; }
fail()  { echo -e "  ${FAIL} $1"; }
info()  { echo -e "  ${INFO} $1"; }
die()   { echo -e "\n${FAIL} $1\n"; exit 1; }

REPO_ROOT="${INFRA_ROOT:-$(pwd)}"

PROFILE="${K8_AWS_PROFILE}"
EXPECTED_ACCOUNT="${K8_AWS_ACCOUNT_ID}"
ONE_PASS_LINK="${K8_CREDENTIALS_LINK}"
TF_DIR="${K8_TF_DIR:-$REPO_ROOT/terraform/production}"
