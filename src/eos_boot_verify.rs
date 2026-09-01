// E-OS V2-MS02: verify what the bootloader loads, instead of trusting magic bytes.
//
// Before this module, `load_to_memory` checked four bytes (`\x7FELF`) for the kernel and eight
// (`RedoxFtw`) for the initfs, then handed `e_entry` -- read straight out of that same file --
// to the CPU. Anyone who could write the root filesystem could therefore choose the first
// instruction executed on the machine. That was demonstrated, not theorised: mounting a stock
// `harddrive.img` with the project's own `redoxfs` tool, replacing `usr/lib/boot/kernel` and
// remounting produced a file whose hash had changed and which nothing objected to. RedoxFS
// hashes blocks with seahash, which is neither cryptographic nor keyed, so the filesystem
// re-hashes tampered data for the attacker.
//
// TRUST ANCHOR. The public key is compiled INTO the bootloader, because the bootloader is the
// one artefact the firmware itself authenticates (Secure Boot, V2-N03). A key sitting next to
// the kernel on disk would be swapped along with it.
//
// CONSTRUCTION. Ed25519 over SHA-512(role || len_le || data). The role tag is not decoration:
// without it a validly signed initfs would verify as a kernel. The length binds the size so a
// prefix of a signed object cannot be presented as the whole. Hashing streams over the buffer,
// so a 21 MiB initfs is never copied.
//
// FAIL CLOSED, DELIBERATELY. A missing signature, a wrong size, an unconfigured key and a bad
// signature all panic. There is no "continue anyway" branch, and no feature flag that removes
// the check -- a bootloader that could be told to skip verification would still be signed with
// the operator's Secure Boot key, i.e. a firmware-trusted tool for booting anything.

use ed25519_dalek::{Signature, Verifier, VerifyingKey};
use sha2::{Digest, Sha512};

/// Ed25519 public key of the E-OS boot-signing key, injected at build time.
///
/// `#[used]` + `#[unsafe(no_mangle)]` are load-bearing, not style: without them LLVM folds the
/// constant into the verifying code and the 32 bytes are physically absent from the binary,
/// which both hides the anchor and makes "prove the key is in the image" impossible to run.
#[used]
#[unsafe(no_mangle)]
pub static EOS_BOOT_VERIFY_PUB: [u8; 32] = *include_bytes!("eos-boot-verify.pub.bin");

/// Domain-separation tag. Distinct per role, fixed length, NUL-padded.
pub const ROLE_KERNEL: &[u8; 16] = b"e-os.boot.kernel";
pub const ROLE_INITFS: &[u8; 16] = b"e-os.boot.initfs";

/// Detached signature length. Anything else is a malformed signature file, not a short read.
pub const SIG_LEN: usize = 64;

/// Panics unless `sig` is a valid signature by the embedded key over this exact object.
///
/// `what` names the object in the panic message so a failure at 3 a.m. on real hardware says
/// which file was rejected rather than just "verification failed".
pub fn verify_or_panic(what: &str, role: &[u8; 16], data: &[u8], sig: &[u8]) {
    if EOS_BOOT_VERIFY_PUB == [0u8; 32] {
        panic!(
            "{}: this bootloader was built without a boot-verification key. \
             Refusing to boot unverified code. Place the key and rebuild (V2-MS02).",
            what
        );
    }

    if sig.len() != SIG_LEN {
        panic!(
            "{}: signature is {} bytes, expected {}",
            what,
            sig.len(),
            SIG_LEN
        );
    }

    let key = match VerifyingKey::from_bytes(&EOS_BOOT_VERIFY_PUB) {
        Ok(key) => key,
        Err(err) => panic!(
            "{}: embedded boot-verification key is not a valid Ed25519 key: {err}",
            what
        ),
    };

    let mut hasher = Sha512::new();
    hasher.update(role);
    hasher.update(&(data.len() as u64).to_le_bytes());
    hasher.update(data);
    let digest = hasher.finalize();

    let mut sig_bytes = [0u8; SIG_LEN];
    sig_bytes.copy_from_slice(sig);

    match key.verify(&digest, &Signature::from_bytes(&sig_bytes)) {
        Ok(()) => println!("{}: signature OK", what),
        Err(_) => panic!(
            "{}: SIGNATURE VERIFICATION FAILED -- this image has been modified, \
             or was signed with a different key. Refusing to boot.",
            what
        ),
    }
}
