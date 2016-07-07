#!/bin/sh
#
# This script is a wrapper that sets
# SwissProt  configuration variables 
# before calling the script that
# generates emboss indexes 
#
cd `dirname $0`; . ../Configuration

splitScript=$scriptdir/split_uniprotFile.awk
updateScript=$scriptdir/processUniprotdb.sh
updateConfigScript=$scriptdir/updateEmbossConfig.pl

embossdbdir=$sprot_embossdbdir
temp_dir=$embossdbdir/temp
old_dir=$embossdbdir/old
temp_file=$sprot_embossdb

sourcedir=$sprot_sourcedir
sourcefilename=$sprot_sourcefilename
embossfile=$sprot_embossfile
filePrefix=$sprot_filePrefix 
chunkSize=$sprot_chunkSize
fileSufix=$sprot_fileSufix
dblogfile=$sprot_embossdb.log
embossdb=$sprot_embossdb
embossfileformat=$sprot_embossfileformat
embossdbindexdir=$sprot_embossdbindexdir
temp_indexdir=$sprot_embossdbindexdir/tempIdx

SCRIPT_NAME=`basename $0`
LOG_DIR=$logdir
logfile=$sprot_embossdb$moddate_prefix.log
last_updatefile=${LOG_DIR}/$logfile

LOG=${LOG_DIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}
echo "$0" >> ${LOG}

export LOG last_updatefile LOG_DIR embossdbindexdir embossfileformat
export embossdb dblogfile fileSufix chunkSize filePrefix embossfile
export perlpath sourcefilename sourcedir temp_file temp_dir old_dir embossdbdir
export splitScript updateScript zcatprog dbflat embossconfig updateConfigScript
export temp_indexdir

$updateScript
#
#To Do
# Check the logs for errors
# If error:
# 1) restore flatfiles
# 2) restore indexes.
#

date | tee -a ${LOG}
echo "${SCRIPT_NAME} completed successfully " | tee -a ${LOG}
date | tee -a ${LOG}

exit 0



