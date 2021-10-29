set -v

NAME="big_content"

rm -rf $NAME
mkdir -p $NAME

head -c 10M </dev/urandom >$NAME/0
head -c 10M </dev/urandom >$NAME/1

# Create a file with the size of your dataset
truncate -s 21M $NAME.img

# Format the file using bcachefs file format
bcachefs format\
     --block_size=4k\
     --metadata_checksum=none\
     --data_checksum=none\
     --compression=none\
     --str_hash=siphash\
     --label=LabelDEADBEEF\
     $NAME.img

# Create a mount point we can write to
mkdir -p tmp

echo "Mount"
# Mount our image for writing
bcachefs fusemount -s $NAME.img tmp

echo "Copy"
cp -vdRLu $NAME/* tmp/

echo "Sanity Check"
original=$(find $NAME -type f -exec md5sum {} \; | cut -d ' ' -f 1 | sort | md5sum)
backup=$(find tmp/ -type f -exec md5sum {} \; | cut -d ' ' -f 1 | sort | md5sum)

echo "original $original"
echo "backup $backup"

# Dismount the image
fusermount3 -u tmp
rm -rf tmp

if [ "$original" != "$backup" ]; then
    echo "Image is wrong"
    rm -rf $NAME.img 
fi
