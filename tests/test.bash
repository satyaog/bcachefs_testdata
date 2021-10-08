
TEST_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source $TEST_DIR/../scripts/bcache-tools.bash
SCRIPT_DIR=$TEST_DIR

SIZE=300MiB
IMAGE="$SCRIPT_DIR/dataset_img"
SOURCE="$SCRIPT_DIR/dataset_src"
MOUNT="$SCRIPT_DIR/dataset"

echo $SCRIPT_DIR
rm -rf $IMAGE $MOUNT $SOURCE

# Create fake "dataset"
mkdir -p $SOURCE
touch $SOURCE/file.txt
# =====

# Create a mount point
mkdir $MOUNT
# =====

# Create the storage necessary for the the dataset
create-bcachefs-image $IMAGE $SIZE

# Mount our image for writing
# making the original dataset available inside the container (in /content)
mount-bcachefs-image $IMAGE $MOUNT $SOURCE

# ================
# Copy our dataset
# copy from /content to /mount
# singularity exec instance://bcachefs touch "/mount/0"
# for i in {1..1200000}
# do
# 	singularity exec instance://bcachefs ln "/mount/0" "/mount/$i"
# done
# ================

unmount-bcachefs-image $IMAGE

# Tests cleanup
rm -rf $IMAGE $MOUNT $SOURCE
