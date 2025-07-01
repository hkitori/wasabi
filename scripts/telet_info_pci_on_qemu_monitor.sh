#!/bin/sh
set -x

{
  # info pci を実行
  printf 'info pci\n'
  # モニターからの応答を受け取るまで少し待機（必要に応じて調整）
  sleep 0.2
  # QEMU を終了
  printf 'quit\n'
} | telnet localhost 2345

