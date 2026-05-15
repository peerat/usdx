# План перехода к универсальной прошивке

Этот документ фиксирует стартовую карту для перехода от текущего монолита
`R3VAF_uSDR_7_01v.ino` к более универсальной "прошивке-трансформеру" без
агрессивного разбиения на файлы и без изменения базового поведения.

## Цель

Сделать прошивку управляемой через единый compile-time конфиг-слой, где:

- аппаратный профиль выбирает железо, кварцы, дисплей, распиновку и LPF;
- функциональный профиль включает и отключает опциональные модули;
- экспериментальные флаги вынесены отдельно и не смешиваются с baseline;
- профили сборки позволяют измерять цену каждой функции в Flash/RAM.

Это соответствует текущему ограничению проекта: для ATmega328P безопаснее
держать один `.ino` с понятной структурой, чем преждевременно дробить код.

## Текущее состояние

База уже частично подготовлена:

- в верхнем конфиг-блоке есть основные пользовательские `#define`;
- появился первичный слой hardware preset `USDX_HW_*` с мостом на старые
  `BLACK_BRICK/RED_CORNERS/...` макросы;
- аппаратные дефолты `BACKLIGHT_MASK`, `SWAP_ROTARY`, `SWR_METER`,
  `LPF_SWITCHING_DL2MAN_USDX_REV3`, `F_XTAL`, `SI5351_ADDR` и `PTX` уже
  сведены к `USDX_HW_DEFAULT_*` вместо размазанных условий по верхнему конфигу;
- появился UI/display bridge слой `USDX_UI_*`, который маппит выбор
  `LCD_I2C`, `OLED_SSD1306`, `OLED_SH1106` и `CONDENSED` на legacy-макросы;
- появились bridge-группы `USDX_TX_*` и `USDX_INPUT_*`, которые маппят
  схему TX-управления и способ управления энкодером на legacy `PTX/NTX/TX_CLK0_CLK1`
  и `ONEBUTTON/ONEBUTTON_INV`;
- слой `USDX_DISABLE_*` уже работает для части модулей;
- в `platformio.ini` уже заведены первые `uno_no_*` профили;
- добавлены smoke-test env для железных пресетов `uno_hw_*`;
- добавлены smoke-test env для UI-вариантов `uno_ui_*`;
- добавлены практические size-first env для реальной экономии flash, а не только
  для измерения цены одного модуля;
- baseline-прошивка и документация зафиксированы перед рефактором.

## Группы compile-time опций

### 1. Аппаратный профиль

Эти опции описывают конкретное железо и должны быть собраны в один блок выбора
платформы/варианта:

- модель: `BLACK_BRICK`, `RED_CORNERS`, `RED_BUTTONS`, `WHITE_BUTTONS`, `TRUSDX`
- локальные поправки: `MY_RED_CORNERS`, `SWAP_ROTARY`, `REVERSE_BAND_CHANGE`
- дисплей и UI-железо: `LCD_I2C`, `OLED_SSD1306`, `OLED_SH1106`, `CONDENSED`
- частоты и тактирование: `F_XTAL`, `F_MCU`, `SI5351_ADDR`
- передающий тракт и выводы: `TX_ENABLE`, `NTX`, `PTX`, `TX_CLK0_CLK1`, `F_CLK2`
- аппаратные расширения: `LPF_SWITCHING_*`, `SWR_METER`, `VSS_METER`, `QCX`
- способ управления: `ONEBUTTON`, `ONEBUTTON_INV`

### 2. Функциональные модули

Эти опции составляют основную матрицу будущего "трансформера":

- CAT: `CAT`, `CAT_FAST`, `CAT_EXT`, `CAT_STREAMING`, `CAT_TX_CMD`, `CAT_XO_CMD`
- CW: `KEYER`, `KEY_CLICK`, `CW_MESSAGE`, `CW_MESSAGE_EXT`, `CW_VOLUME`
- CW decoder: `CW_DECODER`, `CW_INTERMEDIATE`
- RX/TX user features: `RIT_ENABLE`, `VOX_ENABLE`, `SEMI_QSK`, `TX_DELAY`
- band/memory behavior: `KEEP_BAND_DATA`, `CW_FREQS_QRP`, `CW_FREQS_FISTS`
- metering and menu extras: `CLOCK`, `FILTER_700HZ`

