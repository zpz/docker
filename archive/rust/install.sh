# This is broken.


# Need to preserve containers so that `cargo` cache stays.
# May need a better solution at some point.


python ../../../pyinstall.py --cmd=rust --options="-it"
( cd ~; rust )

# This will enter docker container.
# Type `exit` to exit the container, and this script will continue.

container_id=$(docker ps --last 1 -q)
echo "Container ID: " ${container_id}
#docker stop ${container_id}
filename=~/work/bin/rust

echo "#! /usr/bin/env bash" > ${filename}
echo >> ${filename}
echo "docker start --attach -i ${container_id}" >> ${filename}
chmod +x ${filename}

