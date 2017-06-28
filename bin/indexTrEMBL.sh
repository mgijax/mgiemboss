#!/bin/sh
#
# This script is a wrapper to set
# TrEMBL  configuration variables 
# before calling the script that
# generates emboss indexes 
#
cd `dirname $0`; . ../Configuration

splitScript=$scriptdir/misc/split_uniprotFile.awk
updateScript=$scriptdir/processUniprotdb.sh
updateConfigScript=$scriptdir/misc/updateEmbossConfig.pl

embossdbdir=$trembl_embossdbdir
temp_dir=$embossdbdir/temp
old_dir=$embossdbdir/old
temp_file=$trembl_embossdb

sourcedir=$trembl_sourcedir
sourcefilename=$trembl_sourcefilename
embossfile=$trembl_embossfile
filePrefix=$trembl_filePrefix 
chunkSize=$trembl_chunkSize
fileSufix=$trembl_fileSufix
dblogfile=$trembl_embossdb.log
embossdb=$tr_embossdb
embossfileformat=$trembl_embossfileformat
embossdbindexdir=$trembl_embossdbindexdir
temp_indexdir=$trembl_embossdbindexdir/tempIdx

SCRIPT_NAME=`basename $0`
LOG_DIR=$logdir
logfile=$trembl_embossdb$moddate_prefix.log
last_updatefile=${LOG_DIR}/$logfile
filterScript=$filtertrembl
isTrembl=1

#Clean the logs 
#
rm -f $LOG_DIR/$dblogfile
LOG=${LOG_DIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}
echo "$0" >> ${LOG}


export LOG last_updatefile LOG_DIR embossdbindexdir embossfileformat
export embossdb dblogfile fileSufix chunkSize filePrefix embossfile
export perlpath sourcefilename sourcedir temp_file temp_dir old_dir embossdbdir
export splitScript updateScript zcatprog dbflat embossconfig updateConfigScript
export temp_indexdir filterScript taxonfile isTrembl

$updateScript

if [ $? -ne 0 ]
then
  echo "Trembl dataset update failed" 
  exit 1
fi
#
#To Do
# Check the logs for errors
# If error:
# 1) restore flatfiles
# 2) restore indexes.
#
if [ -f $LOG_DIR/$dblogfile ]
then
   cat $LOG_DIR/$dblogfile | tee -a ${LOG}
fi

echo "${SCRIPT_NAME} completed successfully " | tee -a ${LOG}
date | tee -a ${LOG}

exit 0



