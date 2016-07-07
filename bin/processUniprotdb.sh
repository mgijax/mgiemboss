#!/bin/sh
#
# This script gets the compressed uniport file
# from hobbiton:/data/downloads/uniprot/swissprot
# untars, splits it into chunks of 2G files,and
# generates emboss indexes 
#
cd `dirname $0`; 

release=""
rdate=`date +%D`
split_file=0
last_update=""

SCRIPT_NAME=`basename $0`
date | tee -a ${LOG}
echo "Starting $SCRIPT_NAME " | tee -a ${LOG}
#
#Check if update needed - by  comparing date on lastupdate date
# to the date the source file was downloaded 
#
date | tee -a ${LOG}
if [ ! -f $sourcedir/$sourcefilename ]
then
   echo "$sourcedir/$sourcefilename does not exists" | tee -a ${LOG}
   exit 1
fi
#
#Check if the source file is being edited 
#
echo "Checking if $sourcefilename is being edited " | tee -a ${LOG}
openfile=`lsof | grep $sourcefilename`
if [ "$openfile" != "" ]
then 
   echo "$sourcefilename is being updated, check  :  $openfile" | tee -a ${LOG}
   exit 1

fi

echo "$sourcefilename is not open " |tee -a ${LOG}
#get last emboss db update date for this dataset 
if [ -f $last_updatefile ]
then 
  last_update=`cat $last_updatefile`
else
  touch $last_updatefile
fi
#Get the source file download date
#filedownload_date=`ls -ltr $sourcedir/$sourcefilename |cut -d " " -f6 |sed s/-/_/g`
#The result format of ls -ltr was not consistent between the comand line run and the cron run
#so I changed ls with stat
#
# set the release id
#
release=` stat -c%y $sourcedir/$sourcefilename | cut -d " " -f1 | sed s/-/_/g|cut -d "_" -f"1-2"`
if [ "$release" = "$last_update" ]
then
  echo "No update needed the last download date $release matches what's in db $last_update " |  tee -a ${LOG}
  echo "Program complete"
  exit
fi
#
# set up dir structure 
#
date | tee -a ${LOG}
echo 'Setting up directory structure' | tee -a ${LOG}

if [ ! -d $temp_dir ]
then
    echo "Creating $temp_dir"
    mkdir  $temp_dir
else
    if ! find $temp_dir -maxdepth 0 -empty | read
    then
         if [ "$temp_dir" != "/" ]
         then  
            echo "Removing temp files"
            rm $temp_dir/*
          fi
    fi
fi

echo 'Unzipping source file' | tee -a ${LOG}
$zcatprog $sourcedir/$sourcefilename > $temp_dir/$temp_file

#Check if the file exist and check the size
date | tee -a ${LOG}
if [ -f $temp_dir/$temp_file ]
then
   echo "File unzipped successfully" | tee -a ${LOG} 
else
   echo "zcat file failed - $zcatprog $sourcedir/$sourcefilename > $temp_dir/$temp_file" | tee -a ${LOG}
   exit 1
fi

#Check the size of the file
filesize=`ls -lh $temp_dir/$temp_file| cut -d " " -f5 |sed s/G//g`
echo "The file size is $filesize GB"
filesize=`echo $filesize|cut -d "." -f1`
decimal=`echo $filesize|cut -d "." -f2`
if [ $filesize -gt 2 ]
then 
   split_file=1
else
   if [ $filesize -eq 2 ]
   then
      if [ $decimal -gt 0 ]
      then 
         split_file=1
       fi
    fi 
fi
date | tee -a ${LOG}
if [ $split_file -eq 1 ] 
then
   echo "Spliting $temp_dir/$temp_file  "| tee -a ${LOG}
   $splitScript $temp_dir/$temp_file $filePrefix $chunkSize $temp_dir $fileSufix
   filecount=`ls $temp_dir |grep ".$fileSufix" | wc -l`
   if [ $filecount -gt 0 ]
   then
      rm -f $temp_dir/$temp_file
      if [ ! -d $old_dir ]
      then
         mkdir  $old_dir
      else
         rm -f $old_dir/* 
      fi
      #move current flat files to old directory
      ##if [ $isTrembl -gt 0 ]
      ##then
      ##   $filterScript $temp_dir/ $taxonfile | tee -a ${LOG}
      ##fi
      mv $embossdbdir/$embossfile $old_dir
      mv $temp_dir/$embossfile $embossdbdir
   else
     echo "command failed : $splitScript $temp_dir/$temp_file $filePrefix $chunkSize $temp_dir $fileSufix " | tee -a ${LOG} 
     exit 1
   fi
else
  if [ ! -d $old_dir ]
  then
     mkdir  $old_dir
  else
     rm -f $old_dir/*
  fi
  mv $embossdbdir/$embossfile $old_dir
  mv $temp_dir/$temp_file $embossdbdir/$temp_file.$fileSufix 
fi

date | tee -a $LOG
#Now I need to generate indexes
echo "Indexing $embossdb release $release" | tee -a $LOG
#save current index
if [ ! -d $embossdbindexdir ]
then
   mkdir  $embossdbindexdir
fi

if [ ! -d $embossdbindexdir/old ]
then
   mkdir  $embossdbindexdir/old
else
   rm -f $embossdbindexdir/old/*
fi

if [ ! -d $temp_indexdir ]
then
   mkdir  $temp_indexdir
else
   rm -f $temp_indexdir/*
fi

cp $embossdbindexdir/*.* $embossdbindexdir/old/

echo $dbflat -dbname="$embossdb" -idformat="$embossfileformat" -directory="$embossdbdir" -filenames="$embossfile" -release=$release -date=$rdate -outfile="${LOG_DIR}/$dblogfile" -indexoutdir="$temp_indexdir" | tee -a $LOG
$dbflat -dbname="$embossdb" -idformat="$embossfileformat" -directory="$embossdbdir" -filenames="$embossfile" -release=$release -date=$rdate -outfile="${LOG_DIR}/$dblogfile" -indexoutdir="$temp_indexdir" 
#
# $dbflat -dbname="$embossdb" -dbresource=swissresource -fields=id -compressed=Y -idformat="$embossfileformat" -directory="$embossdbdir" -filenames="$embossfile" -release=$release -date=$rdate -outfile="${LOG_DIR}/$dblogfile" -indexoutdir="$temp_indexdir"

if [ $? -ne 0 ]
then
   echo "Dataset update failed - restore the flat files\n"
   exit 1
fi

mv $temp_indexdir/*.* $embossdbindexdir

date | tee -a ${LOG}
#update the config file with new release
$perl $updateConfigScript $embossdb $release $embossconfig
#update release flag
echo "Update needed - last download date $release does not match what's in db $last_update " |  tee -a ${LOG}
echo "$release" > $last_updatefile

echo "${SCRIPT_NAME} completed successfully " | tee -a ${LOG}
date | tee -a ${LOG}

exit 0



