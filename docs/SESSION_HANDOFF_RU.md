# Передача состояния сессии

Этот файл нужен, чтобы после перезапуска сессии быстро восстановить контекст
и продолжить работу без повторного разбора проекта.

## Где лежит проект

- Рабочий каталог: `/home/peerat/projects/usdx`
- Основной файл прошивки: `R3VAF_uSDR_7_01v.ino`
- Подготовленный publish-клон для GitHub: `/tmp/usdx-publish.criTHC`

## Текущее состояние

- Версия прошивки в коде: `7.01v`
- Проект подготовлен как опорная точка перед переходом к более модульной
  "прошивке-трансформеру"
- `QUAD` вынесен в compile-time опцию и по умолчанию выключен
- `VOX_ENABLE` выключен
- `SEMI_QSK` выключен
- `TX_DELAY`, `CLOCK` и `QUAD` теперь тоже заведены в `USDX_DISABLE_*` профили
- `CW_MESSAGE` / `CW_MESSAGE_EXT` заведены в отдельный `USDX_DISABLE_*` профиль
- `CW_VOLUME` заведён в отдельный `USDX_DISABLE_*` профиль; выигрыш `72 B` flash
- `FAST_AGC` заведён в отдельный `USDX_DISABLE_*` профиль, но baseline уже без него
- `KEEP_BAND_DATA` заведён в отдельный `USDX_DISABLE_*` профиль, baseline уже без него
- `CW_INTERMEDIATE` заведён в отдельный `USDX_DISABLE_*` профиль
- `FILTER_700HZ` заведён в отдельный `USDX_DISABLE_*` профиль, baseline уже без него
- `CAT_XO_CMD` заведён в отдельный `USDX_DISABLE_*` профиль, baseline уже без него
- `CW_DEBUG_DISPLAY` удалён из прошивки как временный диагностический костыль
- верхний конфиг получил первый слой hardware preset `USDX_HW_*` с мостом на
  старые `BLACK_BRICK/RED_CORNERS/...` макросы
- дефолты железа `BACKLIGHT_MASK`, `SWAP_ROTARY`, `SWR_METER`,
  `LPF_SWITCHING_DL2MAN_USDX_REV3`, `F_XTAL`, `SI5351_ADDR`, `PTX` теперь
  собраны вокруг `USDX_HW_DEFAULT_*`, а не размазаны по нескольким условиям
- UI/display bridge слой тоже заведен сверху файла: `USDX_UI_LCD_I2C`,
  `USDX_UI_OLED_SSD1306`, `USDX_UI_OLED_SH1106`, `USDX_UI_CONDENSED`
  маппятся на legacy `LCD_I2C` / `OLED_*` / `CONDENSED`
- structural слой доведен еще на две группы выбора:
  `USDX_TX_*` теперь выбирает `PTX` / `NTX` / `TX_CLK0_CLK1`,
  а `USDX_INPUT_*` выбирает обычный rotary mode или `ONEBUTTON`
- в `docs/TRANSFORMER_PLAN_RU.md` зафиксированы правила совместимости:
  `hardware preset` выбирается один, `display backend` один, `LPF topology`
  одна, а модульные feature flags уже комбинируются поверх этой базы
- в коде добавлены compile-time guard'ы: несовместимые комбинации hardware/UI/LPF
  и зависимые флаги вроде `CAT_XO_CMD` без `CAT`/`RIT_ENABLE` теперь падают
  на этапе сборки с явной ошибкой
- в `platformio.ini` добавлены smoke-test env для hardware preset:
  `uno_hw_black_brick`, `uno_hw_red_buttons`, `uno_hw_trusdx`,
  `uno_hw_generic_27mhz`
- в `platformio.ini` добавлены structural smoke-test env:
  `uno_tx_ntx`, `uno_input_onebutton`
- в `platformio.ini` добавлены UI smoke-test env:
  `uno_ui_lcd_i2c`, `uno_ui_oled_ssd1306`, `uno_ui_oled_sh1106`,
  `uno_ui_oled_sh1106_condensed`
- в `platformio.ini` добавлены практические size-first env:
  `uno_size_headroom`, `uno_size_tight`, `uno_oled_ssd1306_cat_slim`,
  `uno_oled_sh1106_cat_slim`, `uno_size_digital`,
  `uno_oled_ssd1306_cat_tight`, `uno_oled_sh1106_cat_tight`
- compile-time guard'ы усилены еще на два "человеческих" случая:
  `MY_RED_CORNERS` теперь требует `RED_CORNERS`, а `ONEBUTTON_INV`
  требует `ONEBUTTON`
