#!/usr/bin/env bash

docker run --interactive --tty --workdir=/workdir --volume $PWD/.azure:/root/.azure --volume $PWD:/workdir --rm -it microsoft/azure-cli:0.9.14 azure $*