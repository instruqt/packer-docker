#!/bin/bash

set -e -o pipefail

apt install -y jq
curl -sfL https://get.k3s.io | sh -
