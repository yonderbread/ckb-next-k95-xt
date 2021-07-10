#!/usr/bin/env bash

set -e

sudo apt update
sudo apt install -y build-essential cmake libudev-dev qtbase5-dev zlib1g-dev libpulse-dev libquazip5-dev libqt5x11extras5-dev libxcb-screensaver0-dev libxcb-ewmh-dev libxcb1-dev qttools5-dev git libdbusmenu-qt5-dev


# We want to see the logs in English
if [[ -z "$LC_ALL" && -z "$LANG" ]]; then
	echo "* Weird, neither LC_ALL nor LANG is set:"
	locale
	echo "* Trying LANG=en_US.UTF-8 anyway"
	export LANG="en_US.UTF-8"
else
	# don't let LC_ALL to be set because it always overrides all LC_*,
	# while LANG only sets LC_* once
	if [[ ! -z "$LC_ALL" ]]; then
		export LC_ALL=
	fi
fi

export LC_NUMERIC=C
export LC_TIME=C
export LC_MONETARY=C
export LC_MESSAGES=C
export LC_PAPER=C
export LC_NAME=C
export LC_ADDRESS=C
export LC_TELEPHONE=C
export LC_MEASUREMENT=C
export LC_IDENTIFICATION=C

function checkfail {
    if [[ $1 -ne 0 ]]; then
        echo "An error occurred,"
        echo "press enter to exit."
        read -rs dummy
        exit "$1"
    fi
}

function finish {
    echo "Done."
    echo "Thank you for installing ckb-next!"
    exit 0
}

# Check if we're in the right directory
if [[ ! -f "src/daemon/usb.c" ]]; then
    echo "Please run this script inside the ckb-next source directory."
    exit
fi

rm -rf build

cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Release -DSAFE_INSTALL=ON -DSAFE_UNINSTALL=ON
checkfail $?

# Find out how many cores the system has, for make
if [[ -z "$JOBS" ]]; then
	JOBS=$(getconf _NPROCESSORS_ONLN 2>/dev/null)
fi

# Default to 2 jobs if something went wrong earlier
if [[ -z "$JOBS" ]]; then
    JOBS=2
fi

cmake --build build --target all -- -j "$JOBS"
checkfail $?

sudo cmake --build build --target install
checkfail $?

finish
