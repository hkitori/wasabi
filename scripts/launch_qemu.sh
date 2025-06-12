#!/bin/bash -e
# -e: スクリプト実行中にエラーが発生したら即座に終了する

# このスクリプトの一つ上のディレクトリを取得し、さらにその親ディレクトリをプロジェクトルートとする
# ${BASH_SOURCE:-$0} はスクリプト自身のパスを指す
# dirname を二重に呼ぶことで「scripts/launch_qemu.sh」→「scripts」→「プロジェクトルート」の順に辿る
PROJ_ROOT="$(dirname $(dirname ${BASH_SOURCE:-$0}))"
cd "${PROJ_ROOT}"

# スクリプトの第1引数を「PATH_TO_EFI」に格納（ビルドしたEFIバイナリのパスを想定）
PATH_TO_EFI="$1"

# ビルドしたEFIブートローダを配置する場所を用意
rm -rf mnt
mkdir -p mnt/EFI/BOOT/

# 指定されたEFIバイナリを「mnt/EFI/BOOT/BOOTX64.EFI」としてコピー
# QEMU起動時にこのEFIファイルがブートローダとして使用される
cp ${PATH_TO_EFI} mnt/EFI/BOOT/BOOTX64.EFI

mkdir -p log

# ゲストに割り当てるメモリサイズを1GBに指定
# OVMF（UEFI対応ファームウェア）をBIOSとして使用する
# third_party/ovmf/RELEASEX64_OVMF.fd がUEFI環境を提供
# 「mnt」ディレクトリをRAW形式のFATイメージとしてマウントし、読み書き可能（rw）に設定
# これにより「mnt/EFI/BOOT/BOOTX64.EFI」がQEMUゲストから認識される
# isa-debug-exit デバイスを追加。UEFIアプリケーションが特定のI/Oポート（0xF4）に書き込むとQEMUが終了する仕組み
# ユニットテストやUEFIアプリからの正常終了シグナルに便利
set +e
qemu-system-x86_64 \
    -m 1G \
    -bios third_party/ovmf/RELEASEX64_OVMF.fd \
    -drive format=raw,file=fat:rw:mnt \
    -chardev stdio,id=char_com1,mux=on,logfile=log/com1.txt \
    -serial chardev:char_com1 \
    -device isa-debug-exit,iobase=0xf4,iosize=0x01
RETCODE=$?
set -e
if [ $RETCODE -eq 0 ]; then
    exit 0
elif [ $RETCODE -eq 3 ]; then
    printf "\nPASS\n"
    exit 0
else
    priintf "\nFAIL: QEMU returned $RETCODE\n"
    exit 1
fi
