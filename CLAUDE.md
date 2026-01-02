# ZMK Config

This is a ZMK firmware configuration for the Corne (42-key) and Sofle (58-key) split keyboards.

## Project Structure

- `config/` - Keyboard configuration files
  - `common.keymap` - Shared keymap layers and behaviors (included by both boards)
  - `corne.keymap` - Corne-specific layout wrapper macros
  - `sofle.keymap` - Sofle-specific layout wrapper macros
  - `*.conf` - Kconfig settings per board
  - `*.overlay` - Devicetree overlays
- `build.yaml` - GitHub Actions build matrix configuration
- `zmk/`, `zephyr/`, `modules/` - West workspace dependencies

## Keymap Architecture

The keymaps use a macro-based wrapper pattern to reduce duplication:

1. **Board-specific files** (`corne.keymap`, `sofle.keymap`) define layout macros:
   - `EXTRA_ROW_*` - Number row (empty on Corne, populated on Sofle)
   - `ENCODER_L/R` - Encoder column (empty on Corne)
   - `THUMB_BASE/TRANS` - Thumb cluster (3 keys on Corne, 5 on Sofle)
   - `SENSOR_BINDINGS` - Rotary encoder config (empty on Corne)

2. **Common file** (`common.keymap`) defines:
   - Layer indices (GALLIUM, QWERTY, LOWER, RAISE, ADJUST)
   - Custom behaviors (home row mods, mo_tog, shift_caps)
   - Shared keymap layers using the wrapper macros

## Building Locally

```bash
# Setup
uvx west init -l config
uvx west update

# Build a specific shield
uvx --with pyelftools west build -p always -s zmk/app -b nice_nano_v2 \
  -- -DZMK_CONFIG=$(realpath config) -DSHIELD="sofle_left nice_oled"

# Build to a specific directory
uvx --with pyelftools west build -p always -s zmk/app -b nice_nano_v2 \
  -d build/corne_left \
  -- -DZMK_CONFIG=$(realpath config) -DSHIELD="corne_left nice_oled"
```

Output firmware is at `build/zephyr/zmk.uf2`.

## Layers

- **GALLIUM** (0) - Default alpha layer using Gallium layout
- **QWERTY** (1) - Standard QWERTY layout
- **LOWER** (2) - Symbols and numpad
- **RAISE** (3) - Function keys and navigation
- **ADJUST** (4) - Bluetooth, RGB, and media (activated by LOWER+RAISE)
