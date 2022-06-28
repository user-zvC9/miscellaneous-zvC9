#!/bin/bash


# this directory will be compressed
name="compress_me"
# "yes" or "no"
run_zstd=no

# next lines you can skip

function user-zvC9-sync {
 sync
}

function user-zvC9-extract-times {
 cat "${result_times_file}" | \
  sed -E -e "/time:/d" | sed -E -e "s/.* ([0-9]*):([0-9.]*)elapsed.*/\\1 \\2/g" | \
  sed -E -e "s/\\./,/g" | sed -E -e "/inputs/d" | sed -E -e "/^\\s*\$/d" > ${result_times_file_short}

}

export LC_ALL=C
export LANG=C

results_file="compressed-sizes.txt"
result_times_file="compression-times-full.txt"
result_times_file_short="compression-times-short.txt"

## not accurate
#result_dd_file="compression-speeds-dd.txt"
## can be file or /dev/null
result_dd_file="/dev/null"

rm -fv "$results_file"
rm -fv "$result_times_file"
if test "$result_dd_file" != "/dev/null" ; then
 rm -fv "$result_dd_file"
fi
user-zvC9-sync

echo -n "UNCOMPRESSED: byte count=" >> $results_file
echo "UNCOMPRESSED creation time:" >> $result_times_file
echo "UNCOMPRESSED creation speed:" >> $result_dd_file

user-zvC9-sync

echo compressor: NONE
echo level: NONE
tar -c "$name" | dd bs=1M status=progress | /bin/time --append -o "$result_times_file" dd bs=1M 2>> $result_dd_file |  wc --bytes >> $results_file
user-zvC9-sync

for compressor in gzip  bzip2  xz  ; do
 if [ "x$compressor" = "xxz" ] ; then
  echo compressor: xz
  echo level: -0
  echo -n "xz -0: byte count=" >> $results_file
  echo -e "\\nxz -0: time:" >> "$result_times_file"
  echo -e "\\nxz -0 speed:" >> $result_dd_file
  user-zvC9-sync
  tar -c "$name" | dd bs=1M status=progress | dd bs=1M 2>> $result_dd_file | /bin/time --append -o "$result_times_file" $compressor -0 |  wc --bytes >> $results_file
  user-zvC9-sync
 fi
 for ((level=1;level<10;++level)) ; do
  echo compressor: $compressor
  echo level: $level
  echo -n "$compressor -$level: byte count=" >> $results_file
  echo -e "\\n$compressor -$level: time:" >> "$result_times_file"
  echo -e "\\n$compressor -$level speed:" >> $result_dd_file
  user-zvC9-sync
  tar -c "$name" | dd bs=1M status=progress | dd bs=1M  2>> $result_dd_file | /bin/time --append -o "$result_times_file" $compressor -$level |  wc --bytes >> $results_file
  user-zvC9-sync
 done
done

if test "$run_zstd" = yes ; then
 compressor=zstd
 for ((level=1;level<20;++level)) ; do
  echo compressor: $compressor
  echo level: $level
  echo -n "$compressor -$level: byte count=" >> $results_file
  echo -e "\\n$compressor -$level: time:" >> "$result_times_file"
  echo -e "\\n$compressor -$level speed:" >> $result_dd_file
  user-zvC9-sync
  tar -c "$name" | dd bs=1M status=progress | dd bs=1M  2>> $result_dd_file | /bin/time --append -o "$result_times_file" $compressor -$level |  wc --bytes >> $results_file
  user-zvC9-sync
 done
fi

user-zvC9-extract-times
user-zvC9-sync