- baseline warning-cleanup проведен для `STARTUP_CALLSIGN`, `F_XTAL`,
  `IOEXP16_ADDR`, TX bitmask macros и I2C/LCD helper-макросов; текущий
  `pio run -e uno` снова собирается тихо без прежнего потока redefinition warning'ов
- Документация приведена к текущему состоянию
- `tools/size_profiles.sh` переведен на локальную сборку через `pio`
  и теперь включает не только измерительные `uno_no_*`, но и практические
  size-first / OLED slim-профили
- в `docs/USER_GUIDE_RU.md` добавлен отдельный раздел первого запуска на живой
  плате: проверка profile, EEPROM reset, порядок bring-up RX/TX и что смотреть
  при неправильной частоте/энкодере/подсветке

## Последние локальные коммиты

Внутренний git-репозиторий хранится в:

- `/home/peerat/projects/usdx/.git-local`

Последние коммиты:

- `dbdb4c0` - `Prepare public snapshot docs for transformer transition`
- `56c92a1` - `Snapshot firmware 7.01v before transformer refactor`

## Сборка

Базовая команда:

```bash
PLATFORMIO_CORE_DIR=/home/peerat/projects/usdx/.pio-core PLATFORMIO_SETTING_ENABLE_TELEMETRY=No pio run -e uno
```

Последний подтвержденный baseline:

- Flash: `31504 / 32256`
- RAM: `1440 / 2048`

Последняя проверка hardware preset:

- `uno` / `uno_hw_black_brick`: `Flash 31504`, `RAM 1440`
- `uno_hw_red_buttons`: `Flash 29898`, `RAM 1358`
- `uno_hw_trusdx`: `Flash 29898`, `RAM 1358`
- `uno_hw_generic_27mhz`: `Flash 29898`, `RAM 1358`

Последняя проверка structural bridge-профилей:

- `uno`: `Flash 31504`, `RAM 1440`
- `uno_tx_ntx`: `Flash 31504`, `RAM 1440`
- `uno_input_onebutton`: `Flash 30758`, `RAM 1440`

Последняя проверка UI/display preset:

- `uno`: `Flash 31504`, `RAM 1440`
- `uno_ui_lcd_i2c`: `Flash 31766`, `RAM 1440`
- `uno_ui_oled_ssd1306`: `Flash 32806`, `RAM 1444` -> не влезает
- `uno_ui_oled_sh1106`: `Flash 32988`, `RAM 1444` -> не влезает
- `uno_ui_oled_sh1106_condensed`: `Flash 33026`, `RAM 1444` -> не влезает

Последняя проверка size-first профилей:

- `uno_size_headroom`: `Flash 29402`, `RAM 1371`
- `uno_size_tight`: `Flash 27788`, `RAM 1289`
- `uno_size_digital`: `Flash 28268`, `RAM 1327`
- `uno_oled_ssd1306_cat_slim`: `Flash 30678`, `RAM 1375`
- `uno_oled_sh1106_cat_slim`: `Flash 30862`, `RAM 1375`
- `uno_oled_ssd1306_cat_tight`: `Flash 28980`, `RAM 1293`
- `uno_oled_sh1106_cat_tight`: `Flash 29162`, `RAM 1293`

## GitHub / сеть

GitHub push не был завершен из этой сессии, потому что в sandbox не работал DNS:

- `Could not resolve host: github.com`
- `Could not resolve host: api.github.com`

При этом подготовленный publish-клон уже существует:

- `/tmp/usdx-publish.criTHC`

Если в новой сессии сеть до GitHub работает, публиковать отсюда:

```bash
cd /tmp/usdx-publish.criTHC
gh repo create peerat/usdx --public --source=. --remote=origin --push
```

Если репозиторий уже создан:

```bash
cd /tmp/usdx-publish.criTHC
git remote add origin https://github.com/peerat/usdx.git
git push -u origin main
```

## Что делать дальше

После публикации на GitHub продолжить рефакторинг в сторону "трансформера":

1. Инвентаризация функций:
   - ядро
   - опции
   - экспериментальные
   - аппаратно-зависимые
2. Перенос всех включаемых функций в единый конфиг-слой сверху файла
3. Подготовка профилей сборки
4. Обновление документации по новой модульной схеме

Отдельная карта перехода и группировки compile-time опций теперь лежит в:

- `docs/TRANSFORMER_PLAN_RU.md`

## Что сказать новой сессии

Вставить примерно такой текст:

```text
Открой /home/peerat/projects/usdx/docs/SESSION_HANDOFF_RU.md, прочитай состояние проекта и продолжи работу.
Сначала проверь доступ к GitHub и при рабочей сети запушь /tmp/usdx-publish.criTHC в public repo peerat/usdx.
После этого продолжим рефактор прошивки в "трансформер".
```
