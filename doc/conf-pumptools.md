# Configure pumptools hooks
To easily apply various configuration settings to multiple games, the command
`conf-pumptools` allows you to specify a configuration file. This file specifies
one game per line and which key-value tuples to set/override in the `hook.conf`
file of each game. Entries in a single line are separated by a semicolon (";").

## Structure per line
```
<game>;<key-value tuple for hook.conf>;<key-value tuple for hook.conf>;...
```

## Simple example
```
01_1st;game.1st_2nd_fs=1;patch.gfx.windowed=1
```

This will set the value `1` for the key `1st_2nd_fs` and the value `1` for the
key `patch.gfx.windowed` in the `hook.conf` file of the game `01_1st`.

## Example multiple games
```
01_1st;game.1st_2nd_fs=1;patch.gfx.windowed=1;patch.piuio.emu_lib=./ptapi-io-piuio-keyboard.so;patch_hook_main_loop.x11_input_handler=./ptapi-io-piuio-keyboard.so
02_2nd;game.1st_2nd_fs=1;patch.gfx.windowed=1;patch.piuio.emu_lib=./ptapi-io-piuio-keyboard.so;patch_hook_main_loop.x11_input_handler=./ptapi-io-piuio-keyboard.so
03_obg;patch.gfx.windowed=1;patch.piuio.emu_lib=./ptapi-io-piuio-keyboard.so;patch_hook_main_loop.x11_input_handler=./ptapi-io-piuio-keyboard.so
```
