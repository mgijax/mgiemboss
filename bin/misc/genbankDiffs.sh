#!/usr/bin/sh

USAGE="genbankDiffs.sh"

#
# set up the environment
#

# old and new index directories 
GENBANK_DIR=$db_basedir
NEW_INDEX_DIR=${GENBANK_DIR}/indexes
OLD_INDEX_DIR=${GENBANK_DIR}/indexes/old

export  GENBANK_DIR NEW_INDEX_DIR OLD_INDEX_DIR

# old and new accid files
SEQID_DIFFS_DIR=${GENBANK_DIR}/seqIdDiffs
NEW_SEQID_FILE=${SEQID_DIFFS_DIR}/allAccids.new
OLD_SEQID_FILE=${SEQID_DIFFS_DIR}/allAccids.old

export SEQID_DIFFS_DIR NEW_SEQID_FILE OLD_SEQID_FILE

# diff files
IN_NEW_DIFF_RPT=${SEQID_DIFFS_DIR}/inNewDiff.rpt
IN_OLD_DIFF_RPT=${SEQID_DIFFS_DIR}/inOldDiff.rpt

export IN_NEW_DIFF_RPT IN_OLD_DIFF_RPT

echo "Start: " `date`

echo "Getting accession ids from the the index files ..."
/usr/bin/strings ${NEW_INDEX_DIR}/acnum.trg > ${NEW_SEQID_FILE}
/usr/bin/strings ${OLD_INDEX_DIR}/acnum.trg > ${OLD_SEQID_FILE}

echo "Removing first two lines of accession id files ..."
/usr/bin/sed '1d' ${NEW_SEQID_FILE} > ${SEQID_DIFFS_DIR}/temp.out
/usr/bin/sed '1d'  ${SEQID_DIFFS_DIR}/temp.out > ${NEW_SEQID_FILE}
/bin/rm ${SEQID_DIFFS_DIR}/temp.out

/usr/bin/sed '1d' ${OLD_SEQID_FILE} > ${SEQID_DIFFS_DIR}/temp.out
/usr/bin/sed '1d'  ${SEQID_DIFFS_DIR}/temp.out > ${OLD_SEQID_FILE}
/bin/rm ${SEQID_DIFFS_DIR}/temp.out

echo "Running the diffs ..."	
$scriptdir/genbankDiffs.py

echo "Done running the diffs"

echo "End: " `date`
exit 0
