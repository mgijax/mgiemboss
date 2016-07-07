#!/usr/bin/python

import os
import string

#
# compare GenBank accIDs:
# new not in old
# old not in new
#

oldFile = os.environ['OLD_SEQID_FILE']
newFile = os.environ['NEW_SEQID_FILE']
inOldFile = os.environ['IN_OLD_DIFF_RPT']
inNewFile = os.environ['IN_NEW_DIFF_RPT']
database = 'genbank'
fpOld = open(oldFile, 'r')
fpNew = open(newFile, 'r')
fpInOldRpt = open (inOldFile, 'w')
fpInNewRpt = open (inNewFile, 'w')

oldList = []
newList = []
inOldNotNewList = []
inNewNotOldList = []

#
# readlines and readline crap out trying to process these files
# so let's do just 2mil
#
accID = fpOld.readline()
ctr = 0
while ctr <= 2000000:
    oldList.append(accID)
    accID = fpOld.readline()
    ctr += 1

accID =fpNew.readline()
ctr = 0
while ctr <= 2000000:
    newList.append(accID)
    accID = fpNew.readline()
    ctr += 1

print 'determining inOldNotNewList'
inOldNotNewList = set(oldList).difference(set(newList))

print 'determining inNewNotOldList'
inNewNotOldList = set(newList).difference(set(oldList))

print 'writing report'
fpInOldRpt.write('GenBank IDs in Last Release Processed, but not in Current Release from first 2mil IDs\n'
)
fpInOldRpt.write('----------------------------------------------------------------------\n')
    
for a in inOldNotNewList:
    fpInOldRpt.write(a)
fpInOldRpt.write('Total: %s\n' % len(inOldNotNewList) )

fpInNewRpt.write('GenBank IDs in Current Release Processed, but not in Last Release from first 2mil IDs\n')
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
id =  fp.readline().strip()
ct = 1
while id and ct <= 10:
    print 'Checking EMBOSS database for %s' % id
    cmd="/usr/local/bin/infoseq -only -accession -nohead -auto -sequence=%s:%s" % (database, id)
    exitCode = os.system(cmd)
    print 'exitcode: %s' % exitCode
    ct += 1
    id =  fp.readline().strip()
