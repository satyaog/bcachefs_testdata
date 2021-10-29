set -v

NAME=link_content
rm -rf $NAME
mkdir -p $NAME

truncate -s 1M $NAME/0

for i in {1..5000}; do
    ln "$NAME/0" "$NAME/$i"
done

# SIZE=$(du -shc link_content | tail -n 1 | cut -f 1)

# Create a file with the size of your dataset
truncate -s 100M $NAME.img

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
# copy our files to the disk image
#   -d: preserve link
#   -R: Recursive
#   -L: follow symbolic links in source
#   -u: Update when source file is newer
cp -vdRLu $NAME/ tmp/

# i=0
# files=$(python filebatch.py -b 20 -i $i link_content)
# while [ ! -z "$files" ]; do
#     cp -vdRLu $files tmp/

#     i=$[$i+1]
#     files=$(python filebatch.py -b 20 -i $i link_content)
#     sleep 2
# done


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
