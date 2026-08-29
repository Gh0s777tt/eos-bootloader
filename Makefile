TARGET?=x86_64-unknown-uefi
SOURCE:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD:=$(CURDIR)
export RUST_TARGET_PATH?=$(SOURCE)/targets
# E-OS V2-MS02: the recipe sets EOS_BOOT_FEATURES=verify-boot when the operator's boot key is
# present, so kernel/initfs signature verification is compiled in. Empty otherwise, which keeps
# a keyless build bootable -- the same graceful-degrade shape V2-N03 uses for Secure Boot.
# Put here rather than in each mk/*.mk rule so all four targets and both live/non-live variants
# pick it up from one place.
EOS_BOOT_FEATURES?=
CARGO_ARGS=--release --locked --target $(TARGET) \
			-Z build-std=core,alloc \
			-Z build-std-features=compiler-builtins-mem \
			$(if $(EOS_BOOT_FEATURES),--features $(EOS_BOOT_FEATURES))

include $(SOURCE)/mk/$(TARGET).mk

clean:
	rm -rf build target

$(BUILD)/filesystem:
	mkdir -p $(BUILD)
	rm -f $@.partial
	mkdir $@.partial
	fallocate -l 1MiB $@.partial/kernel
	mv $@.partial $@

$(BUILD)/filesystem.bin: $(BUILD)/filesystem
	mkdir -p $(BUILD)
	rm -f $@.partial
	fallocate -l 254MiB $@.partial
	redoxfs-ar $@.partial $<
	mv $@.partial $@
