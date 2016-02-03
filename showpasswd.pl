#!/usr/local/bin/perl

use IO::File;
use BerkeleyDB;

  tie %pass, 'BerkeleyDB::Hash' ,
            -Filename   => '/etc/mail/passwd.db',
            -Flags      => DB_CREATE,
            -Mode       => 0444
       or die "Couldn't open passwd.db";

    while (($key, $val) = each %pass) { 
      print "$key $val\n";
    }

    untie %pass ;
