# rF2RippleMapDescriptorEditor

A ripple map (raindrop movement direction) descriptor editor for creating and editing `raindrop_desc.json` file for used in `rF2` vehicle mod.

This tool simplifies `raindrop_desc.json` file creation process without the need for manual editing JSON file or memorizing complex direction code. Up to `16` customizable ripple control sets are supported by default. Raindrop movement can be quickly adjusted by selecting direction symbols from direction drop-down lists.

For additional info regarding `Ripple Map` creation and specification, see [rF2 developers guide](https://docs.studio-397.com/developers-guide/car-development/car-art/rain-effects-and-windscreen-shaders-for-cars).


## Usage

### Load & Save
- Click `Open` to select and load `raindrop_desc.json` file from `rF2` vehicle mod.
- Click `Export as JSON` to generate and save all changes to `raindrop_desc.json` file.
- Click `Copy to Clipboard` to generate and copy all code to Clipboard, which then can be manually pasted into existing file.

### Ripple Configuration
- Set toggle:
    - Allow `enable` or `disable` ripple control sets. Disabled sets will not be exported to file. Note, up to `16` control sets are tested and supported by default. Additional sets may be enabled by increasing `MAX_RIPPLE_SET` value in source code of this tool.
- Color spinbox:
    - Adjustable color spinboxes in `Red`, `Green`, `Blue` order. Each color value range in `0` to `255`. Changes are immediately updated in color preview box.
- Still direction (first drop-down list):
    - Set raindrop movement direction while vehicle is stationary. Note, the drop-down list supports `8` movement directions plus `1` still (no movement). Directions should be set relative to vehicle's body UV map (skin livery paint). See `direction reference` section for details.
- Movement direction (second drop-down list):
    - Set raindrop movement direction while vehicle is moving.
- Description:
    - Add description info to each set in JSON file.


## Direction reference
|X      |Y      |Description  |
|-------|-------|-------------|
|-1.0   |-1.0   |↖ Left Up    |
|+0.0   |-1.0   |↑ Up         |
|+1.0   |-1.0   |↗ Right Up   |
|-1.0   |+0.0   |← Left       |
|+0.0   |+0.0   |● Still      |
|+1.0   |+0.0   |→ Right      |
|-1.0   |+1.0   |↙ Left Down  |
|+0.0   |+1.0   |↓ Down       |
|+1.0   |+1.0   |↘ Right Down |

Note, values from `X` and `Y` columns represent raindrop movement direction code defined in `raindrop_desc.json` file.


## Requirements
This tool is written in [Autohotkey](https://www.autohotkey.com) scripting language, source script requires `Autohotkey v2` to run.


## License
rF2RippleMapDescriptorEditor is licensed under the [MIT License](./LICENSE.txt).
