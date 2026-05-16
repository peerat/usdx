# Development

## Workflow

1. Make a small change.
2. Verify that the baseline firmware still fits and behaves as expected.
3. If a hardware or feature toggle changed, re-check the matching configuration.
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

- Baseline firmware must still build successfully.
- Flash must still fit inside `32256 B`.
- No unexpected new warnings.
- If EEPROM defaults changed, note that in the user guide.