### 3. Экспериментальные и дорогие по памяти опции

Их лучше отделить от baseline и держать явно помеченными:

- `QUAD`
- `NR_FIR`
- `FAST_AGC`
- `FM_ARCTAN`
- `AM_MOD_MAGN_SQRT`
- `DIAG`
- `DEBUG`
- `DEBUG_G8RDI`
- `TESTBENCH`

### 4. Внутренние служебные макросы

Эти макросы важны для кода, но не должны торчать в пользовательском слое как
настройки "универсальной" прошивки:

- `_SERIAL`
- `OLED`
- `_DELAY`
- `AF_OUT`
- `NEW_TX`, `NEW_RX`
- `SECOND_ORDER_DUC`
- низкоуровневые LCD/I2C/DSP helper-макросы

## Ключевые зависимости

### Жесткие зависимости

- `CAT_XO_CMD` требует `RIT_ENABLE`.
- `CAT` или `TESTBENCH` вместе с не-OLED дисплеем включают `_SERIAL`.
- `LPF_SWITCHING_DL2MAN_USDX_REV3_NOLATCH` автоматически требует `LPF_SWITCHING_DL2MAN_USDX_REV3`.
- При выключении `TX_ENABLE` автоматически теряют смысл `KEYER`, `TX_DELAY`,
  `SEMI_QSK`, `RIT_ENABLE`, `VOX_ENABLE`, `MOX_ENABLE`.
- `CW_MESSAGE_EXT` имеет смысл только вместе с `CW_MESSAGE`.

Часть этих зависимостей уже усилена compile-time guard'ами прямо в `.ino`,
чтобы несовместимые комбинации падали на сборке, а не жили молча.

### Поведенческие зависимости

- `CAT` зависит от Serial, UI-состояния, VFO и TX/RX переключения.
- `RIT_ENABLE` влияет не только на UI, но и на CAT-команды и восстановление частоты.
- `SWR_METER` зависит от TX-состояния и чтения ADC.
- `CW_DECODER` зависит от RX DSP, UI и обновления экрана.
- `KEYER` связан с CW TX, таймингами и обработкой кнопок.
- `LPF_SWITCHING_*` зависит от диапазона, частоты и I2C/GPIO expander.
- `ONEBUTTON` меняет поведение ввода и требует отдельной проверки UI-навигации.

### Конфликты и зоны риска

- `CAT`, `CW_MESSAGE`, `SWR_METER` и другие крупные модули конкурируют за Flash.
- `QUAD` трогает TX DSP и уже помечен как рискованный по качеству SSB.
- `NR_FIR` дорог по памяти и CPU.
- `DEBUG`, `DIAG`, `TESTBENCH` не должны смешиваться с обычным baseline.
- `KEEP_BAND_DATA` меняет EEPROM-поведение и структуру параметров меню.
- дисплейные варианты (`LCD`, `LCD_I2C`, `OLED_*`) влияют на serial coexistence,
  скорость вывода и часть UI-веток.

## Правила выбора и совместимости

Ниже зафиксированы правила, какие compile-time опции являются выбором "ровно
одна из группы", а какие можно комбинировать.

### 1. Взаимоисключаемые группы

Эти группы должны давать не набор флагов, а именно выбор одного варианта:

- hardware preset: ровно один из `USDX_HW_BLACK_BRICK`, `USDX_HW_RED_CORNERS`,
  `USDX_HW_RED_BUTTONS`, `USDX_HW_WHITE_BUTTONS`, `USDX_HW_TRUSDX`,
  `USDX_HW_GENERIC_27MHZ`
- display backend: не больше одного из `LCD_I2C`, `OLED_SSD1306`,
  `OLED_SH1106`; если не выбран ни один, используется обычный parallel LCD
