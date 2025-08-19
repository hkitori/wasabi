#!/bin/bash

if [[ -n $1 ]]; then
    rip="$1"
else
    echo
    echo "Error: specify RIP as decimal like 0x... with parameter#1"
    echo
    exit 1
fi

if [[ -n $2 ]]; then
    image_base="$2"
else
    echo
    echo "Error: specify image_base as decimal like 0x... with parameter#2"
    echo
    exit 2
fi

image_base_in_objdump="0x`cargo-objdump -- --all-headers 2>/dev/null | awk '/^ImageBase/{print $2}'`"

rip_in_objdump=`printf "%X\n" $(( $image_base_in_objdump + $rip - $image_base ))`

# debug
#echo
#echo $image_base_in_objdump
#echo $rip
#echo $image_base
#echo
# debug

echo
echo "rip_in_objdump = 0x$rip_in_objdump"
echo

set -x
cargo-objdump -- -d | grep --color -10 -i ${rip_in_objdump}

