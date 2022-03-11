#!/bin/bash

ERROR() {
  echo -e '\u001b[91m'\[`date +%H:%M:%S`\] \[ERROR\] $@
}

SUCCESS() {
  echo -e '\u001b[92m'\[`date +%H:%M:%S`\] \[SUCCESS\] $@
}

WARNING() {
  echo -e '\u001b[33m'\[`date +%H:%M:%S`\] \[WARNING\] $@
}

INFO() {
  echo -e '\u001b[1m'\[`date +%H:%M:%S`\] \[INFO\] $@
}

export -f INFO WARNING SUCCESS ERROR >>/dev/null