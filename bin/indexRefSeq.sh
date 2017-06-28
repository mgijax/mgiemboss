#!/bin/sh
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
LOG_DIR=$logdir
#set this just for checking if update is needed 
embossdb=refseqRna
logfile=$embossdb$moddate_prefix.log
last_updatefile=${LOG_DIR}/$logfile

LOG=${LOG_DIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}
echo "Running $0" | tee -a  ${LOG}

date | tee -a ${LOG}
sourcedir=$refseq_sourcedir
embossdbdir=$refseq_dbbasedir
temp_dir=$embossdbdir/temp

echo "" | tee -a ${LOG}
echo "Global variables setting" | tee -a ${LOG}
echo "------------------------" | tee -a ${LOG}
echo "sourcedir=$sourcedir" | tee -a ${LOG}
echo "rna_file=$refseq_rna_file" | tee -a ${LOG}
echo "protein_file=$refseq_protein_file" | tee -a ${LOG}
echo "zcatprog=$zcatprog" | tee -a ${LOG}
echo "temp_dir=$temp_dir" | tee -a ${LOG}

export temp_dir sourcedir zcatprog REMOTE_FILES
export refseq_rna_file refseq_protein_file
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
#release_number_file=$sourcedir/RELEASE_NUMBER
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



