#!/bin/sh
set -o errexit -o noclobber

if [ -z "${MD5SUMS}" ]
then
	exit 1
fi

for item in "$@"
do
	singularity exec instance://bcachefs cp -aLu content/"$item" mount/
done
singularity exec instance://bcachefs scripts/checksum.sh > "${MD5SUMS}".checksums
