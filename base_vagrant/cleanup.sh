#!/bin/bash

#set -Eeuo pipefail

# Credits to:
#  - https://github.com/chef/bento/blob/master/ubuntu/scripts/cleanup.sh
#  - https://gist.github.com/adrienbrault/3775253
#  - https://gist.github.com/adrienbrault/3775253


apt-get -y autoremove;
apt-get -y clean;

# Remove thumbnail cache
rm -rf ~/.cache/thumbnails/*

# Remove docs
rm -rf /usr/share/doc/*

# Remove caches
find /var/cache -type f -exec rm -rf {} \;

# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;

# Remove documentation files
printf "STEP: Remove documentation files\n"
find /var/lib/doc -type f | xargs rm -f

# Zero free space to aid VM compression
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

touch /var/cleanup_done