- UI bridge choice: не больше одного из `USDX_UI_LCD_I2C`,
  `USDX_UI_OLED_SSD1306`, `USDX_UI_OLED_SH1106`
- input mode profile: не больше одного из `USDX_INPUT_ROTARY`,
  `USDX_INPUT_ONEBUTTON` или legacy `ONEBUTTON`
- LPF switching topology: не больше одного основного варианта
  `LPF_SWITCHING_DL2MAN_USDX_REV1`, `REV2`, `REV2_BETA`, `REV3`,
  `WB2CBA_USDX_OCTOBAND`, `PE1DDA_USDXDUO`
- TX output wiring: ровно одна схема управления PA/PTT через `USDX_TX_PTX`,
  `USDX_TX_NTX`, `USDX_TX_CLK0_CLK1` или legacy `PTX/NTX/TX_CLK0_CLK1`

### 2. Опции-надстройки

Эти флаги не являются самостоятельным профилем, а только модифицируют базовый
вариант:

- `MY_RED_CORNERS` имеет смысл только поверх `RED_CORNERS`
- `REVERSE_BAND_CHANGE` имеет смысл только рядом с rotary profile
- `ONEBUTTON_INV` имеет смысл только вместе с `ONEBUTTON`
- `CONDENSED` имеет смысл только для `OLED_*` или `LCD2004`
- `LPF_SWITCHING_DL2MAN_USDX_REV3_NOLATCH` имеет смысл только вместе с
  `LPF_SWITCHING_DL2MAN_USDX_REV3`
- `CW_MESSAGE_EXT` имеет смысл только вместе с `CW_MESSAGE`
- `CAT_FAST`, `CAT_EXT`, `CAT_STREAMING`, `CAT_TX_CMD`, `CAT_XO_CMD` имеют
  смысл только вместе с `CAT`

### 3. Свободно комбинируемые модули

Эти модули по смыслу можно включать независимо, если хватает Flash/RAM и нет
отдельных зависимостей по коду:

- `SWR_METER`
- `KEYER`
- `CW_DECODER`
- `CW_VOLUME`
- `RIT_ENABLE`
- `VOX_ENABLE`
- `SEMI_QSK`
- `TX_DELAY`
- `CLOCK`
- `FILTER_700HZ`
- `KEEP_BAND_DATA`
- `FAST_AGC`
- `QUAD`

### 4. Глобальные gate-флаги

Некоторые флаги открывают или закрывают целый класс возможностей:

- `TX_ENABLE`:
  при выключении теряют смысл `KEYER`, `TX_DELAY`, `SEMI_QSK`, `VOX_ENABLE`,
  `MOX_ENABLE`, `PTX`, `NTX`, `TX_CLK0_CLK1`, SWR-пути в TX и часть CAT/TX UI
- `CAT`:
  открывает всю подгруппу `CAT_*` и может включать `_SERIAL` при не-OLED
  фронтенде
- `OLED`:
  не выбирается напрямую пользователем, а является производным от
  `OLED_SSD1306` или `OLED_SH1106`

### 5. Практическое правило для "трансформера"

Верхний конфиг должен постепенно прийти к такой форме:

1. один `hardware preset`
2. один `display backend`
3. один `LPF topology`, если нужен
4. ноль или больше модульных feature flags
5. ноль или больше опций-надстроек, но только поверх уже выбранной базы

Именно эта схема убирает двусмысленность вида "включили два экрана сразу" или
"одновременно задали два несовместимых LPF-варианта".

## Что уже переведено в профильный слой

На текущий момент `USDX_DISABLE_*` уже существуют для:

- `CAT`
- `SWR_METER`
- `LPF_SWITCHING_*`
- `KEYER`
- `CW_DECODER`
- `VOX_ENABLE`
- `SEMI_QSK`
- `RIT_ENABLE`
- `TX_DELAY`
- `CLOCK`
- `QUAD`
- `CW_MESSAGE` / `CW_MESSAGE_EXT`
- `CW_VOLUME`
- `FAST_AGC`
- `KEEP_BAND_DATA`
- `CW_INTERMEDIATE`
- `FILTER_700HZ`
- `CAT_XO_CMD`

