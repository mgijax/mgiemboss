#!/bin/sh
#
# indexRefSeq.sh
#
# This script is a wrapper that calls
# scripts to run refseq rna and refseq protein 
# datasets update
#
cd `dirname $0`; . ../Configuration

if [ ! -f $refseq_release_file ]
then
   echo "Dataset update failed - missing $release_file file"
   exit 1
fi

update_rna=$scriptdir/configRefSeq_rna.sh
update_prot=$scriptdir/configRefSeq_prot.sh
REMOTE_FILES="rna.gbff
genomic.gbff
protein.gpff"

SCRIPT_NAME=`basename $0`
#set this just for checking if update is needed 
embossdb=refseqRna
logfile=$embossdb$moddate_prefix.log
last_updatefile=$logdir/$logfile

LOG=$logdir/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}
echo "Running $0" | tee -a  ${LOG}

date | tee -a ${LOG}
embossdbdir=$refseq_dbbasedir
temp_dir=$embossdbdir/temp

echo "" | tee -a ${LOG}
echo "Global variables setting" | tee -a ${LOG}
echo "------------------------" | tee -a ${LOG}
echo "sourcedirs=$refseq_source_mammalian_dir $refseq_source_other_dir" | tee -a ${LOG}
echo ""
echo "zcatprog=$zcatprog" | tee -a ${LOG}
echo "temp_dir=$temp_dir" | tee -a ${LOG}

export embossdbdir temp_dir zcatprog REMOTE_FILES
echo "------------------------" | tee -a ${LOG}
echo "" | tee -a ${LOG}

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
echo "Checking if update needed " | tee -a ${LOG}
release=`cat $refseq_release_file`
if [ "$release" = "$last_update" ]
then
  echo "No update needed current release $release is in sync" |  tee -a ${LOG}
  echo "Program complete"
  exit
fi


echo "New release $release" |  tee -a ${LOG}
echo "Calling " $zcatRefSeqScript | tee -a ${LOG}
$zcatRefSeqScript | tee -a ${LOG}

date | tee -a ${LOG}
$update_rna  

date | tee -a ${LOG}
$update_prot

echo "${SCRIPT_NAME} completed successfully " | tee -a ${LOG}
date | tee -a ${LOG}

exit 0
