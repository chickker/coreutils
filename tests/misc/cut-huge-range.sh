#!/bin/sh
# Ensure that cut does not allocate mem for large ranges

# Copyright (C) 2012-2013 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

. "${srcdir=.}/tests/init.sh"; path_prepend_ ./src
print_ver_ cut
require_ulimit_v_
getlimits_

# Ensure we can cut up to our sentinel value.
# This is currently SIZE_MAX, but could be raised to UINTMAX_MAX
# if we didn't allocate memory for each line as a unit.
CUT_MAX=$(expr $SIZE_MAX - 1)

# From coreutils-8.10 through 8.20, this would make cut try to allocate
# a 256MiB bit vector.  With a 20MB limit on VM, the following would fail.
(ulimit -v 20000; : | cut -b$CUT_MAX- > err 2>&1) || fail=1

# Up to and including coreutils-8.21, cut would allocate possibly needed
# memory upfront.  Subsequently extra memory is no longer needed.
(ulimit -v 20000; : | cut -b1-$CUT_MAX >> err 2>&1) || fail=1

# Explicitly disallow values above CUT_MAX
(ulimit -v 20000; : | cut -b$SIZE_MAX 2>/dev/null) && fail=1
(ulimit -v 20000; : | cut -b$SIZE_OFLOW 2>/dev/null) && fail=1

compare /dev/null err || fail=1

Exit $fail