Их профили уже отражены в `platformio.ini` как `uno_no_*`.

## Что еще нужно довести до "трансформерного" формата

Первый кандидатный список для следующей волны `USDX_DISABLE_*`:

Для каждого такого модуля нужен одинаковый шаблон:

1. единая точка включения в верхнем конфиг-блоке;
2. `USDX_DISABLE_*` переопределение ниже;
3. отдельный `uno_no_*` профиль в `platformio.ini`;
4. проверка baseline и профильной сборки;
5. обновление `MEMORY.md`, если размер изменился.

## Порядок работ

### Этап 1. Нормализовать конфиг-слой без смены логики

Собрать верхнюю часть `.ino` в четыре секции:

- `hardware profile`
- `feature toggles`
- `experimental toggles`
- `build overrides`

На этом этапе код ниже не переписывать, только упорядочить входные флаги.

### Этап 2. Довести опциональные модули до общего стандарта

Постепенно перевести оставшиеся функции на схему `USDX_DISABLE_*` и добавить
соответствующие `uno_no_*` env для измерения стоимости.

### Этап 3. Сформировать реальные аппаратные профили

Выделить 2-4 поддерживаемых профиля, например:

- baseline `red_corners`
- `black_brick`
- `trusdx`
- минимальный `generic_27mhz`

Важно: это должны быть compile-time профили, а не новый runtime-конфиг.

Промежуточное состояние уже есть: верхний конфиг использует `USDX_HW_*` как
новую точку входа, а код ниже пока продолжает жить на legacy-макросах. Это
позволяет постепенно переносить железные дефолты без большого risky rewrite.

По display/UI уже есть полезные замеры на текущем baseline-наборе функций:

- `LCD_I2C` еще влезает в Uno: `31766 B flash`, `1440 B RAM`;
- `OLED_SSD1306` уже не влезает: `32806 B flash`, `1444 B RAM`;
- `OLED_SH1106` тоже не влезает: `32988 B flash`, `1444 B RAM`;
- `SH1106 + CONDENSED` не спасает: `33026 B flash`, `1444 B RAM`.

При этом уже есть и реальные slim-профили, которые проходят по памяти:

- `uno_size_headroom`: `29402 B flash`, `1371 B RAM`
- `uno_size_tight`: `27788 B flash`, `1289 B RAM`
- `uno_size_digital`: `28268 B flash`, `1327 B RAM`
- `uno_oled_ssd1306_cat_slim`: `30678 B flash`, `1375 B RAM`
- `uno_oled_sh1106_cat_slim`: `30862 B flash`, `1375 B RAM`
- `uno_oled_ssd1306_cat_tight`: `28980 B flash`, `1293 B RAM`
- `uno_oled_sh1106_cat_tight`: `29162 B flash`, `1293 B RAM`

Это уже дает практическую матрицу под маленький размер:

- если нужен baseline UX/CAT/SWR, но нужен запас flash: `uno_size_headroom`
- если важнее именно headroom под Uno и SWR не критичен: `uno_size_tight`
- если радио используется как SSB/FT8/CAT без CW TX/RX: `uno_size_digital`
- если нужен OLED на Uno и хочется не просто "влезает", а нормальный запас:
  `uno_oled_*_cat_tight`

### Этап 4. Почистить модульные границы внутри монолита

После стабилизации флагов можно локально улучшать структуру:

- группировать данные и функции по модулям;
- убирать неиспользуемые ветки после отключения опций;
- сокращать дублирующиеся `#ifdef` там, где это безопасно.

## Практический следующий шаг

Следующий маленький безопасный патч:

1. нормализовать верхний конфиг-блок `.ino` по секциям;
2. не менять набор включенных функций;
3. не трогать DSP и тайминговые участки;
4. собрать `uno`;
5. собрать существующие `uno_no_*` профили и убедиться, что поведение
   профильного слоя не сломалось.

Именно с этого шага удобно начинать реальный рефактор "трансформера".
