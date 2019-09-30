#!/usr/bin/sh

USAGE="refseqDiffs.sh [rna|prot]"

# 
# check script parameter
#
DATA_SET=$1
if [ "${DATA_SET}" = "" ]
then
    echo "Usage: ${USAGE}"
    exit 1
fi

export DATA_SET

#
# set up the environment
#

# old and new index directories 
REFSEQ_DIR=$embossdbdir
NEW_RNA_INDEX_DIR=${REFSEQ_DIR}/refseqRnaIdx
OLD_RNA_INDEX_DIR=${NEW_RNA_INDEX_DIR}/old
NEW_PROT_INDEX_DIR=${REFSEQ_DIR}/refseqProtIdx
OLD_PROT_INDEX_DIR=${NEW_PROT_INDEX_DIR}/old

export REFSEQ_DIR NEW_RNA_INDEX_DIR OLD_RNA_INDEX_DIR 
export NEW_PROT_INDEX_DIR OLD_PROT_INDEX_DIR

# old and new accid files
SEQID_DIFFS_DIR=${REFSEQ_DIR}/seqIdDiffs
NEW_RNA_SEQID_FILE=${SEQID_DIFFS_DIR}/allRNAaccids.new
OLD_RNA_SEQID_FILE=${SEQID_DIFFS_DIR}/allRNAaccids.old
NEW_PROT_SEQID_FILE=${SEQID_DIFFS_DIR}/allPROTaccids.new
OLD_PROT_SEQID_FILE=${SEQID_DIFFS_DIR}/allPROTaccids.old

export SEQID_DIFFS_DIR NEW_RNA_SEQID_FILE OLD_RNA_SEQID_FILE 
export NEW_PROT_SEQID_FILE OLD_PROT_SEQID_FILE

# diff files
RNA_IN_NEW_DIFF_RPT=${SEQID_DIFFS_DIR}/rnaInNewDiff.rpt
RNA_IN_OLD_DIFF_RPT=${SEQID_DIFFS_DIR}/rnaInOldDiff.rpt
PROT_IN_NEW_DIFF_RPT=${SEQID_DIFFS_DIR}/protInNewDiff.rpt
PROT_IN_OLD_DIFF_RPT=${SEQID_DIFFS_DIR}/protInOldDiff.rpt

export RNA_IN_NEW_DIFF_RPT RNA_IN_OLD_DIFF_RPT
export PROT_IN_NEW_DIFF_RPT PROT_IN_OLD_DIFF_RPT

echo "Getting accession ids from the the index files ..."
/usr/bin/strings ${NEW_RNA_INDEX_DIR}/acnum.trg > ${NEW_RNA_SEQID_FILE}
/usr/bin/strings ${OLD_RNA_INDEX_DIR}/acnum.trg > ${OLD_RNA_SEQID_FILE}
/usr/bin/strings ${NEW_PROT_INDEX_DIR}/acnum.trg > ${NEW_PROT_SEQID_FILE}
/usr/bin/strings ${OLD_PROT_INDEX_DIR}/acnum.trg > ${OLD_PROT_SEQID_FILE}

echo "Removing first two lines of accession id files ..."
/usr/bin/sed '1d' ${NEW_RNA_SEQID_FILE} > ${SEQID_DIFFS_DIR}/temp.out
/usr/bin/sed '1d'  ${SEQID_DIFFS_DIR}/temp.out > ${NEW_RNA_SEQID_FILE}
/bin/rm ${SEQID_DIFFS_DIR}/temp.out

/usr/bin/sed '1d' ${OLD_RNA_SEQID_FILE} > ${SEQID_DIFFS_DIR}/temp.out
/usr/bin/sed '1d'  ${SEQID_DIFFS_DIR}/temp.out > ${OLD_RNA_SEQID_FILE}
/bin/rm ${SEQID_DIFFS_DIR}/temp.out

/usr/bin/sed '1d' ${NEW_PROT_SEQID_FILE} > ${SEQID_DIFFS_DIR}/temp.out
/usr/bin/sed '1d'  ${SEQID_DIFFS_DIR}/temp.out > ${NEW_PROT_SEQID_FILE}
/bin/rm ${SEQID_DIFFS_DIR}/temp.out

/usr/bin/sed '1d' ${OLD_PROT_SEQID_FILE} > ${SEQID_DIFFS_DIR}/temp.out
/usr/bin/sed '1d'  ${SEQID_DIFFS_DIR}/temp.out > ${OLD_PROT_SEQID_FILE}
/bin/rm ${SEQID_DIFFS_DIR}/temp.out

echo "Running the diffs ..."	
$scriptdir/refseqDiffs.py

echo "Done running the diffs"
exit 0
