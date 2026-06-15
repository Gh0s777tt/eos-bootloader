<a name="top"></a>
<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:E50914,100:0B0B0B&height=200&section=header&text=eos-bootloader&fontSize=50&fontColor=ffffff&fontAlignY=38&desc=Red%20%26%20black%20bootloader%20for%20E-OS&descAlignY=60&descSize=18&animation=fadeIn" alt="eos-bootloader"/>
</p>

<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=19&pause=900&color=E50914&center=true&vCenter=true&width=800&lines=The+red%2Fblack+bootloader+for+E-OS;Downstream+of+redox-os%2Fbootloader;Branding+%2B+boot+for+E-OS" alt="tagline"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-E50914?style=for-the-badge&labelColor=0B0B0B" alt="license"/>
  <img src="https://img.shields.io/badge/Rust-E50914?style=for-the-badge&logo=rust&logoColor=white&labelColor=0B0B0B" alt="Rust"/>
  <img src="https://img.shields.io/badge/part%20of-E--OS-E50914?style=for-the-badge&labelColor=0B0B0B" alt="part of E-OS"/>
</p>

<p align="center"><img src="https://raw.githubusercontent.com/Gh0s777tt/Gh0s777tt/main/assets/divider.svg" width="100%" alt=""/></p>

## Requirements

These software needs to be available on the PATH at build time:

+ [mtools](https://www.gnu.org/software/mtools/)
+ [nasm](https://nasm.us/)
+ [redoxfs-ar](https://gitlab.redox-os.org/redox-os/redoxfs)

## Building

```sh
make TARGET=<triplet> BUILD=build all
```

The `<triplet>` is one of:

| ARCH | Boot Mode | Triplets |
|---|---|---|
| `i686` | BIOS | `x86-unknown-none` |
| `x86_64` | BIOS | `x86-unknown-none` |
| `x86_64` | UEFI | `x86_64-unknown-uefi` |
| `aarch64` | UEFI | `aarch64-unknown-uefi` |
| `riscv64gc` | UEFI | `riscv64gc-unknown-uefi` |

See [mk directory](./mk) for more information of how the build is working.

## Entry points

Please read [Boot Process](https://doc.redox-os.org/book/boot-process.html) in the Redox OS Book for an introductory guide.

In this source code, some interesting files for entry points are:

+ BIOS boot stages: [asm/x86-unknown-none/bootloader.asm](./asm/x86-unknown-none/bootloader.asm)
+ BIOS boot entry: `fn start` at [src/os/bios/mod.rs](./src/os/bios/mod.rs)
+ UEFI boot entry: `fn main` at [src/os/uefi/mod.rs](src/os/uefi/mod.rs)
+ Common boot process: `fn main` at [src/main.rs](src/main.rs)
+ UEFI kernel entry: `fn kernel_entry` in each arch:
  - `x86_64`: [src/os/uefi/arch/x86_64.rs](src/os/uefi/arch/x86_64.rs)
  - `aarch64`: [src/os/uefi/arch/aarch64.rs](src/os/uefi/arch/aarch64.rs)
  - `riscv64gc`: [src/os/uefi/arch/riscv64/mod.rs](src/os/uefi/arch/riscv64/mod.rs)

## Debugging

### QEMU

```sh
make TARGET=<triplet> BUILD=build qemu
```

## How To Contribute

To learn how to contribute to this system component you need to read the following document:

- [CONTRIBUTING.md](https://gitlab.redox-os.org/redox-os/redox/-/blob/master/CONTRIBUTING.md)

## Development

To learn how to do development with this system component inside the Redox build system you need to read the [Build System](https://doc.redox-os.org/book/build-system-reference.html) and [Coding and Building](https://doc.redox-os.org/book/coding-and-building.html) pages.

<p align="center"><img src="https://raw.githubusercontent.com/Gh0s777tt/Gh0s777tt/main/assets/divider.svg" width="100%" alt=""/></p>

<div align="center">

### 🩸 Part of the **GHOST EMPIRE** ecosystem

[**E-OS**](https://github.com/Gh0s777tt/E-OS) · Rust microkernel OS &nbsp;·&nbsp; Minecraft infrastructure suite &nbsp;·&nbsp; Discord &amp; streaming platforms — forged under **Empire Forge**.

<a href="https://discord.gg/Egf88V9UdH"><img src="https://img.shields.io/badge/Discord-Join%20the%20Empire-5865F2?style=for-the-badge&logo=discord&logoColor=white&labelColor=0B0B0B" alt="discord"/></a>
<a href="mailto:ghostt77@empire-forge.com"><img src="https://img.shields.io/badge/Email-Empire%20Forge-E50914?style=for-the-badge&logo=maildotru&logoColor=white&labelColor=0B0B0B" alt="email"/></a>
<a href="https://donatr.ee/ghost77/"><img src="https://img.shields.io/badge/%E2%9D%A4%20Support-Donate-E50914?style=for-the-badge&labelColor=0B0B0B" alt="donate"/></a>

<sub><i>Black. Red. Production-grade. — © GHOST EMPIRE · Empire Forge</i></sub>

</div>
