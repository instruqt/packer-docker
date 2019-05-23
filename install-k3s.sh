#!/bin/bash

set -e -o pipefail

curl -sfL https://get.k3s.io | sh -
systemctl disable k3s
