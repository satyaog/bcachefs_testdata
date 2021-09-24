#!/bin/sh
set -o errexit -o noclobber

if [ -z "${NAME}" ]
then
	export NAME=bcachefs.img
fi

if [ -z "${SIZE}" ]
then
	export SIZE=10MiB
fi

if [ -e "${NAME}" ]
then
	exit 1
fi

truncate -s ${SIZE} "${NAME}"
./bcachefs-tools.sif format --block_size=4k --metadata_checksum=none --data_checksum=none --compression=none --str_hash=siphash --label=LabelDEADBEEF $PWD/"${NAME}"
