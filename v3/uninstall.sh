#!/usr/bin/env bash

__main() {
  target_path="/usr/local/bin/gcpath"

  if ! [ -h "$target_path" ]
  then
    echo "Already Uninstalled"
    exit 1
  fi

  sudo rm $target_path

  echo "Uninstalled"
  exit 0
}

__main $@
