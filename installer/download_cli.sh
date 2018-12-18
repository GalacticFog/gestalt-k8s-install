#!/bin/bash

gestalt_cli_version=0.10.6

exit_with_error() {
  echo "[Error] $@"
  exit 1
}

exit_on_error() {
  if [ $? -ne 0 ]; then
    exit_with_error $1
  fi
}

if [ ! -f './fog' ]; then
    os=`uname`

    if [ "$os" == "Darwin" ]; then
        url="https://github.com/GalacticFog/gestalt-fog-cli/releases/download/${gestalt_cli_version}/gestalt-fog-cli-macos-${gestalt_cli_version}.zip"
    elif [ "$os" == "Linux" ]; then
        url="https://github.com/GalacticFog/gestalt-fog-cli/releases/download/${gestalt_cli_version}/gestalt-fog-cli-linux-${gestalt_cli_version}.zip"
    else
        echo
        echo "Warning: unknown OS type '$os', treating as Linux"
    fi

    if [ ! -z "$url" ]; then
        echo
        echo "Downloading Gestalt fog CLI $gestalt_cli_version..."

        curl -L $url -o fog.zip
        exit_on_error "Failed to download 'fog' CLI, aborting."

        echo
        echo "Unzipping..."

        unzip -o fog.zip
        exit_on_error "Failed to unzip 'fog' CLI package, aborting."

        rm fog.zip
    fi
fi
