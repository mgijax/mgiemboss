#!/bin/sh
#
# This script gets the compressed genbank (*.seq.gz) files
# from dataServer:/data/downloads/genbank/
# untars and generates emboss indexes 
#
# The old files and indexes are stored under flatfile.old and
# indexes.old directories respectively and restored on failure 

# Assumption:
# 1) The script is called from a preconfigured script (indexGenbank.sh)
# 2) All the environment variables have been set in indexGenbank.sh
#
# What it does:
# 1) Sets expected directory structure
# 2) Checks that the update is needed by comparing the release numbers
# 3) Saves previous data and inedexes
# 4) moves new data from temp location to dataset files base
# 5) generates indexes in temp
# 6) moves indexes from temp to index base
# 7) updates Emboss config with new release number
# 8) updates local flag
#
cd `dirname $0`; 

rdate=`date +%D`
last_update=""

SCRIPT_NAME=`basename $0`
date | tee -a ${LOG}
echo "Starting $SCRIPT_NAME " | tee -a ${LOG}
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

if [ "$release" = "$last_update" ]
then
  echo "No update needed the last download date $release matches what's in db $last_update " |  tee -a ${LOG}
  echo "Program complete"
  exit
fi

date | tee -a ${LOG}
echo "Indexing $embossdb release $release" | tee -a $LOG
#
# set up dir structure 
#
if [ ! -d $old_dir ]
then
   mkdir  $old_dir
else
   rm -f $old_dir/*
fi

#save current index
if [ ! -d $old_indexdir ]
then
   mkdir  $old_indexdir
else
   rm -f $old_indexdir/*
fi

if [ ! -d $temp_indexdir ]
then
   mkdir  $temp_indexdir
else
   rm -f $temp_indexdir/*
fi

#Save old indexes and data
mv $embossdbdir/$embossfile $old_dir
mv $embossdbindexdir/*.* $old_indexdir/
#Move new data files from temp to dataset file base
#
mv $temp_dir/$embossfile $embossdbdir/

# Index new release
echo $dbflat -dbname="$embossdb" -idformat="$embossfileformat" -directory="$embossdbdir" -filenames="$embossfile" -release=$release -date=$rdate -outfile="${LOG_DIR}/$dblogfile" -indexoutdir="$temp_indexdir" | tee -a $LOG

$dbflat -dbname="$embossdb" -idformat="$embossfileformat" -directory="$embossdbdir" -filenames="$embossfile" -release=$release -date=$rdate -outfile="${LOG_DIR}/$dblogfile" -indexoutdir="$temp_indexdir" 

#move new indexes from temp to index base
mv $temp_indexdir/*.* $embossdbindexdir

date | tee -a ${LOG}
#update Emboss config file with new release
$perl $updateConfigScript $embossdb $release $embossconfig
#update release flag
echo "$release" > $last_updatefile

echo "genbank release: " $release | tee -a ${LOG}
echo "${SCRIPT_NAME} completed successfully " | tee -a ${LOG}
date | tee -a ${LOG}

exit 0



