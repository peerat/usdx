# Architecture

## Ownership

- Current fork and maintenance: Peerat
- Current GitHub repo: `https://github.com/peerat/usdx`
- Base project: `https://github.com/threeme3/QCX-SSB`
- Base DSP/firmware author: Guido PE1NNZ
- Prior major modification layer preserved in this fork: Rob Colclough GW8RDI

## Repository

| Path | Purpose |
| --- | --- |
| `R3VAF_uSDR_7_01v.ino` | Main firmware source |
| `platformio.ini` | Build profiles |
| `MEMORY.md` | Size map |
| `CHANGELOG.md` | Important fork changes |
| `LICENSE.md` | Source and license notes |
| `docs/USER_GUIDE_RU.md` | User-facing guide |
| `docs/DEVELOPMENT.md` | Dev workflow |
| `tools/size_profiles.sh` | Batch build helper |

## Firmware Structure

`R3VAF_uSDR_7_01v.ino` remains a single-file AVR firmware on purpose.

Main zones:

- Transformer config layer:
  hardware, display, TX wiring, input mode, feature flags, build overrides.
- Low-level IO:
  LCD/OLED, I2C bit-bang, ADC, GPIO, encoder.
- Si5351 / VFO:
  frequency calculation and clock programming.
- RX DSP:
  sampling, filtering, AGC, NR, S-meter.
- TX path:
  modulation, CW TX, PTT, RX/TX switching.
- UI and menu:
  screen render, parameter edit, EEPROM state.
- CAT:
  serial control protocol.

## Supported Build Axes

- Hardware preset: `USDX_HW_*`
- Display/UI preset: `USDX_UI_*`
- TX wiring: `USDX_TX_*`
- Input mode: `USDX_INPUT_*`
- Feature disable overrides: `USDX_DISABLE_*`

## Constraint

ATmega328P leaves very little flash/RAM headroom, so structure here is optimized
for predictable builds, not for aggressive file-splitting.
