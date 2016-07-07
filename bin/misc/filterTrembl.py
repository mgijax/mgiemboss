#!/usr/bin/env python

#
# This script filters TrEMBL dataset to only include data for homology organisms
# The script is ran after split_uniprotFile.awk
#
# Input: a directory containing trembl flat files (*.flat)
# Output: trembl flat files that only include homologene organisms
# 
# Data blocks in the input files are delimitted by "//"
#
# Usage: ./filterTrembl.py tremblDir_path taxonomy_file
#

import sys
import os
import shutil
import string  
import re

def writeBlock(block,ids,filed,token):
  rows=""
  istargetblock=0
  txidCount=0
  for row in block:
      rows+=row
      if token in row:
         taxonids=[]
         for m in re.finditer("\d+",row): 
             taxonids.append(m.group(0))
         #get the id of the first taxon
         taxon_id= taxonids[0]
         if taxon_id in taxons:
            istargetblock=1
            txidCount+=1
            if taxon_id in ids:
               ids[taxon_id]+=1
            else:
               ids[taxon_id]=1
         else:
             break
  if istargetblock==1:
     filed.write(rows)
     filed.write("//\n")
  return txidCount 

# show usage
usage="*************\n\nUsage: ./filterTrembl.py tremblDir_path /data/databases/taxonomy.txt\n"
usage+="Where tremblDir_path is a directory name storing the flat files generated from \n"
usage+="split_uniprotFile.awk  script.The file taxonomy.txt is the file containing taxonomy ids \n"
if len(sys.argv)<3:
   print usage
   sys.exit(1)

#check if flat files data directory exists
trembl_dirname=sys.argv[1]
trembl_dirname.rstrip("/")
temp_dir=trembl_dirname+"/temp"
oldtemp_dir=trembl_dirname+"/temp/old"
taxon_file=sys.argv[2]
if not os.path.isdir(trembl_dirname):
   print trembl_dirname+" is not a directory"
   print usage
   sys.exit(1)  

if not os.path.isfile(taxon_file):
   print taxon_file+" is not a file"
   print usage
   sys.exit(1)

#create temp directory if needed
if not os.path.exists(temp_dir):
       os.makedirs(temp_dir)

#create old temp directory if needed
if not os.path.exists(oldtemp_dir):
       os.makedirs(oldtemp_dir)

#load taxon ids into a map- taxon_id is the key
taxons={}
for taxon in open(taxon_file):
    taxon= taxon.rstrip('\n')
    fields= taxon.split("=")
    if len(fields)==2:
       key=fields[1]
       taxons[key]=fields[0]

#Process files under trembl
ids={}
token="NCBI_TaxID="
notIndexedfh= open(trembl_dirname+"/file_skipped.txt","w" )
indexedfh= open(trembl_dirname+"/file_indexed.txt","w")
indexedfh.write("File\tTotalIDs\tTotalIdsIndexedCount\ttaxon_indexed\ttaxon_idsCount\n")
#process flat files one at the time
for flatfile in os.listdir(trembl_dirname):
    if os.path.isfile(trembl_dirname+"/"+flatfile):
       print "Processing",flatfile 
       fileh=open(trembl_dirname+"/"+flatfile)
       filteredh=open(temp_dir+"/"+flatfile,'w')
       idCount=0
       taxidCount=0
       block=[]
       for line in  fileh:
           if line.startswith('//'):
              #process previous block if not empty
              taxidCount+=writeBlock(block,ids,filteredh,token)
              block=[]
              idCount+=1
           else:
              block.append(line)
       fileh.close()
       if taxidCount==0:
          # generate a log - remove temp file,move trembl/file to temp/old_dir
          data=flatfile+"\t%s\n"% (idCount) 
          notIndexedfh.write(data)
          os.remove(temp_dir+"/"+flatfile)
          if os.path.isfile(oldtemp_dir+"/"+flatfile):
              os.remove(oldtemp_dir+"/"+flatfile)
          shutil.move(trembl_dirname+"/"+flatfile,oldtemp_dir)
       else:
           # generate a log - move the trembl/file to old
           for key,value in ids.iteritems():
               data=flatfile+"\t%s\t%s\t%s\t%s\n" % (idCount,taxidCount,key,value)
               indexedfh.write(data)
           if os.path.isfile(oldtemp_dir+"/"+flatfile):
              os.remove(oldtemp_dir+"/"+flatfile)
           shutil.move(trembl_dirname+"/"+flatfile,oldtemp_dir)
           shutil.move(temp_dir+"/"+flatfile,trembl_dirname)
#zip the the old directory
print "Program Complete Successfully"
notIndexedfh.close()
indexedfh.close()
