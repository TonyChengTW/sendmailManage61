#!/bin/perl
#-----------------------
# Version : 2004042201
# Writer  : Mico Cheng
# Use for : deleting mash files
# Host    : x
#-----------------------

$deldir = $ARGV[0];

if ( $#ARGV != 0 ) {
    print "\nUsage: del_mash_file.pl /path_to_the_dir\n\n";
    exit;
}

opendir DELDIR,"$deldir" or die "can't not find $deldir:$!\n";

foreach (readdir DELDIR) {
     next if $_ =~ /^\..*/;
     unlink "$_" or die "can't delete $_:$!\n";
     print "deleting $_\n";
     $count++;
}
print "Done!\n";
print "Tatal : $count\n";
