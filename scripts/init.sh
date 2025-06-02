#!/bin/sh


if [ ! -f third_party/ovmf/RELEASEX64_OVMF.fd ]; then
    mkdir -p third_party/ovmf
    cd third_party/ovmf
    wget https://github.com/hikalium/wasabi/raw/main/third_party/ovmf/RELEASEX64_OVMF.fd
    cd -
fi

if [ ! -d mnt/EFI/BOOT ]; then
    mkdir -p mnt/EFI/BOOT
fi

rustup target add x86_64-unknown-uefi
cargo build --target x86_64-unknown-uefi
ret=$?
#cargo run --target x86_64-unknown-uefi

if [ $ret -ne 0 ]; then
    echo "-------------------------------------"
    echo "Error: cargo build failed..."
    exit 1
fi
cp target/x86_64-unknown-uefi/debug/wasabi.efi mnt/EFI/BOOT/BOOTX64.EFI
qemu-system-x86_64 -bios third_party/ovmf/RELEASEX64_OVMF.fd -drive format=raw,file=fat:rw:mnt


