#!/usr/bin/bash

cd /data
rm -f backup.tar.gz
tar -czvf backup.tar.gz ./ascension* ./scan.sh ./describe.sh --exclude '*.gz'