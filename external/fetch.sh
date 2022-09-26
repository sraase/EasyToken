#!/bin/bash

#
# OpenConnect (SSL + DTLS) VPN client
#
# Copyright © 2014 Kevin Cernekee <cernekee@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# version 2.1, as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#

set -e

libxml2_MIRROR_0=http://xmlsoft.org/download
libxml2_MIRROR_1=http://sources.buildroot.net/libxml2
libxml2_MIRROR_2=http://distfiles.macports.org/libxml2

gmp_MIRROR_0=http://ftp.gnu.org/gnu/gmp
gmp_MIRROR_1=ftp://ftp.gmplib.org/pub/gmp
gmp_MIRROR_2=http://mirror.anl.gov/pub/gnu/gmp
gmp_MIRROR_3=http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gmp

nettle_MIRROR_0=http://www.lysator.liu.se/~nisse/archive
nettle_MIRROR_1=http://mirror.anl.gov/pub/gnu/nettle
nettle_MIRROR_2=http://ftp.gnu.org/gnu/nettle
nettle_MIRROR_3=http://sources.buildroot.net/nettle

MAX_TRIES=5

function make_url
{
	local tarball="${1##*/}"
	local mirror_idx="$2"

	local pkg="${tarball%-*}"
	pkg="${pkg/-/_}"

	if [[ "$pkg" =~ [^[:alnum:]_] ]]; then
		echo ""
		return
	fi

	eval local mirror_base="\$${pkg}_MIRROR_${mirror_idx}"
	eval local mirror_suffix="\$${pkg}_SUFFIX_${mirror_idx}"

	if [ -z "$mirror_base" ]; then
		echo ""
		return
	fi

	echo "${mirror_base}/${tarball}${mirror_suffix}"
	return

}

function check_hash
{
	local tarball="$1"
	local good_hash="$2"

	local actual_hash=$(sha1sum "$tarball")
	actual_hash=${actual_hash:0:40}

	if [ "$actual_hash" = "$good_hash" ]; then
		return 0
	else
		echo "$tarball: hash mismatch"
		echo "  expected: $good_hash"
		echo "  got instead: $actual_hash"
		return 1
	fi
}

function download_and_check
{
	local url="$1"
	local tmpfile="$2"
	local hash="$3"

	rm -f "$tmpfile"
	if curl --location --connect-timeout 30 --speed-limit 1024 \
			-o "$tmpfile" "$url"; then
		if [ -n "$hash" ]; then
			if ! check_hash "$tmpfile" "$hash"; then
				return 1
			fi
		fi
		return 0
	fi
	return 1
}

# iterate through all available mirrors and make sure they have a good copy
# of $tarball
function mirror_test
{
	local tarball="$1"
	local good_hash="$2"

	if [ -z "$good_hash" ]; then
		echo "ERROR: you must specify the hash for testing mirrors"
		exit 1
	fi

	local mirror_idx=0
	local tmpfile="${tarball}.mirror-test.tmp"

	while :; do
		local url=$(make_url "$tarball" "$mirror_idx")
		if [ -z "$url" ]; then
			break
		fi

		echo ""
		echo "Testing mirror $url"
		echo ""

		if download_and_check "$url" "$tmpfile" "$good_hash"; then
			echo ""
			echo "SHA1 $good_hash OK."
			echo ""
		else
			exit 1
		fi

		echo ""
		mirror_idx=$((mirror_idx + 1))
	done

	m -f "$tmpfile"
	echo "Mirror test for $tarball PASSED"
	echo ""
	exit 0
}

#
# MAIN
#

if [ "$1" = "--mirror-test" ]; then
	mirror_test=1
	shift
else
	mirror_test=0
fi

if [ -z "$1" ]; then
	echo "usage: $0 [ --mirror-test ] <tarball_to_fetch> [ <sha1_hash> ]"
	exit 1
fi

tarball="$1"
hash="$2"

if [ $mirror_test = 1 ]; then
	mirror_test "$tarball" "$hash"
	exit 1
fi

if [ -e "$tarball" -a -n "$hash" ]; then
	if check_hash "$tarball" "$hash"; then
		echo "$tarball hash check passed. Done."
		echo ""
		exit 0
	fi
fi

tries=1
tmpfile="${tarball}.tmp"

while :; do
	mirror_idx=0
	while :; do
		url=$(make_url "$tarball" "$mirror_idx")
		if [ -z "$url" ]; then
			if [ $mirror_idx = 0 ]; then
				echo "No mirrors found for $tarball"
				exit 1
			else
				break
			fi
		fi

		echo ""
		echo "Attempt #$tries for mirror $url:"
		echo ""

		if download_and_check "$url" "$tmpfile" "$hash"; then
			mv "$tmpfile" "$tarball"
			exit 0
		fi

		echo ""
		mirror_idx=$((mirror_idx + 1))
	done

	tries=$((tries + 1))
	if [ $tries -gt $MAX_TRIES ]; then
		break
	fi

	echo "All mirrors failed; sleeping 10 seconds..."
	echo ""
	sleep 10
done

rm -f "$tarball" "$tmpfile"

echo "ERROR: Unable to download $tarball"
echo ""
exit 1
