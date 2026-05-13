#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PIO_CORE_DIR="${PLATFORMIO_CORE_DIR:-$(pwd)/.pio-core}"
export PLATFORMIO_CORE_DIR="$PIO_CORE_DIR"
export PLATFORMIO_SETTING_ENABLE_TELEMETRY="${PLATFORMIO_SETTING_ENABLE_TELEMETRY:-No}"
PIO_BIN="${PIO_BIN:-pio}"

profiles=(
  uno
  uno_no_swr
  uno_no_lpf
  uno_no_cw_decoder
  uno_no_vox
  uno_no_semi_qsk
  uno_no_rit
  uno_no_keyer
  uno_no_cat
)

for env in "${profiles[@]}"; do
  printf '\n===== %s =====\n' "$env"
  "$PIO_BIN" run -e "$env" 2>&1 | grep -E 'RAM:|Flash:|FAILED|SUCCESS|error:'
done
