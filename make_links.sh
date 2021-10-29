set -v

rm -rf link_content
mkdir -p link_content

truncate -s 1M link_content/0

for i in {1..5000}; do
    ln "link_content/0" "link_content/$i"
done

SIZE=$(du -shc link_content | tail -n 1 | cut -f 1)

# Create a file with the size of your dataset
truncate -s 10M link_content.img

# Format the file using bcachefs file format
bcachefs format\
     --block_size=4k\
     --metadata_checksum=none\
     --data_checksum=none\
     --compression=none\
     --str_hash=siphash\
     --label=LabelDEADBEEF\
     link_content.img


# Create a mount point we can write to
mkdir -p tmp

echo "Mount"
# Mount our image for writing
bcachefs fusemount -s link_content.img tmp

echo "Copy"
# copy our files to the disk image
#   -d: preserve link
#   -R: Recursive
#   -L: follow symbolic links in source
#   -u: Update when source file is newer
cp -dRLu link_content/* tmp/

echo "Sanity Check"
find link_content -type f -exec md5sum {} \; | sort -k 2 | md5sum
find tmp -type f -exec md5sum {} \; | sort -k 2 | md5sum

# Dismount the image
fusermount3 -u tmp
rm -rf tmp
