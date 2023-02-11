#!/usr/bin/env bash

__main() {
  directoryx="$(dirname -- $(readlink -fn -- "$0"; echo x))"
  directory="${directoryx%x}"

  target_path="/usr/local/bin/gcpath"

  if [ -h "$target_path" ]
  then
    echo "Already Installed"
    exit 1
  fi

  __setup_jq

  sudo ln -s "$directory/gcpath" $target_path

  echo "Installed"
  exit 0
}

__setup_jq() {
  echo "{}" | jq > /dev/null 2>&1

  if [ $? != 0 ]
  then
    # install jq
    brew install jq
  fi
}

__main $@
