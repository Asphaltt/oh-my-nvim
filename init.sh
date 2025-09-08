#!/bin/bash
# Copyright 2025 Leon Hwang.
# SPDX-License-Identifier: Apache-2.0

apt install -y \
    nodejs \
    npm \
    python3 \
    python3-venv \
    cmake
# clang-format
# clang-tools

pip3 install --break-system-packages \
    cpplint \
    pylint \
    autopep8 \
    clang-format \
    neovim
cpplint --version

echo "Recommend to upgrade neovim to latest version by downloading the appimage version from https://github.com/neovim/neovim/releases then 'mv nvim-xxx.appimage /usr/local/bin/nvim'"
