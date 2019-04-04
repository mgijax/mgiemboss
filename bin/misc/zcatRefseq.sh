#!/bin/sh
#
# zcatRefseq.sh 
#
# sc - updated to process multi source dirs
#
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

if [ ! -d $temp_dir ]
then
    echo "Creating $temp_dir"
    mkdir  $temp_dir
else
    echo "Removing files from $term_dir"
    rm $temp_dir/*
fi

echo "start: " `date`
echo "Data directories: " $sourcedir
echo "Destination directory: " $temp_dir

for dir in $sourcedir:
    cd $dir
    echo "File Count in $dir:"
    ls -l *.gz | wc -l

    for file_group in $REMOTE_FILES
    do
       echo "File count for $file_group:"
       ls -l $dir/*$file_group.gz | wc -l
       for file in `ls -f *$file_group.gz |sed s/.gz//`
       do
	    if [ -f $temp_dir/$file ] 
	    then
		    echo "already expanded:" $file
	    else
		    echo "Expanding this file: " $file
		    #set the release number if not set
		    # sc - strip out lines  beginning with 'PROJECT' and 'DBLINK'
		    $zcatprog ${file}.gz  | sed -e '/^PROJECT/d' | sed -e '/^DBLINK/d' > $temp_dir/${file}
	    fi

	done
    done
done

echo 'File Count:'
ls -l $temp_dir/ | wc -l

echo "end: " `date`
