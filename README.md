# eos-bootloader

**E-OS fork of [`redox-os/bootloader`](https://gitlab.redox-os.org/redox-os/bootloader).** Part of the [**E-OS**](https://github.com/Gh0s777tt/E-OS) ecosystem — a hardened, Crimson-branded downstream of [Redox OS](https://www.redox-os.org).

This repository is the **Redox UEFI/BIOS bootloader**.

## E-OS changes vs upstream

- E-OS **red/black (Crimson)** theme + `E-OS Bootloader` banner.

## How it's pinned

The E-OS build pins this fork in [`recipes/core/bootloader/recipe.toml`](https://github.com/Gh0s777tt/E-OS/blob/main/recipes/core/bootloader/recipe.toml):

- branch **`eos-rebased`** · rev **`f1ba665799a0`**
- up to date with upstream

## Build standalone

This fork is normally built by the E-OS cookbook (`make CI=1 …` in the [main repo](https://github.com/Gh0s777tt/E-OS)). To build it on its own you need the Redox toolchain; see the main repo's [build guide](https://github.com/Gh0s777tt/E-OS/blob/main/docs/building.md).

## Hosting

**GitLab (source of truth):** https://gitlab.com/e-os/eos-bootloader  
**GitHub (read-only mirror):** https://github.com/Gh0s777tt/eos-bootloader

## License

MIT (inherited from upstream Redox). The E-OS project as a whole is AGPL-3.0; see the [main repo](https://github.com/Gh0s777tt/E-OS/blob/main/LICENSE).

---
[E-OS main repo](https://github.com/Gh0s777tt/E-OS) · [Docs](https://github.com/Gh0s777tt/E-OS/tree/main/docs) · [Upstream](https://gitlab.redox-os.org/redox-os/bootloader)
