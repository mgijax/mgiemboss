#!/bin/sh
#
# This script is a wrapper that sets
# RefsSeq rna  configuration variables 
# before calling the script that
# generates emboss indexes 
#
cd `dirname $0`; . ../Configuration
is_rna=1

refseq_sourcedir=$remotedatadir/refseq/complete
refseq_filePrefix=complete
refseq_dbbasedir=$dbdir/refseq
refseq_flatfiles_basedir=$refseq_dbbasedir/flatfiles
refseq_update_script=$scriptdir/processRefSeq.sh
refseq_embossfileformat=GB

release_file=$refseq_release_file

updateScript=$refseq_update_script

#where the flatfiles and indexes are located on the EMBOSS server
embossdbdir=$dbdir/refseq
flatfiles_dir=$embossdbdir/flatfiles
temp_dir=$embossdbdir/temp
old_dir=$embossdbdir/flatfiles.old
embossdbindexdir=$embossdbdir/refseqRnaIdx
temp_indexdir=$embossdbindexdir/tempIdx
old_indexdir=$embossdbindexdir/old

export is_rna updateConfigScript flatfiles_dir 
export embossdbdir temp_dir old_dir embossdbindexdir temp_indexdir
export old_indexdir release_file

#Where to get the files on hobbiton 
sourcedir=$refseq_sourcedir

# configuration specific to emboss tool
embossdb=refseqRna
filePrefix=$refseq_filePrefix
fileSufix=rna.gbff
embossfile=$filePrefix*.$fileSufix
embossfileformat=$refseq_embossfileformat

db_basedir=$embossdbdir

export sourcedir embossdb embossfile filePrefix fileSufix
export embossfileformat db_basedir

SCRIPT_NAME=`basename $0`
dblogfile=$embossdb.log
LOG_DIR=$logdir
logfile=$embossdb$moddate_prefix.log
last_updatefile=${LOG_DIR}/$logfile

LOG=${LOG_DIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}
echo "Running $0" | tee -a ${LOG}
echo "" | tee -a ${LOG}
date | tee -a ${LOG}
echo "" | tee -a ${LOG}
echo "Global variables setting" | tee -a ${LOG}
echo "------------------------" | tee -a ${LOG}
echo "is_rna=$is_rna" | tee -a ${LOG}
echo "updateConfigScript=$updateConfigScript" | tee -a ${LOG}
echo "embossdbdir=$embossdbdir" | tee -a ${LOG}
echo "flatfiles_dir=$flatfiles_dir" | tee -a ${LOG}
echo "temp_dir=$temp_dir" | tee -a ${LOG}
echo "old_dir=$old_dir" | tee -a ${LOG}
echo "embossdbindexdir=$embossdbindexdir" | tee -a ${LOG}
echo "temp_indexdir=$temp_indexdir" | tee -a ${LOG}
echo "old_indexdir=$old_indexdir" | tee -a ${LOG}
echo "sourcedir=$sourcedir" | tee -a ${LOG}
echo "" | tee -a ${LOG}
echo "embossdb=$embossdb" | tee -a ${LOG}
echo "embossfile=$embossfile" | tee -a ${LOG}
echo "filePrefix=$filePrefix" | tee -a ${LOG}
echo "fileSufix=$fileSufix" | tee -a ${LOG}
echo "db_basedir=$db_basedir" | tee -a ${LOG}
echo "embossfileformat=$embossfileformat" | tee -a ${LOG}
echo "embossconfig=$embossconfig" | tee -a ${LOG}
echo "" | tee -a ${LOG}

export LOG last_updatefile LOG_DIR dblogfile
export perlpath dbflat dbfasta embossconfig 
export scriptdir

echo "LOG=$LOG" | tee -a ${LOG}
echo "last_updatefile=$last_updatefile" | tee -a ${LOG}
echo "LOG_DIR=$LOG_DIR" | tee -a ${LOG}
echo "perlpath=$perlpath" | tee -a ${LOG}
echo "zcatprog=$zcatprog" | tee -a ${LOG}
echo "dbflat=$dbflat" | tee -a ${LOG}
echo "scriptdir=$scriptdir" | tee -a ${LOG}
echo "------------------------" | tee -a ${LOG}
echo "" | tee -a ${LOG}
date | tee -a ${LOG}
$updateScript
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



