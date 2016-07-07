#!/bin/sh
#
#
# This script gets the compressed file
# from /data/downloads/ensembl_mus_cdna 
# or /data/downloads/ensembl_mus_protein
# or /data/downloads/ensembl_mus_ncrna
# or /data/downloads/vega_mus_ncrna
# or /data/downloads/vega_mus_cdna
# or /data/downloads/vega_mus_protein
#
# untars,and generates emboss indexes 
#
# Assumption:
# 1. ensembl cdna file name has the format: Mus_musculus.$current_mouse.cdna.all.fa.gz
# 2. ensembl ncrna file name has the format: Mus_musculus.$current_mouse.ncrna.fa.gz
# 3. ensembl protein file name has the format: Mus_musculus.$current_mouse.pep.all.fa.gz
# 4. VEGA cdna file name has the format: Mus_musculus.VEGA$release.cdna.all.fa.gz
# 5. VEGA ncrna file name has the format: Mus_musculus.VEGA$release.ncrna.fa.gz
# 6. VEGA protein file name has the format: Mus_musculus.VEGA$release.pep.all.fa.gz
#
# This script is called by the update[Ensembl|Vega]_* scripts
#
cd `dirname $0`; 

release=""
rdate=`date +%D`
relID=0
need_update=0

## To remove the version number from the accessiopn in the sequence header
#
PERL=`which perl`
zcatprog=`which zcat`

run_format_header="$PERL $format_header"
SCRIPT_NAME=`basename $0`

date | tee -a ${LOG}
echo "Starting $SCRIPT_NAME  -release date: $rdate" | tee -a ${LOG}
echo "Remote Files under $sourcedir/" | tee -a ${LOG}
echo "Local files under: $embossdbdir "
echo "Index Directory: $embossdbindexdir "
echo "Temp file(s): $temp_file "
echo "Emboss file: $embossfile "
echo "Emboss database: $embossdb "
echo "Emboss data format: $embossfileformat "
echo "File prefix: $filePrefix "
echo "File Sufix:  $fileSufix "
echo "Temp directory: $temp_dir"
echo "Old dir: $old_dir"
echo "Index temp dir: $temp_indexdir "
echo "emboss log: $dblogfile"
echo "last_updatefile $last_updatefile "
echo "Emboss config update script: $updateConfigScript "
echo "script to format seq headr: $format_header "

#
date | tee -a ${LOG}
#get last emboss db update date for this dataset 
need_update=0
if [ -f $last_updatefile ]
then 
  last_update=`cat $last_updatefile`
else
  touch $last_updatefile
fi
release=$target_release
#
# set up dir structure 
#
date | tee -a ${LOG}
echo "Last time this dataset was updated was $last_update "
echo 'Setting up directory structure' | tee -a ${LOG}
#
# set up dir structure 
#
if [ ! -d $old_dir ]
then
   mkdir  $old_dir
else
   rm -f $old_dir/*
fi

if [ ! -d $temp_dir ]
then
    echo "Creating $temp_dir"
    mkdir  $temp_dir
else
    if ! find $temp_dir -maxdepth 0 -empty | read
    then
         if [ "$temp_dir" != "/" ]
         then  
            echo "Removing temp files"
            rm $temp_dir/*
          fi
    fi
fi
#now loop throug the file list
#setup the file to download from soruce
for filepath  in $temp_file
do
   filename=`basename "$filepath"`
   sourcefilename=$filepath.gz
   echo "Checking if $sourcefilename is being edited " | tee -a ${LOG}
   openfile=`lsof | grep $sourcefilename`
   if [ "$openfile" != "" ]
   then
      echo "Can't update $sourcefilename is being edited by another process, check  :  $openfile" | tee -a ${LOG}
      exit =1
   fi
   date | tee -a ${LOG}
   echo "Unzipping source file $sourcefilename" | tee -a ${LOG}
   echo "Cammand: $zcatprog $sourcefilename > $temp_dir/$filename"
   $zcatprog $sourcefilename > $temp_dir/$filename
   #Check if the file exist and check the size
   date | tee -a ${LOG}
   if [ -f $temp_dir/$filename ]
   then
        echo "File unzipped successfully" | tee -a ${LOG} 
        ##reformat the header lines
        echo "Reformat sequence header line " | tee -a ${LOG}
        echo "$run_format_header $temp_dir/$filename" 
        $run_format_header $temp_dir/$filename 
   else
        echo "zcat file failed - $zcatprog $sourcefilename > $temp_dir/$filename" | tee -a ${LOG}
        exit 1
   fi
done
#Now I need to generate indexes
echo "Indexing $embossdb release $release" | tee -a $LOG
if [ ! -d $embossdbindexdir ]
then
   mkdir  $embossdbindexdir
fi

if [ ! -d $embossdbindexdir/old ]
then
   mkdir  $embossdbindexdir/old
else
   rm -f $embossdbindexdir/old/*
fi

if [ ! -d $temp_indexdir ]
then
   mkdir  $temp_indexdir
else
   rm -f $temp_indexdir/*
fi
# archive old indexes and data files
#
mv $embossdbdir/$embossfile $old_dir
mv $temp_dir/* $embossdbdir/
mv $embossdbindexdir/*.* $embossdbindexdir/old/

echo $dbfasta -dbname="$embossdb" -idformat="$embossfileformat" -directory="$embossdbdir" -filenames="$embossfile" -release=$release -date=$rdate -outfile="${LOG_DIR}/$dblogfile" -indexoutdir="$temp_indexdir" | tee -a $LOG

$dbfasta -dbname="$embossdb" -idformat="$embossfileformat" -directory="$embossdbdir" -filenames="$embossfile" -release=$release -date=$rdate -outfile="${LOG_DIR}/$dblogfile" -indexoutdir="$temp_indexdir" 

mv $temp_indexdir/*.* $embossdbindexdir
#
# Check if the indexes were generated
#
date | tee -a ${LOG}
#update the config file with new release
$PERL $updateConfigScript $embossdb $release $embossconfig
#update release flag
echo "$release" > $last_updatefile

echo "${SCRIPT_NAME} completed - check the logs : $LOG" | tee -a ${LOG}
date | tee -a ${LOG}

exit 0


