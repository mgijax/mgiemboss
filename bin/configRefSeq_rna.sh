#!/bin/sh
#
# configRefSeq_rna.sh
#
# This script is a wrapper that sets
# RefsSeq rna  configuration variables 
# before calling the script that
# generates emboss indexes 
#
# HISTORY
#
#       04/04/19 - sc
#               - updated to factor out over configuration and process files
#               - from multiple directories

cd `dirname $0`; . ../Configuration


# used by processRefSeq.sh
refseq_embossfileformat=GB
export refseq_embossfileformat

# used by processRefSeq.sh
refseq_file_pattern=vertebrate_*.gbff
export refseq_file_pattern

#where the flatfiles and indexes are located on the EMBOSS server
temp_dir=$embossdbdir/temp
old_dir=$embossdbdir/flatfiles.old
embossdbindexdir=$embossdbdir/refseqRnaIdx
temp_indexdir=$embossdbindexdir/tempIdx
old_indexdir=$embossdbindexdir/old
REMOTE_FILES="rna.gbff
genomic.gbff"

export temp_dir old_dir embossdbindexdir temp_indexdir
export old_indexdir REMOTE_FILES

# configuration specific to emboss tool
#embossdb=refseqRna
# change to lower case for dbxflat
embossdb=refseqrna
export embossdb 

SCRIPT_NAME=`basename $0`
dblogfile=$embossdb.log
logfile=$embossdb$moddate_prefix.log
last_updatefile=$logdir/$logfile

export dblogfile last_updatefile

LOG=$logdir/${SCRIPT_NAME}.log
export LOG

rm -f ${LOG}
touch ${LOG}
echo "Running $0" | tee -a ${LOG}
echo "" | tee -a ${LOG}
date | tee -a ${LOG}
echo "" | tee -a ${LOG}

echo "Global variables setting" | tee -a ${LOG}
echo "------------------------" | tee -a ${LOG}
echo "updateConfigScript=$updateConfigScript" | tee -a ${LOG}
echo "embossdbdir=$embossdbdir" | tee -a ${LOG}
echo "refseq_flatfiles_basedir=$refseq_flatfiles_basedir" | tee -a ${LOG}
echo "temp_dir=$temp_dir" | tee -a ${LOG}
echo "old_dir=$old_dir" | tee -a ${LOG}
echo "embossdbindexdir=$embossdbindexdir" | tee -a ${LOG}
echo "temp_indexdir=$temp_indexdir" | tee -a ${LOG}
echo "old_indexdir=$old_indexdir" | tee -a ${LOG}
echo "" | tee -a ${LOG}
echo "embossdb=$embossdb" | tee -a ${LOG}
echo "embossfileformat=$refseq_embossfileformat" | tee -a ${LOG}
echo "embossconfig=$embossconfig" | tee -a ${LOG}
echo "" | tee -a ${LOG}

echo "LOG=$LOG" | tee -a ${LOG}
echo "last_updatefile=$last_updatefile" | tee -a ${LOG}
echo "perlpath=$perlpath" | tee -a ${LOG}
echo "zcatprog=$zcatprog" | tee -a ${LOG}
echo "dbflat=$dbflat" | tee -a ${LOG}
echo "------------------------" | tee -a ${LOG}
echo "" | tee -a ${LOG}

date | tee -a ${LOG}
echo "running $scriptdir/processRefSeq.sh" | tee -a ${LOG}
$scriptdir/processRefSeq.sh

#
#To Do
# Check the logs for errors
# If error:
# 1) restore flatfiles
# 2) restore indexes.
#
date | tee -a ${LOG}
echo "Calling " $refSeqDiffs | tee -a ${LOG}
$refSeqDiffs rna >& $logdir/refseqDiffs.sh.log

date | tee -a ${LOG}
echo "${SCRIPT_NAME} completed successfully " | tee -a ${LOG}
date | tee -a ${LOG}

exit 0
