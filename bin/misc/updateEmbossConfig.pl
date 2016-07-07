#!/usr/bin/env perl

######################################
# This script updates the release id
# of a given database name
######################################
#use vars qw($opt_h $opt_r $opt_d);
#use GetOpt::Std;
#getopts('hr:d:');
if(@ARGV<3){
#if(($opt_h)||!($opt_r)||!($opt_d)){
   print <<HELP;
  
  Use this script to update the release id of a database in emboss config file

  Usage: perl updateEmbossConfig.pl  embossdbname dbreleaseid embossConfigfile
  Arguments:
   -h  displays this help message
   -d  required, emboss database name 
   -r  required, database release 
   -f  required, emboss configuration file

  Example: perl updateEmbossConfig.pl -d sprot -r 2014_05 -f /usr/local/share/EMBOSS/emboss.default.text

  The above will set the release of sprot database to "2014_05"
  run emboss command: showdb -Release  to test the update

 Note: Because some perl libraries are missing from hygelac, the GetOpt library,so we will not use 
 parameter options to run this program - this translate into having the command line as:
 >perl updateEmbossConfig.pl sprot  2014_05 /usr/local/share/EMBOSS/emboss.default

HELP
exit; 
}
$db=$ARGV[0];$release=$ARGV[1];
$config_file=$ARGV[2];
$temp_file="$config_file.temp";
$backup_file="$config_file.back";
if(-f $config_file){
   `cp $config_file $backup_file`; open(IN,"$config_file");
   if(!IN){
      print "Failed to update $db release to $release - Could not open $config_file - $!\n";exit;
   }
   else{
      open(OUT,">$temp_file");
      if(!OUT){print "Could not open $config_file - $!\n";exit; } 
      while($line=<IN>){
         if($line=~/^\s*DB\s+$db\s+\[/){ print OUT $line;$update=1;
            while($update){
                  $line=<IN>;if($line=~/release:\s*(.+)$/){$line=~s/$1/$release/;}
                  print OUT $line; $update=0 if($line=~/\]\s*$/);
            }
         }else{print OUT $line;} 
      }
  }
 system("mv $temp_file $config_file");
}
