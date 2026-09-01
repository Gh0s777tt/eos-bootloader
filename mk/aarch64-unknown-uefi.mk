# E-OS: aarch64 builds WITHOUT LTO, and this is a boot requirement, not a preference.
#
# Cargo.toml sets `lto = true` + `codegen-units = 1` for the whole workspace because the BIOS
# stage3 is padded to a hard 384 KiB and Ed25519 overflows it without LTO (87b214b5). That reason
# is real and unchanged -- but the profile is global, and on aarch64 LTO is what breaks the boot.
#
# LTO merges callee frames into their caller, so locals that were live one at a time become live
# at once. Measured on this tree, aarch64-unknown-uefi:
#
#   lto=true    12 probed __chkstk frames, 229808 B total, including a 36704 B frame that exists
#               in NO non-LTO build; three smaller frames (11552 + 12480 + 5040) vanish
#   lto=false   15 probed frames, 235456 B total -- MORE in total, and it boots
#
# The total is not what matters; the peak on one call path is. QEMU virt's firmware DXE stack is
# ~124 KiB usable, and with LTO the kernel-load path needs ~128 KiB, dying in the __chkstk probe
# before ExitBootServices (ESR 0x9600000B, access-flag fault, level 3).
#
# Proven end to end with a matched control -- same revision, same verify-boot feature, same key,
# only this setting differing:
#
#   lto=true    boot-smoke FAIL at 2048 AND 6144 MiB, identical ESR, fault at helper+0x10
#   lto=false   boot-smoke PASS at 2048 AND 6144 MiB -- reached userspace login
#
# Set here rather than in Cargo.toml so x86-unknown-none, x86_64-unknown-uefi and riscv64 keep
# exactly what they have today; this file is the only one that changes. RUSTFLAGS cannot carry
# it -- `-C lto` there collides with the `-C embed-bitcode=no` cargo gives build-std deps.
#
# This restores the margin, it does NOT create headroom. See E-OS issue #15.
export PARTED?=parted
export QEMU?=qemu-system-aarch64

all: $(BUILD)/bootloader.efi

$(BUILD)/bootloader.efi: $(SOURCE)/Cargo.toml $(SOURCE)/Cargo.lock $(shell find $(SOURCE)/src -type f)
	mkdir -p "$(BUILD)"
	env CARGO_PROFILE_RELEASE_LTO=false CARGO_PROFILE_RELEASE_CODEGEN_UNITS=16 \
	    RUSTFLAGS="--cfg aes_force_soft --cfg curve25519_dalek_backend=\"serial\" -Zunstable-options" \
	cargo rustc \
		--manifest-path="$<" \
		$(CARGO_ARGS) \
		--bin bootloader \
		-- \
		--emit link="$@"

$(BUILD)/bootloader-live.efi: $(SOURCE)/Cargo.toml $(SOURCE)/Cargo.lock $(shell find $(SOURCE)/src -type f)
	mkdir -p "$(BUILD)"
	env CARGO_PROFILE_RELEASE_LTO=false CARGO_PROFILE_RELEASE_CODEGEN_UNITS=16 \
	    RUSTFLAGS="--cfg aes_force_soft --cfg curve25519_dalek_backend=\"serial\" -Zunstable-options" \
	cargo rustc \
		--manifest-path="$<" \
		$(CARGO_ARGS) \
		--bin bootloader \
		--features live \
		-- \
		--emit link="$@"

$(BUILD)/esp.bin: $(BUILD)/bootloader.efi
	rm -f "$@.partial"
	fallocate -l 64MiB "$@.partial"
	mkfs.vfat -F 32 "$@.partial"
	mmd -i "$@.partial" efi
	mmd -i "$@.partial" efi/boot
	mcopy -i "$@.partial" "$<" ::efi/boot/bootaa64.efi
	mv "$@.partial" "$@"

$(BUILD)/harddrive.bin: $(BUILD)/esp.bin $(BUILD)/filesystem.bin
	rm -f "$@.partial"
	fallocate -l 320MiB "$@.partial"
	$(PARTED) -s -a minimal "$@.partial" mklabel gpt
	$(PARTED) -s -a minimal "$@.partial" mkpart ESP FAT32 1MiB 65MiB
	$(PARTED) -s -a minimal "$@.partial" mkpart REDOXFS 65MiB 100%
	$(PARTED) -s -a minimal "$@.partial" toggle 1 boot
	dd if="$(BUILD)/esp.bin" of="$@.partial" bs=1MiB seek=1 conv=notrunc
	dd if="$(BUILD)/filesystem.bin" of="$@.partial" bs=1MiB seek=65 conv=notrunc
	mv "$@.partial" "$@"

$(BUILD)/firmware.rom: /usr/share/AAVMF/AAVMF_CODE.fd
	cp "$<" "$@"

qemu: $(BUILD)/harddrive.bin $(BUILD)/firmware.rom
	$(QEMU) \
		-d cpu_reset \
		-no-reboot \
		-smp 4 -m 2048 \
		-chardev stdio,id=debug,signal=off,mux=on \
		-serial chardev:debug \
		-mon chardev=debug \
		-device virtio-gpu-pci \
		-machine virt \
		-net none \
		-cpu max \
		-bios "$(BUILD)/firmware.rom" \
		-drive file="$<",format=raw
