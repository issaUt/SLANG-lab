#!/usr/bin/env sh
set -eu

SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET_DIR="${HOME}/.vscode-server/extensions/local.slang-language-0.1.0"

rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -R "$SOURCE_DIR"/. "$TARGET_DIR"/

printf 'Installed SLANG Language Support to %s\n' "$TARGET_DIR"
printf 'Reload VSCode, then open a .SL or .sl file.\n'
