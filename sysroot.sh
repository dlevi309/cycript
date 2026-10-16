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

rm -rf sysroot.ios
mkdir -p sysroot.ios/usr/include

# the iOS SDK lacks the headers for the ncurses (terminfo) library that iOS ships
mac=$(xcrun --sdk macosx --show-sdk-path)
for h in curses.h ncurses_dll.h term.h termcap.h unctrl.h; do
    cp -a "${mac}/usr/include/${h}" sysroot.ios/usr/include
done

for h in jni.h jni_md.h; do
    ln -s /System/Library/Frameworks/JavaVM.framework/Versions/A/Headers/"${h}" sysroot.ios/usr/include
done
