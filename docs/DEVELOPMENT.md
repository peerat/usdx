# Development

## Baseline

Primary build:

```bash
platformio run -e uno
```

Local cache variant:

```bash
PLATFORMIO_CORE_DIR=.pio-core PLATFORMIO_SETTING_ENABLE_TELEMETRY=No platformio run -e uno
```

## Workflow

1. Make a small change.
2. Build `uno`.
3. If a feature flag changed, build the matching profile from `platformio.ini`.
4. If flash/RAM changed materially, update `MEMORY.md`.
5. If user-visible behavior changed, update `docs/USER_GUIDE_RU.md`.
6. If fork-level behavior changed, update `CHANGELOG.md`.

## Rules

- Do not reformat the whole `.ino`.
- Prefer compile-time switches over runtime branches when a feature is optional.
- Prefer `F("...")` for UI strings on AVR.
- Avoid `sprintf()`, `String`, dynamic allocation, and large stack buffers.
- Check flash impact of every new UI string and CAT response.

## Before Flashing

- `uno` must build successfully.
- Flash must still fit comfortably inside `32256 B`.
- No unexpected new warnings.
- If EEPROM defaults changed, note that in the user guide.
