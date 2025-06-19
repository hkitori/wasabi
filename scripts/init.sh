#!/bin/sh

# ---------------------------------------------------------
#  init
# ---------------------------------------------------------
if [ ! -f third_party/ovmf/RELEASEX64_OVMF.fd ]; then
    mkdir -p third_party/ovmf
    cd third_party/ovmf
    wget https://github.com/hikalium/wasabi/raw/main/third_party/ovmf/RELEASEX64_OVMF.fd
    cd -
fi

if [ ! -f src/font.txt ]; then
    curl https://raw.githubusercontent.com/hikalium/wasabi/main/font/font.txt > src/font.txt
fi

if [ ! -d mnt/EFI/BOOT ]; then
    mkdir -p mnt/EFI/BOOT
fi

rustup target add x86_64-unknown-uefi

# And also you need the following setting for rust-analyzer.
# See also: https://lowlayergirls.github.io/wasabi-help/os1/
#
# > cat ~/.vim/coc-settings.json
# {
#    "launguageserver": {
#      "rust": {
#        "command": "rust-analyzer",
#        "filetypes": ["rust"],
#        "rootPatterns": ["Cargo.toml"]
#      }
#    }
#    "rust-analyzer.server.path": "~/.rustup/toolchains/nightly-2024-01-01-x86_64-unknown-linux-gnu/bin/rust-analyzer"
# }
# >


# install cargo-objdump
cargo install cargo-binutils --locked

# ---------------------------------------------------------
#  build
# ---------------------------------------------------------
cargo build --target x86_64-unknown-uefi
ret=$?
#cargo run --target x86_64-unknown-uefi

if [ $ret -ne 0 ]; then
    echo "-------------------------------------"
    echo "Error: cargo build failed..."
    exit 1
fi

# ---------------------------------------------------------
#  run
# ---------------------------------------------------------
cp target/x86_64-unknown-uefi/debug/wasabi.efi mnt/EFI/BOOT/BOOTX64.EFI
qemu-system-x86_64 -bios third_party/ovmf/RELEASEX64_OVMF.fd -drive format=raw,file=fat:rw:mnt



