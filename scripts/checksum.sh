#!/bin/sh
set -o errexit -o noclobber

if [ -z "${MD5SUMS}" ]
then
	exit 1
fi

MD5SUMS=$(cd "$(dirname "${MD5SUMS}")"; pwd)/"$(basename ${MD5SUMS})"
cd mount/
md5sum -c "${MD5SUMS}"
