# mgiemboss

```bash 
 #####################################
 
  Author :lnh - 04/2015
  Modified: 06/2017
#####################################
#
# emboss admin doc : http://emboss.sourceforge.net/docs/adminguide/node19.html
# dbxflat doc: http://emboss.sourceforge.net/apps/cvs/emboss/apps/dbxflat.html
# dbiflat doc: http://emboss.sourceforge.net/apps/cvs/emboss/apps/dbiflat.html
#
# MGI EMBOSS server: bhmgiem01.jax.org
# Server alias : mgiprodemboss.jax.org
#
```
This product stores all the scripts and configuration files needed to index Sequence datasets into EMBOSS 

## Contents
- [Prerequisites](#prerequisites)
- [Installing](#installing)
- [Documentation](#documentation)
- [Configuration](#configuration)
- [Related TRs](#related-trs)
- [Disk Space](#disk-space-usage)

## Prerequisites 
Before running an index script for a given sequence dataset, check the following first:

 1. The path to the sequence data is as defined in the dataset configuration file
 2. The individual sequence file name format is as defined in the dataset Configuration file
 3. Access/pathto Dataset realease version if applicable is as defined in the Configuration/update script 
   
If any of the above has changed, update the Configuration/update scripts as needed. 

### Directories and files

 * mgiemboss/Configuration.default  -- main configuration file for emboss datasets global configuration
 * mgiemboss/taxonomy.txt - used by indexTrembl.sh  to only index sequences of organisms included in the taxonomy file
  this file was used to filter Trembl dataset - not needed anymore since Trembl reduced their dataset
 * mgiemboss/Install   
 * mgiemboss/bin/      -- stores scripts  to run specific updates 
 ```bash
    cleanSoaplabTempfiles.sh  
    
    configRefSeq_prot.sh	  
    configRefSeq_rna.sh	  
    
    indexRefSeq.sh		
    indexGenbank.sh	
    
    indexSprot.sh	
    indexTrEMBL.sh
   
    indexEnsemblMus_cdna.sh
    indexEnsemblMus_prot.sh
    
   processGenbank.sh
   processRefSeq.sh
   processSanger.sh
   processUniprotdb.sh
```
 * mgiemboss/misc 
 
## Installing
The product mgiemboss should be installed on the emboss server(mgiprodemboss)
under /data/databases/

## Documentation:
http://mgiwiki/mediawiki/index.php/sw:Emboss

## Configuration 

EMBOSS updates are scheduled on the production instance of Jenkins.

* See EMBOSS Updates On Jenkins: [http://bhmgiem01.jax.org:10080/job/EMBOSS-DATASETS-Update/]

### Weekly and monthly crons

1. indexGenbank.sh          - to run genbank Release
2. indexTrembl.sh           - to run Trembl update
3. indexSprot.sh            - to run Swissprot update
4. indexRefseq.sh           - to run Refseq Release

### On demand

5. indexEnsemblMus_cdna.sh  - to run Ensembl cdna and ncrna
6. indexEnsemblMus_prot.sh  - to run Ensembl protein


## Related TRs:
* TR9685  - Update Seqfetch to access EMBOSS server
* TR11226 - MGI support of EMBOSS
* TR11327 - EMBOSS links for Genbank GSS sequences need the URL to use ACC ID
* TR11333 - Add chicken, zebrafish, and frog refseqs to Emboss
* TR11702 - Automate Emboss updates for major datasets
* TR11703 - Move Emboss from hygelac.jax.org to MGI server
* TR11824 - Some Uniprot TREMBL Sequences missing in Emboss
* TR11918 - Broken FASTA links

## Disk Space Usage

The server tends to run out of space quite often due to the size of some datasets - While waiting to implement 
a different solution, It's advisable to clean old files and indexes to free space after each successful run.


