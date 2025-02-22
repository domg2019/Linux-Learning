#!/usr/bin/perl
##########################################################################
#
#  .Das Script RESEND_TOO_MUCH wird alle Dateien vom comexp_too_much
#  Verzeichnis mit einem Zeitinterval
#  in comexp_ok schicken, damit die nachgesendet werden.
#
# Perl is used due to performance reasons
#
##########################################################################
# $Revision:: 14527                                                      $
# $LastChangedDate:: 2011-08-01 11:50:04 +0200 (Mo, 01 Aug 2011)         $
# $Author:: oliver.rogowski                                              $
##########################################################################

#use strict;
require("/app/sword/schenker/framework/Schenker.pm");

# import all environment variables with same name as on shell level
#use lib "/app/xib/ext/schenker/toolslocal/technology/lib/lib/site_perl";
#use Env::Sourced qw(/app/xib/home/xib/.profile);
#use Env;
#Env::import();
checkMyselfRunning();
#check_maint();
use Time::HiRes;
use File::Copy;
use File::Path;
use File::stat;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $log = "/app/sword/log/too_much.log";
my $time=localtime();
my $archivedir="/app/sword/schenker/data/archive/comexp_too_much/$mday";
my $archive_base_dir="/app/sword/schenker/data/archive/comexp_too_much/";
my @archivedirs_todelete=<${archive_base_dir}*>;
my @comsenarray;
my $comsysdir;
my $name;
my $DIR;
my $comexp_ok;
my $agreement;
my $agr_dir;
my @remainingfiles;
my @files;

#create archivedir if not yet created
check_dir ("$archivedir");

#delete all archives but the current day
foreach (@archivedirs_todelete) {
  unless ($_ eq $archivedir) {
    rmtree($_);
    }
  }

open(LOGFILE, ">>$log");
print LOGFILE "START--------------------------------------$time-------------------------------------------\n" ;

#define array with all comsys instances by directories on hard disk "<>"= globbing operator
chomp(@comsenarray=</app/sword/schenker/comsys/COMS*/>);

if ($#comsenarray == -1) {die "no comsys installed on this machine: $!\n"};

#loop thru all comsys instances
NOCHMAL: foreach(@comsenarray) {
  $comsysdir = "$_"."comexp_too_much/";
  $comexp_ok = "$_"."comexp_ok/";
  $agr_dir   = "$_"."agr/";
  if (-d "$comsysdir") {
     #open comsysdir and read all entries/files
     opendir(DIR, "$comsysdir") or die "cannot open DIR $DIR - $!\n";
     @files = sort {(stat $a)[10] <=> (stat $b)[10]} readdir(DIR);
#print content of array for debugging
         #{local $,='| ';print @files}
         while($name = shift(@files)){
        #skip if the entry is "." or ".."
        next if $name=~ m/^(\.|\.\.)/;
            ($agreement = $name) =~ s/^(.*?)\.(.*)/$1/;
        #copy all files to archivedir first
        copy("${comsysdir}${name}","$archivedir");
        move("${comsysdir}${name}","${comexp_ok}${name}");
        $time=localtime();
        print LOGFILE "$time - Moved ${name} to ${comexp_ok} \n";
        Time::HiRes::sleep(0.1);
        #check if still files for this agreement in the pipeline and for an existing too_much.flg in agr dir if none there delete flg
        chomp(@remainingfiles=<${comsysdir}${agreement}*>);
        if (-e "${agr_dir}${agreement}/too_much.flg" && $#remainingfiles == -1) {
          unlink ("${agr_dir}${agreement}/too_much.flg");
          $time=localtime();
          print LOGFILE "$time - Deleted ${agr_dir}${agreement}/too_much.flg \n";
        }
     } # end while
     closedir(DIR);
  }
  # if there are new files in the too_much dir that were not part of the former arglist, just begin from start
  # (jump to redo label "NOCHMAL" until all are gone
  if ($#remainingfiles != -1){
    $time=localtime();
    sleep(1);
    print LOGFILE "$time - ${agr_dir}${agreement} - Reloaded file list in too_much directory, because a transfer still generates too much files. Slept for 1 second!  \n";
    redo NOCHMAL;
  }
}
$time=localtime();
print LOGFILE "END----------------------------------------$time-------------------------------------------\n" ;
close(LOGFILE);

#print array with delimiter
#{local $,='| ';print @files}