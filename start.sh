#!/bin/sh
set -eu
cd "$(dirname "$0")"
if [ ! -f theme/shaders/hair-wind.vert.qsb ] || [ theme/shaders/hair-wind.vert -nt theme/shaders/hair-wind.vert.qsb ]; then ./theme/shaders/build.sh; fi
if [ ! -x preview/qt-preview ] || [ preview/preview.cpp -nt preview/qt-preview ] || [ preview/context.h -nt preview/qt-preview ]; then ./preview/build.sh; fi
if ! systemctl --user is-active --quiet rezero-sddm-preview.service; then
    systemd-run --user --collect --unit=rezero-sddm-preview --description='Re:Zero local QML theme preview' \
        --setenv="REZERO_X11VNC=${REZERO_X11VNC:-}" \
        --setenv="REZERO_CAVA=${REZERO_CAVA:-}" \
        --setenv="REZERO_WEBSOCKIFY_PYTHON=${REZERO_WEBSOCKIFY_PYTHON:-}" \
        "$(command -v python3)" "$PWD/preview/serve.py"
fi
printf '%s\n' 'http://localhost:8770/'
