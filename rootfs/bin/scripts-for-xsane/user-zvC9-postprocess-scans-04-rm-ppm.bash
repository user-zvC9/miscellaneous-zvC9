#!/bin/bash

echo "Danger! Опасность! Continue? Продолжить?"
echo -n \"y\" Enter или \(or\) \"n\" Enter:" "

read answer

if test ! "$answer" = "y" ; then
	echo Aborted
	exit 1
fi

#find -name "*.ppm" -delete
find -name "*.ppm" -exec rm -fv "{}" ";"

