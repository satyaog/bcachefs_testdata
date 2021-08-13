#!/bin/sh
set -o errexit -o noclobber

if [ -z "${CONTENT_SRC}" ]
then
	export CONTENT_SRC="$PWD"
fi

singularity instance stop bcachefs || echo -n
singularity instance start -B "$PWD/":"$PWD/":rw -B "$CONTENT_SRC":"$PWD/content":ro bcachefs-tools.sif bcachefs
singularity run instance://bcachefs fusemount -s -f "${NAME}" mount/
