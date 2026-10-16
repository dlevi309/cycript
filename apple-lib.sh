#!/usr/bin/env bash

# Cycript - The Truly Universal Scripting Language
# Copyright (C) 2009-2016  Jay Freeman (saurik)

# GNU Affero General Public License, Version 3 {{{
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# }}}

set -e

extra=("$@")

archs=()
function arch() {
    local lib=$1
    shift

    local arch=$1
    local host=$2
    local sdk=$3
    local os=$4
    local min=$5
    shift 5

    rm -rvf "${lib}.${arch}"
    if ! isysroot=$(xcodebuild -sdk "${sdk}" -version Path); then
        return
    fi

    archs+=("${arch}")
    mkdir "${lib}.${arch}"

    flags=()
    flags+=(-isysroot "${isysroot}")
    flags+=(-m${os}-version-min="${min}")
    flags+=(-O3 -g3)

    if [[ ${arch} == armv* && ${arch} != armv6 ]]; then
        flags+=(-mthumb)
    fi

    src=$(cd "${lib}" && pwd)
    if [[ ! -x "${src}/configure" ]]; then
        # autoconf searches ../ and ../.. for helper scripts, so bootstrap away from our own copies
        src=$(mktemp -d)
        cp -R "${lib}/." "${src}"
        (cd "${src}" && ./autogen.sh)
    fi

    opts=()
    if [[ ${lib} == libffi ]]; then
        opts+=(--disable-docs)
    fi
    if [[ ${lib} == readline ]]; then
        # readline's ancient config.sub does not recognize arm64-apple-darwin, which is what config.guess says on Apple silicon
        opts+=(--build=x86_64-apple-darwin)
    fi

    cd "${lib}.${arch}"
    CC="clang -arch ${arch}" CXX="clang++ -arch ${arch}" LDFLAGS="${flags[*]}" CPPFLAGS="${flags[*]} $*" "${src}"/configure --host="${host}" --enable-static --disable-shared "${opts[@]}" \
        ac_cv_func_strcoll_works=yes bash_cv_func_sigsetjmp=present bash_cv_func_ctype_nonascii=no bash_cv_must_reinstall_sighandlers=no bash_cv_func_strcoll_broken=yes bash_cv_wcwidth_broken=no
    make -j5
    cd ..
}

function arch64() {
    local lib=$1
    shift

    arch "${lib}" arm64 aarch64-apple-darwin iphoneos iphoneos 11.0 "$@"
}

function arch64e() {
    local lib=$1
    shift

    arch "${lib}" arm64e aarch64-apple-darwin iphoneos iphoneos 11.0 "$@"
}

function archs() {
    local lib=$1
    shift

    arch64 "${lib}" "$@"
    arch64e "${lib}" "$@"
}

archs libffi -DPAGE_MAX_SIZE=16384 -DPAGE_MAX_SHIFT=14 -fno-stack-protector
archs libuv
archs readline -include sys/ioctl.h

for arch in $(printf '%s\n' "${archs[@]}" | sort -u); do
    ln -sf . "readline.${arch}/readline"
done
