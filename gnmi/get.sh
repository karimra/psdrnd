#!/bin/bash

set -e

lab=$1
node=$2
xpath=$3

usage() {
  echo "usage: $0 [lab] [dut] [path] : send get request to [dut] in [lab] with [path]"
  echo "       $0 help : print this help"
  exit 1
}

if [ -z "$lab" ]; then
  usage
fi

if [ -z "$node" ]; then
  usage
fi

if [ -z "$xpath" ]; then
  usage
fi

if [ "$1" == "help" ]; then
  usage
fi

nodeIP=$(docker ps --filter "label=lab-$lab=$node" -q | xargs -n1 docker inspect $node -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')

if [ z "$nodeIP" ]; then
  echo "IP address for lab=$lab, node=$node not found"
  exit 1
fi

basecmd="gnmic -a $nodeIP -u admin -p admin -e json_ietf --config /dev/null --skip-verify --log"
$basecmd get --path $xpath