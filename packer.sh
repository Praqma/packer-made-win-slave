#!/usr/bin/env bash

docker run --interactive --tty --workdir=/workdir --volume $PWD:/workdir --rm -e PACKER_CACHE_DIR=/workdir/.packer_cache -e PACKER_LOG=1 -e PACKER_LOG_AZURE_MAXLEN=3000 -it packer-azure:0.8.6 packer $*