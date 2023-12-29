# Proof-of-concept of bootable Operating System terminal with keyboard interaction using Assembly x86-64 and QEMU.

This is a proof-of-concept project created for learning purposes to better understand how the OS (Operating System) sets the CPU to protected mode (32 bits) and then long mode (64 bits) by providing a bootable image where the user can type characters and see them on the screen.

The assembly language has been used, but the user has the option to switch to the C language if desired.

## Build instructions:
1. Create a GCC cross-compiler with a generic target (i686-elf). The compiler creation instructions can be found at the OSDev.org website: https://osdev.org/GCC_Cross-Compiler
2. Update the Makefile variable `"cross-compiler"` to the path created at step #1.
3. Build the OS with the following command:
```
make clean && make build-64-asm -B
```

## Run from QEMU virtual machine:
1. Run the following command:
```
make run-64
```
2. A QEMU window with a terminal should pop up where the user can type characters and see them on the screen.
3. Hit Ctrl+Alt+G to release the grab and close the QEMU window.

## Run from real hardware:
1. burn the iso to an USB stick (MAKE SURE TO BACKUP YOUR DEVICE DATA FIRST OR DATA WILL BE LOST):
```
dd if=build/kernel_64.hdd of=(path to your device)
```
2. Boot the computer with the USB stick.
3. Please note that there is no built-in functionality to power off the machine, so the power button must be used to shut the machine down. Make sure that, after the machine has been shut down, the USB stick is removed.

## Credits:

The website OSDev.org as well as Poncho's YouTube channel have been used as a reference. The link to their pages can be found below:

OSDev.org
https://osdev.org/Main_Page

Poncho's YouTube channel:
https://www.youtube.com/watch?v=7LTB4aLI7r0&list=PLxN4E629pPnKKqYsNVXpmCza8l0Jb6l8-
