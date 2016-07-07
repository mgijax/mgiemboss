#!/bin/sh
# Version 2 12/7/2009
# sc - updated 01/07/2013
# sc - updated 09/10/2013
#
# lnh - updated 11/05/2014
#
# This script is called from the updateGenbank.sh script
# Asumption - all the global variables have already been set
#
# It took about 3 hours to run
# 
datadir=$sourcedir
destination=$temp_dir

if [ ! -d $destination ]
then
    echo "Creating $destination"
    mkdir  $destination
else
    echo "Removing temp files"
    if ! find $destination -maxdepth 0 -empty | read
    then
      rm $destination/*
    fi
fi

echo "start: " `date`
echo "Data directory: " $datadir
echo "Destination directory: " $destination
echo "The file prefix: " $filePrefix

cd $datadir

for file in `ls $filePrefix*.gz |sed s/.gz//`
do
	if [ -f $destination/$file ] 
	then
		echo "already expanded:" $file
	else
 		echo "Expanding this file: " $file
                #set the release number if not set
		# sc - strip out lines  beginning with 'PROJECT' and 'DBLINK'
		$zcatprog ${file}.gz  | sed -e '/^PROJECT/d' | sed -e '/^DBLINK/d' > $destination/${file}
	fi

done

echo 'File Count:'
ls -l $destination/$filePrefix*.seq | wc -l

echo "end: " `date`
