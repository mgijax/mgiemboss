#!/bin/sh
#
# This script is a wrapper that sets
# Genbank  configuration variables 
# before calling the script that
# generates emboss indexes 
#
# lnh: 12/2014
#
cd `dirname $0`; . ../Configuration

zgrep=`which zgrep`

updateScript=$scriptdir/processGenbank.sh
updateConfigScript=$scriptdir/misc/updateEmbossConfig.pl
# configuration specific to emboss tool
genbank_embossdbtype=N
embossdb=genbank
fileSufix=seq
filePrefix=gb
#genbank_embossdbdir=$dbdir/$genbank_embossdb/flatfiles
embossdbmaindir=$dbdir/$embossdb
embossdbindexdir=$embossdbmaindir/indexes
embossfile=$filePrefix*.$fileSufix
embossfileformat=GB

genbank_embossmethod=emblcd
genbank_embossfields=""
genbank_embosscomment=" GenBank in native format with EMBL index"
genbank_release_label="NCBI-GenBank Flat File Release"
db_basedir=$dbdir/$embossdb


#where the flatfiles are located
embossdbdir=$dbdir/$embossdb/flatfiles
flatfiles_dir=$embossdbdir
temp_dir=$embossdbdir/temp

sourcedir=$remotedatadir/ftp.ncbi.nih.gov/genbank
sourcefilename=seq.gz
dblogfile=$embossdb.log
old_dir=$embossdbdir/old
temp_indexdir=$embossdbindexdir/temp
old_indexdir=$embossdbindexdir/old

SCRIPT_NAME=`basename $0`
LOG_DIR=$logdir
logfile=$embossdb$moddate_prefix.log
last_updatefile=${LOG_DIR}/$logfile

LOG=${LOG_DIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}
echo "$0" | tee -a  ${LOG}
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
echo "zgrepPath=$zgrep" | tee -a ${LOG}
echo "======================" | tee -a ${LOG}
#check if this is a Sunday 
#if [ `date '+%u'` != "0" ] 
#   then
#        echo "Today is not an update day . It is day: " `date '+%u'` "of the week" | tee -a ${LOG}
#        echo "Stop Time: `date`" | tee -a ${LOG}
#        exit
#fi
#get the release number 
echo "get the release number" | tee -a ${LOG} 
release=""
files=(`ls $sourcedir/$filePrefix*.seq.gz`)
file=${files[0]}

echo "Getting Release number from  $file " | tee -a ${LOG}
release=`$zgrep "$genbank_release_label" $file | sed s/"$genbank_release_label"//g`
release=`echo $release | sed s/\s+//g`
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

echo "Indexing genbank release number: $release"
export LOG last_updatefile LOG_DIR embossdbindexdir embossfileformat
export embossdb dblogfile fileSufix chunkSize filePrefix embossfile
export perlpath sourcefilename sourcedir temp_file temp_dir old_dir embossdbdir
export splitScript updateScript zcatprog dbflat embossconfig updateConfigScript
export temp_indexdir release db_basedir scriptdir old_indexdir

date | tee -a ${LOG}
echo "Copying files from hobbiton - Calling " $zcatGBScript | tee -a ${LOG}
$zcatGBScript | tee -a ${LOG}

date | tee -a ${LOG}
echo "Indexing new data - Calling " $updateScript | tee -a ${LOG}
$updateScript
#
#To Do
# Check the logs for errors
# If error:
# 1) restore flatfiles
# 2) restore indexes.
#

exit 0
date | tee -a ${LOG}
echo "Checking if the run was successfully - Calling " $genbankDiffs | tee -a ${LOG}
$genbankDiffs rna >& $logdir/genbankDiffs.sh.log

date | tee -a ${LOG}
echo "${SCRIPT_NAME} complete - Check the logs ${LOG} " | tee -a ${LOG}
date | tee -a ${LOG}

exit 0



