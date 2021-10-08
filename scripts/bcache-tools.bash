#!/bin/bash

BCACHE_LOC=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
BCACHE_TOOLS="$BCACHE_LOC/../bcachefs-tools.sif"


function create-bcachefs-image() {
    if [ $# -ne 2 ]; then
        echo "expects 2 arguments"
        echo "  usage: create-bcachefs-image dataset_img 10MiB"
        return
    fi

    name=$1
    size=$2

    # make the file here
    truncate -s ${size} "${name}"

    $BCACHE_TOOLS format\
        --block_size=4k\
        --metadata_checksum=none\
        --data_checksum=none\
        --compression=none\
        --str_hash=siphash\
        --label=LabelDEADBEEF "${name}"
}

# mount the current folder so all the tools remains available
#   dataset_img: bcachefs image that will store the dataset
#   dataset_src: original source of the datasets (will be copied to the image)
#   dataset: mount point of the image so it can be inspected
#
#   Mount `content` argument inside the container as `/content`
#   Mount the script folder with this tool lib inside `/bcachefs-tools`
#   Mount the image as `/archive`
#   
#   Fuse mount the archive image into mount
function mount-bcachefs-image() {
    if [ $# -ne 3 ]; then
        echo "expects 3 arguments"
        echo "  usage: mount-bcachefs-image dataset_img dataset_src dataset"
        return
    fi

    name=$1
    mount=$2
    content=$3

    # if the container is running stop it
    # suppress the error if any (i.e if no container is running)
    singularity instance stop bcachefs &> /dev/null || echo -n

    singularity instance start\
        -B "$BCACHE_LOC":"/bcachefs-tools":ro\
        -B "$content":"/content":ro\
        -B "$mount":"/archive":rw\
        $BCACHE_TOOLS bcachefs

    echo "Fuse mount the dataset"
    echo ">>>>>>>>>>>>"
    singularity run instance://bcachefs fusemount -s -f $name /archive
    echo "<<<<<<<<<<<<"
}

function unmount-bcachefs-image() {
    if [ $# -ne 1 ]; then
        echo "expects 1 arguments"
        echo "  usage: unmount-bcachefs-image dataset"
        return
    fi

    mount=$1

    singularity exec instance://bcachefs fusermount3 -u "${mount}/"
    singularity instance stop bcachefs
}
