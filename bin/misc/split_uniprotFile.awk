#!/usr/bin/awk -f
#
# script to split a very large uniprot file
# into parts smaller than 2 GB each.
# number the output file names sequentially
#
# Usage: program input2splitFilename outputfilePrefix chunksize outputDir outputfileSufix
# example : split_uniprotFile.awk  /data/databases/sprot/temp/uniprot_sprot.dat sprot_test 1932735283 /data/databases/sprot_test flat
BEGIN {
  in_entry = 0
  tot_len = 0
  #default database name
  prefix = "sprot"
  #default chunk size is  1.5 GB
  chunksize=1610612736
  partno = 1
  filename="/data/databases/sprot/temp/sprot"
  outdir="/data/databases/sprot/temp"
  sufix="flat"
  blockStart="ID"
  blockEnd="//"
  if ( ARGC == 6 ){
        prefix=ARGV[2]
        chunksize=ARGV[3]
        filename=ARGV[1]
        outdir=ARGV[4]
        sufix=ARGV[5] 
  }
  while(getline < filename){
        outfile = sprintf("%s/%s%s.flat",outdir,prefix,partno)
        if ( ! in_entry ) {
           if (index($0, blockStart) == 1) {
               in_entry = 1
               tot_len += length($0)
               print $0 > outfile
           }
        }
        else {
             if ( index($0, blockEnd) == 1 ) {
                in_entry = 0
                tot_len += length($0)
                print $0 > outfile
                if ( tot_len >= chunksize ) {
                     tot_len = 0
                     partno++
                 }
             }
            else {
                 tot_len += length($0)
                 print $0 > outfile
             }
        }
   }
}
