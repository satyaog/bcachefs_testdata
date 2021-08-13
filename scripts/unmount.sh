#!/bin/sh
set -o errexit -o noclobber

singularity exec instance://bcachefs fusermount3 -u mount/
singularity instance stop bcachefs
