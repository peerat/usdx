# uSDX / uSDR Firmware Fork

Рабочий форк прошивки uSDX/uSDR для ATmega328P/Arduino Uno.

![uSDX transceiver](usdx.png)

## Ownership

- Current fork and maintenance: Peerat
- Current GitHub repo: `https://github.com/peerat/usdx`
- Current author channel: `https://t.me/ham33operator`
- Base source project: `https://github.com/threeme3/QCX-SSB`
- Base DSP/firmware author: Guido PE1NNZ
- Prior major modification layer preserved in this fork: Rob Colclough GW8RDI
- License and origin notes: [LICENSE.md](LICENSE.md)

Проект держится как практичная рабочая прошивка под реальное радио и как база
для конфигурируемого "трансформера" под разные варианты железа.

## What Changed Relative To Base

Эта ветка не переписывает базовую прошивку с нуля, а делает ее удобнее для
живого использования на конкретном трансивере. Относительно базовой QCX-SSB/uSDX
здесь изменены меню и кнопки, приведены в порядок дефолты под SSB/CW/FT8,
добавлены CAT `115200`, SWR, автопрокрутка с адаптивной остановкой по сигналу,
точная подстройка к локальному максимуму, более понятный экран и поддержка
разных вариантов железа.

## Status

- Main firmware: `R3VAF_uSDR_7_01v.ino`
- Current baseline firmware: `7.01w`
- Current baseline build zone: `Flash 32066 / 32256`, `RAM 1396 / 2048`
- Default `ScanStop`: `+3 dB`

## Project Structure

| Path | Purpose |
| --- | --- |
| `R3VAF_uSDR_7_01v.ino` | Main firmware |
| `MEMORY.md` | Flash/RAM map and size profiles |
| `CHANGELOG.md` | Important fork-level changes only |
| `LICENSE.md` | Source and license notes |
| `docs/USER_GUIDE_RU.md` | User guide and live-board bring-up |
| `docs/ARCHITECTURE.md` | Firmware and repo structure |
| `docs/DEVELOPMENT.md` | Internal development workflow |

Подробности по памяти: [MEMORY.md](MEMORY.md)

## Docs

- User guide: [docs/USER_GUIDE_RU.md](docs/USER_GUIDE_RU.md)
- Architecture: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Development: [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)
- Changelog: [CHANGELOG.md](CHANGELOG.md)
