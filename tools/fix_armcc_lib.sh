#!/usr/bin/env bash
# Rewrite a static library built by ARM Compiler 5 so GNU ld accepts it.
# ArmCC puts a local symbol behind the global ones in .symtab, which
# binutils >= 2.40 rejects ("local symbol at index ... >= sh_info").
# objcopy writes the symbol table in the order the ELF spec requires.
# usage: fix_armcc_lib.sh <in.lib> <out.a>
set -euo pipefail
in=$(realpath "$1"); out=$(realpath -m "$2")
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
arm-none-eabi-ar x "$in"
# keep the member order of the original archive
mapfile -t members < <(arm-none-eabi-ar t "$in")
for m in "${members[@]}"; do
    arm-none-eabi-objcopy "$m" "$m.fixed"
    mv "$m.fixed" "$m"
done
rm -f "$out"
arm-none-eabi-ar rcs "$out" "${members[@]}"
