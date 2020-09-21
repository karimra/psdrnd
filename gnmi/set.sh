#!/bin/bash

set -e

lab=$1
node=$2
file=$3

if [ -z "$file" ]; then
  file="config/$lab/$node.yaml"
fi

usage() {
  echo "usage: $0 [lab] [dut] [path_to_file]: send set request to [dut] with config in file [path_to_file]"
  echo "       $0 help : print this help"
  exit 0
}

if [ -z "$lab" ]; then
  usage
fi

if [ -z "$node" ]; then
  usage
fi

if [ "$1" == "help" ]; then
  usage
fi

nodeIP=$(docker ps --filter "label=lab-$lab=$node" -q | xargs -n1 docker inspect $node -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')

if [ -z "$nodeIP" ]; then
  echo "IP address for lab=$lab, node=$node not found"
  exit 1
fi

basecmd="gnmic -a $nodeIP -u admin -p admin -e json_ietf --config /dev/null --skip-verify --log"

$basecmd set --update-path / --update-file $file

#$basecmd get --path /