#!/bin/sh
#
# This script is a wrapper that sets
# Ensembl Mus cdna  and ncrna configuration variables 
# before calling the script that
# generates emboss indexes 
#
# Input: Make sure you update the target_release viariable
#        with the right release number
#
cd `dirname $0`; . ../Configuration

updateScript=$scriptdir/processSanger.sh
target_release=84

# Configuration specific to source
embossdb=ensembl_mus_cdna
remotedb=ensembl_mus_cdna
ncrna_remotedb=ensembl_mus_ncrna
file_prefix=Mus_musculus
fileSufix=.cdna.all.fa
ncrna_fileSufix=.ncrna.fa
filePrefix=$file_prefix.$current_mouse

embossdbdir=$dbdir/$embossdb
embossdbindexdir=$embossdbdir/Indexes
embossfile=$file_prefix.*.fa

sourcedir=$remotedatadir/$remotedb
ncrna_sourcedir=$remotedatadir/$ncrna_remotedb
embossfileformat=simple

temp_file="$sourcedir/$filePrefix$fileSufix $ncrna_sourcedir/$filePrefix$ncrna_fileSufix"
temp_dir=$embossdbdir/temp
old_dir=$embossdbdir/old_flat_files
temp_indexdir=$embossdbindexdir/temp

SCRIPT_NAME=`basename $0`
LOG_DIR=$logdir
dblogfile=$embossdb.log
logfile=$embossdb$moddate_prefix.log
last_updatefile=${LOG_DIR}/$logfile

LOG=${LOG_DIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}
echo "$0" >> ${LOG}
export LOG last_updatefile LOG_DIR embossdbindexdir embossfileformat
export embossdb dblogfile fileSufix chunkSize filePrefix embossfile
export sourcedir ncrna_sourcedir temp_file temp_dir old_dir embossdbdir
export splitScript updateScript dbfasta embossconfig updateConfigScript
export format_header temp_indexdir target_release

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



