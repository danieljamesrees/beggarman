#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ -z "${AWS_ACCESS_KEY_ID}" ]]; then
  echo Must specify AWS_ACCESS_KEY_ID
  exit 1
fi

if [[ -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
  echo Must specify AWS_SECRET_ACCESS_KEY
  exit 1
fi

if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
  echo Must specify AWS_DEFAULT_REGION
  exit 1
fi

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_pip3() {
  sudo apt install python3-pip
}

install_aws_cli() {
  pip3 install awscli --upgrade --user
}

install_aws_supporting_tools() {
  sudo apt install jq
}

WORKING_TERRAFORM_VERSION="0.10.8"
WORKING_TERRAFORM_PATH="${__dir}/terraform_${WORKING_TERRAFORM_VERSION}/terraform"

if [[ ! -f "${WORKING_TERRAFORM_PATH}" ]]; then
  TEMP_FILE=$(mktemp)
  wget "https://releases.hashicorp.com/terraform/${WORKING_TERRAFORM_VERSION}/terraform_${WORKING_TERRAFORM_VERSION}_linux_amd64.zip" --output-document="${TEMP_FILE}"
  unzip -o -d terraform_"${WORKING_TERRAFORM_VERSION}" "${TEMP_FILE}"
  rm "${TEMP_FILE}"
fi
#if ! command -v terraform; then
#  sudo snap install terraform
#fi

if ! command -v git; then
  sudo snap install git
fi

cd "${__dir}/terraform"

"${WORKING_TERRAFORM_PATH}" init
"${WORKING_TERRAFORM_PATH}" apply

install_pip3
install_aws_cli
install_aws_supporting_tools

PATH=~/.local/bin:$PATH ./vault_helper.sh

cd "${__dir}"
