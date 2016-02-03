#!/usr/local/bin/perl

if($#ARGV ne 0)
{
    print "\nusage:   showpasswd.pl <Date> \nExample: showpasswd.pl 20040228\n\n
\n";
    exit;
}

$file="\/etc\/mail\/backup\/$ARGV[0].passwd";
#$file="\/etc\/mail\/passwd.db";
print "\nFile Name = $file\n";

use IO::File;
use BerkeleyDB;

  tie %pass, 'BerkeleyDB::Hash' ,
            -Filename   => $file,
            -Flags      => DB_CREATE,
            -Mode       => 0644
       or die "Couldn't open passwd.ebt";

$acc_num=keys %pass;
#$passwd_num=values %pass;
print "\n\n\Total User = $acc_num\n";
#    while (($key, $val) = each %pass) {
#      print "$key $val\n";
#    }

    untie %pass ;

