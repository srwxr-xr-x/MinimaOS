.PHONY: all
all: minima.iso

.PHONY: dep
dep:
	sudo apt-get install nasm qemu-system-x86

.PHONY: info
info:
	@echo "make: 		Make ISO"
	@echo "make dep:	Make all required dependencies"
	@echo "make run: 	Boot off ISO in QEMU"
	@echo "make debug: 	Boot off ISO in QEMU with GDB hooked into it"
	@echo "make clean:	Clean all files"

.PHONY: all-hdd
all-hdd: minima.hdd

.PHONY: run
run: minima.iso
	qemu-system-x86_64 -M q35 -m 2G -cdrom minima.iso -boot d

.PHONY: debug
debug: minima.iso kernel
	qemu-system-x86_64 -s -S -M q35 -m 2G -cdrom minima.iso -boot d & gdb -ex "target remote localhost:1234" -ex "symbol-file kernel/minima.elf"

.PHONY: run-uefi
run-uefi: ovmf-x64 minima.iso
	qemu-system-x86_64 -M q35 -m 2G -bios ovmf-x64/OVMF.fd -cdrom minima.iso -boot d

.PHONY: run-hdd
run-hdd: minima.hdd
	qemu-system-x86_64 -M q35 -m 2G -hda minima.hdd

.PHONY: run-hdd-uefi
run-hdd-uefi: ovmf-x64 minima.hdd
	qemu-system-x86_64 -M q35 -m 2G -bios ovmf-x64/OVMF.fd -hda minima.hdd

ovmf-x64:
	mkdir -p ovmf-x64
	cd ovmf-x64 && curl -o OVMF-X64.zip https://efi.akeo.ie/OVMF/OVMF-X64.zip && 7z x OVMF-X64.zip

limine:
	git clone https://github.com/limine-bootloader/limine.git --branch=v4.x-branch-binary --depth=1
	make -C limine

.PHONY: kernel
kernel:
	$(MAKE) -C kernel

minima.iso: limine kernel
	rm -rf iso_root
	mkdir -p iso_root
	cp kernel/minima.elf \
		limine.cfg limine/limine.sys limine/limine-cd.bin limine/limine-cd-efi.bin iso_root/
	xorriso -as mkisofs -b limine-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot limine-cd-efi.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		iso_root -o minima.iso
	limine/limine-deploy minima.iso
	rm -rf iso_root

minima.hdd: limine kernel
	rm -f minima.hdd
	dd if=/dev/zero bs=1M count=0 seek=64 of=minima.hdd
	parted -s minima.hdd mklabel gpt
	parted -s minima.hdd mkpart ESP fat32 2048s 100%
	parted -s minima.hdd set 1 esp on
	limine/limine-deploy minima.hdd
	sudo losetup -Pf --show minima.hdd >loopback_dev
	sudo mkfs.fat -F 32 `cat loopback_dev`p1
	mkdir -p img_mount
	sudo mount `cat loopback_dev`p1 img_mount
	sudo mkdir -p img_mount/EFI/BOOT
	sudo cp -v kernel/minima.elf limine.cfg limine/limine.sys img_mount/
	sudo cp -v limine/BOOTX64.EFI img_mount/EFI/BOOT/
	sync
	sudo umount img_mount
	sudo losetup -d `cat loopback_dev`
	rm -rf loopback_dev img_mount

.PHONY: clean
clean:
	rm -rf iso_root minima.iso minima.hdd
	$(MAKE) -C kernel clean

.PHONY: distclean
distclean: clean
	rm -rf limine ovmf-x64
	$(MAKE) -C kernel distclean
