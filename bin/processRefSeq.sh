#!/bin/sh
#
# processRefSeq.sh
#
# This script is called by  indexRefSeq.sh
# scripts to index refSeq sequences in to EMBOSS 
#
# Assumption:
# 1. The files have already been copied/unzipped from hobbiton to /data/databases/refseq/temp
# 2. refseq rna file name has the format: complete.*.rna.gbff 
# 3. refseq protein file name has the format: complete.*.protein.gpff 
#
# The old files and indexes are stored under flatfile.old and
# indexes.old directories respectively and restored on failure 
#
# Author: lnh
# Date: 2/2015
#
# What it does:
# 1) Gets the release number and decides if update needed 
# 2) Verifies and set up expected dir structure 
# 3) Moves current flatfiles to flatfiles.old
# 4) Moves new files from temp/ to flatfiles/
# 5) Copies current index files from indexdir/ to old_indexdir/
# 6) Calls dbfasta script to index new files 
# 7) Copies new index files from temp_indexdir/ to indexdir/
# 8) update the release number in emboss.default
#
# HISTORY
#
#	04/04/19 - sc
#		- updated to factor out over configuration and process files
#		- from multiple directories
cd `dirname $0`; 

release=""
rdate=`date +%D`
relID=0
need_update=0
temp_file=""

SCRIPT_NAME=`basename $0`
date | tee -a ${LOG}
echo "**************** " | tee -a ${LOG}
echo "Starting $SCRIPT_NAME  -release date: $rdate" | tee -a ${LOG}
echo "****************" | tee -a ${LOG}
date | tee -a ${LOG}
#
#Check if update needed - by  comparing date on lastupdate date
# to the date the source file was downloaded 
#
date | tee -a ${LOG}
#get last emboss db update date for this dataset 
if [ -f $last_updatefile ]
then
  last_update=`cat $last_updatefile`
else
  touch $last_updatefile
fi
#
# set the release id
#
if [ ! -f $refseq_release_file ]
then
   echo "Dataset update failed - missing $refseq_release_file file"
   exit 1
fi
release=`cat $refseq_release_file`
if [ "$release" = "$last_update" ]
then
  echo "No update needed current release $release is in sync" |  tee -a ${LOG}
  echo "Program complete"
  exit
fi
echo "Updating EMBOSS with $release release" |  tee -a ${LOG}
#
# set up dir structure 
#
date | tee -a ${LOG}
echo 'Setting up directory structure' | tee -a ${LOG}
if [ ! -d $old_dir ]
then
   echo "creating old_dir $old_dir"
   mkdir  $old_dir
fi

date | tee -a ${LOG}
for file_group in $REMOTE_FILES
do
    echo "processing file_group $file_group"
    filecount=`ls $refseq_flatfiles_basedir/ | grep $file_group | wc -l`
    if [ $filecount -gt 0 ]
    then
         echo "Moving $filecount $refseq_flatfiles_basedir/*$file_group to $old_dir" | tee -a ${LOG}
         rm -f $old_dir/*$file_group
         echo "mv $refseq_flatfiles_basedir/*$file_group $old_dir"
         mv $refseq_flatfiles_basedir/*$file_group $old_dir
    fi
    echo "Moving $temp_dir/*$file_group to $refseq_flatfiles_basedir" | tee -a ${LOG}
    mv $temp_dir/*$file_group $refseq_flatfiles_basedir
done
date | tee -a ${LOG}

# Generate indexes
echo "Indexing $embossdb release $release" | tee -a $LOG
echo "old_dir=$old_dir "| tee -a $LOG
echo "refseq_file_pattern=$refseq_file_pattern"| tee -a $LOG
echo "temp_dir=$temp_dir"| tee -a $LOG
echo "refseq_flatfiles_basedir=$refseq_flatfiles_basedir"| tee -a $LOG
echo "embossdbindexdir=$embossdbindexdir"| tee -a $LOG
echo "old_indexdir=$old_indexdir"| tee -a $LOG
echo "temp_indexdir=$temp_indexdir"| tee -a $LOG

#
#set index directories
if [ ! -d $embossdbindexdir ]
then
   echo "creating embossdbindexdir $embossdbindexdir"
   mkdir  $embossdbindexdir
fi

if [ ! -d $old_indexdir ]
then
   echo "creating old_indexdir $old_indexdir"
   mkdir  $old_indexdir 
else
   rm -f $old_indexdir/*.*
fi

if [ ! -d $temp_indexdir ]
then
   echo "creating temp_indexdir $temp_indexdir"
   mkdir  $temp_indexdir
else
   rm -f $temp_indexdir/*.*
fi

date | tee -a ${LOG}
echo "Archiving current Indexes: cp $embossdbindexdir/*.* $old_indexdir/" |tee -a ${LOG} 
cp $embossdbindexdir/*.* $old_indexdir/

#-debug="Y"
date | tee -a ${LOG}
echo "Indexing $embossdb" |tee -a ${LOG}

# OLD dbflat call
#$dbflat -dbname="$embossdb" -idformat="$embossfileformat" -directory="$flatfiles_dir" -filenames="$embossfile" -release=$release -date=$rdate -outfile="${LOG_DIR}/$dblogfile" -indexoutdir="$temp_indexdir" | tee -a $LOG

# NEW dbxflat call (btree indexing)
echo $dbxflat -dbname="$embossdb" -dbresource="$embossdb" -idformat="$refseq_embossfileformat" -directory="$refseq_flatfiles_basedir" -fields="id,acc" -filenames="$refseq_file_pattern" -release=$release -date=$rdate -compressed="Yes" -outfile="$logdir/$dblogfile" -indexoutdir="$temp_indexdir" -debug="Y" | tee -a $LOG

$dbxflat -dbname="$embossdb" -dbresource="$embossdb" -idformat="$refseq_embossfileformat" -directory="$refseq_flatfiles_basedir" -fields="id,acc" -filenames="$refseq_file_pattern" -release=$release -date=$rdate -compressed="Yes" -outfile="$logdir/$dblogfile" -indexoutdir="$temp_indexdir" -debug="Y" | tee -a $LOG

date | tee -a ${LOG}
echo "copying indexes from $temp_indexdir/*.* to $embossdbindexdir" |tee -a ${LOG}
cp $temp_indexdir/*.* $embossdbindexdir

date | tee -a ${LOG}
# uncomment for production
#update the config file with new release
echo "update the EMBOSS config file with new release" |tee -a ${LOG}
echo $perlpath $updateConfigScript $embossdb $release $embossconfig |  tee -a ${LOG}
$perlpath $updateConfigScript $embossdb $release $embossconfig

#update release flag
echo "Update $last_updatefile with release number $release " |  tee -a ${LOG}

echo "$release" > $last_updatefile

echo "${SCRIPT_NAME} completed successfully " | tee -a ${LOG}
date | tee -a ${LOG}

exit 0
