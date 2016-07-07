#!/usr/bin/python

import os
import string

#
# compare RefSeq RNA accIDs:
# new not in old
# old not in new
#

dataSet = os.environ["DATA_SET"].upper()

if dataSet == "RNA":
    oldFile = os.environ['OLD_RNA_SEQID_FILE']
    newFile = os.environ['NEW_RNA_SEQID_FILE']
    inOldFile = os.environ['RNA_IN_OLD_DIFF_RPT']
    inNewFile = os.environ['RNA_IN_NEW_DIFF_RPT']
    database = 'refseqRna'
elif dataSet == "PROT":
    oldFile = os.environ['OLD_PROT_SEQID_FILE']
    newFile = os.environ['NEW_PROT_SEQID_FILE']
    inOldFile = os.environ['PROT_IN_OLD_DIFF_RPT']
    inNewFile = os.environ['PROT_IN_NEW_DIFF_RPT']
    database = 'refseqProt'
else:
    exit( 'unsupported sequence type')
fpOld = open(oldFile, 'r')
fpNew = open(newFile, 'r')
fpInOldRpt = open (inOldFile, 'w')
fpInNewRpt = open (inNewFile, 'w')

oldList = []
newList = []
inOldNotNewList = []
inNewNotOldList = []

for accID in fpOld.readlines():
    oldList.append(accID)
for accID in fpNew.readlines():
    newList.append(accID)

print 'determining inOldNotNewList'
inOldNotNewList = set(oldList).difference(set(newList))

print 'determining inNewNotOldList'
inNewNotOldList = set(newList).difference(set(oldList))

print 'writing report'
fpInOldRpt.write('RefSeq IDs in Last Release Processed, but not in Current Release\n'
)
fpInOldRpt.write('----------------------------------------------------------------------\n')
    
for a in inOldNotNewList:
    fpInOldRpt.write(a)
fpInOldRpt.write('Total: %s\n' % len(inOldNotNewList) )

fpInNewRpt.write('RefSeq IDs in Current Release Processed, but not in Last Release\n')
fpInNewRpt.write('----------------------------------------------------------------------\n')

for a in inNewNotOldList:
    fpInNewRpt.write(a)
fpInNewRpt.write('Total: %s' % len(inNewNotOldList))

fpNew.close()
fpNew.close()
fpInOldRpt.close()
fpInNewRpt.close()

########
fp = open(inNewFile, 'r')
header = fp.readline()
header = fp.readline()
ct = 1
while ct <= 10:
    id = fp.readline().strip()
    print 'Checking EMBOSS database for %s' % id
    cmd="/usr/local/bin/infoseq -only -accession -nohead -auto -sequence=%s:%s" % (database, id)
    exitCode = os.system(cmd)
    print 'exitcode: %s' % exitCode
    ct += 1
