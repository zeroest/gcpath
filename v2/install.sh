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

  ln -s "$directory/gcpath" $target_path

  echo "Installed"
  exit 0
}

__main $@
