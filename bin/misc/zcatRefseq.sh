#!/bin/sh
# Version 2 12/7/2009
# Version 3 01/23/2011
# sc - updated 9/5/2013
# sc - update 09/10/2013
#
# lnh - updated 1/29/2015
#
# This script is called from the updateRefseq.sh script
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

for file in `ls $filePrefix*.rna.g?ff.gz |sed s/.gz//`
do
	if [ -f $destination/$file ] 
	then
		echo "already expanded" $file
	else
 		echo "Expanding this file: " $file
		# sc - strip out lines  beginning with 'PROJECT' and 'DBLINK'
		$zcatprog ${file}.gz  | sed -e '/^PROJECT/d' | sed -e '/^DBLINK/d' > $destination/${file}
	fi
done

for file in `ls $filePrefix*.protein.g?ff.gz |sed s/.gz//`
do
	if [ -f $destination/$file ] 
	then
		echo "already expanded" $file
	else
 		echo "Expanding this file: " $file
	# sc - strip out lines  beginning with 'PROJECT' and 'DBLINK'
	$zcatprog ${file}.gz  | sed -e '/^PROJECT/d' | sed -e '/^DBLINK/d' > $destination/${file}
	fi
done

echo 'File Count:'
ls -l $destination/$filePrefix* | wc -l

echo "end: " `date`

