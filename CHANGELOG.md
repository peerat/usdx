# Changelog

Здесь остаются только важные пользовательские и архитектурные изменения форка.

## 2026-05-15

- Версия форка поднята до `7.01w`.
- Завершен structural cleanup baseline:
  скрытая сервисная `CAL_IQ` ветка выключена по умолчанию, убраны недостижимые
  menu post-handler'ы `BAND`, `VFOSEL`, `RIT`, `CALIB`.
- Освобожден рабочий запас flash для baseline `uno`.
- Текущий baseline `uno`: `Flash 32056 / 32256`, `RAM 1396 / 2048`.

## 2026-05-14

- Завершен transformer config layer:
  `USDX_HW_*`, `USDX_UI_*`, `USDX_TX_*`, `USDX_INPUT_*`, `USDX_DISABLE_*`.
- Добавлены hardware/UI/size build profiles в `platformio.ini`.
- Добавлены compile-time guard'ы для несовместимых комбинаций.
- Удален `CW_DEBUG_DISPLAY`.

## 2026-05-13

- Зафиксирован public snapshot перед переходом к "прошивке-трансформеру".
- Введены size-first профили и карта модулей в `MEMORY.md`.
- Подготовлен baseline bring-up для живой платы.
