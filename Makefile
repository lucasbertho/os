cross-compiler=/opt/cross/bin

gcc-32=${cross-compiler}/i686-elf-gcc
ld-32=${cross-compiler}/i686-elf-ld

gcc-64=${cross-compiler}/x86_64-elf-gcc
ld-64=${cross-compiler}/x86_64-elf-ld

kernel_entry_point_addr=0x9800

virtual_machine_memory_mb=256
virtual_machine_args-32=-m ${virtual_machine_memory_mb} -monitor stdio -fda build/kernel_32.hdd # -drive file=build/kernel_32.hdd,index=0,media=disk,format=raw
virtual_machine_args-64=-m ${virtual_machine_memory_mb} -monitor stdio -fda build/kernel_64.hdd # -drive file=build/kernel_64.hdd,index=0,media=disk,format=raw

boot=build/boot.bin build/gdt.bin build/pmode.bin build/lmode.bin build/idt.bin

boot: ${boot}

build-32: boot build/pmode_kernel_entry.o build/pmode_kernel.bin build/kernel_32.hdd
build-64: boot build/lmode_kernel_entry.o build/lkernel.bin build/kernel_64.hdd
build-64-asm: boot build/lkernel_asm.bin build/kernel_64_asm.hdd

build/boot.bin: src/boot/boot.asm
	nasm src/boot/boot.asm -f bin -o $@

build/gdt.bin: src/boot/gdt.asm
	nasm src/boot/gdt.asm -f bin -o $@

build/pmode.bin: src/pmode/pmode.asm
	nasm src/pmode/pmode.asm -f bin -o $@

build/idt.bin: src/lmode/lmode_idt.asm
	nasm src/lmode/lmode_idt.asm -f bin -o $@

build/lmode.bin: src/lmode/lmode.asm
	nasm src/lmode/lmode.asm -f bin -o $@

build/lkernel_asm.bin: src/lmode/lkernel/lkernel.asm
	nasm src/lmode/lkernel/lkernel.asm -f bin -o $@

build/pmode_kernel_entry.o: src/pmode/pmode_kernel_entry.asm
	nasm src/pmode/pmode_kernel_entry.asm -f elf -o $@

build/lmode_kernel_entry.o: src/lmode/lmode_kernel_entry.asm
	nasm src/lmode/lmode_kernel_entry.asm -f elf64 -o $@

build/pmode_kernel.bin: src/pmode/pmode_kernel.c build/pmode_kernel_entry.o
	${gcc-32} -ffreestanding -c src/pmode/pmode_kernel.c -o build/kernel.o
	${ld-32} -o build/pmode_kernel.bin -Ttext ${kernel_entry_point_addr} build/pmode_kernel_entry.o build/kernel.o --oformat binary

build/lkernel.bin: src/lmode/lkernel/lkernel.c build/lmode_kernel_entry.o
	${gcc-64} -ffreestanding -mno-red-zone -m64 -Ttext ${kernel_entry_point_addr} -c src/lmode/lkernel/lkernel.c -o build/kernel.o
	${ld-64} -T"src/lmode/linker.ld"

build/kernel_32.hdd: boot build/pmode_kernel.bin
	cat ${boot} build/pmode_kernel.bin > $@
	ndisasm -b 32 build/kernel_32.hdd > build/kernel_32.dis

build/kernel_64.hdd: ${boot} build/lkernel.bin
	cat ${boot} build/lkernel.bin > $@
	ndisasm -b 64 build/kernel_64.hdd > build/kernel_64.dis

build/kernel_64_asm.hdd: boot build/lkernel_asm.bin
	cat ${boot} build/lkernel_asm.bin > build/kernel_64.hdd
	ndisasm -b 64 build/kernel_64.hdd > build/kernel_64.dis

clean:
	rm -f build/*.bin build/*.o build/*.flp build/*.hdd build/*.dis

run-32:
	qemu-system-i386 ${virtual_machine_args-32}

run-64:
	qemu-system-x86_64 ${virtual_machine_args-64}

debug-32:
	xfce4-terminal -e "qemu-system-i386 ${virtual_machine_args-32} -s -S"
	xfce4-terminal -e "${cross-compiler}/i686-elf-gdb -q --command=util/debug_bootsector.gdb"

debug-64:
	xfce4-terminal -e "qemu-system-x86_64 ${virtual_machine_args-64} -s -S"
	xfce4-terminal -e "${cross-compiler}/x86_64-elf-gdb -q --command=util/debug_bootsector.gdb"

burn-iso-64:
	dd if=build/kernel_64.hdd of=/dev/sdb