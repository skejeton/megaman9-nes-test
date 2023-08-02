# Megaman 9 NES port test

An attempt to port Megaman 9 engine for NES.

## Building process

The game is currently designed to be built under a Linux-like environment. 
For Windows users, I recommend to [install WSL](https://learn.microsoft.com/en-us/windows/wsl/install).

### Prerequisites

Before compiling this project, make sure you have two following programs installed: 

*   `ca65` - 6502 assembler program
*   `ld65` - 6502 linker program

If you use Ubuntu or WSL, the command for installing is:

```sh
sudo apt install cc65
```

### Building

Run this command in the root directory of the project:

```
./build.sh
```

Outputs: 
* `output/megaman9.o` - object file
* `output/megaman9.nes` - executable NES ROM

### Running

For running the project any valid NES emulator is suitable.
Recommended emulators are Mesen and FCEUX.

Open the NES file located at `output/megaman9.nes` with your emulator.

## Editing

Please follow the `.editorconfig` specification for formatting - it's usually best to set up your editor to handle it for you.
