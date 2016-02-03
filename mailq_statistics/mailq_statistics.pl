#!/usr/bin/perl
#-----------------------
# Version : 2004051301
# Writer  : Mico Cheng
# Server  : 203.79.224.63
#-----------------------

if ($#ARGV != 1)
{
     print "\n".'usage:    mailq-statistics.pl'." '\x1b[4mRE\x1b[m'"." '\x1b[4mACTION\x1b[m'"."\n";
     print "\n".'example:  mailq-statistics.pl \'reason=.*timed.*mx.pchome.com.tw\''." kill\n";
     print "\n\"ACTION\" must be matched with (kill|besize|send|stat|spamkill)\n\n";
     exit;
}

if ($ARGV[1] !~ /^(kill|besize|send|stat|spamkill)$/)
{
     print "\n   Error: Action must be matched with (kill|besize|send|stat|spamkill)\n\n";
     exit;
}

$workdir = "/root/mico/mailq_statistics";
#$mqdir = "/var/spool/mqueue/";
$mqdir = "/os_backup/mqueue";
$mqfile = "$workdir/mailq_statistics.list";
$killfile = "$workdir/kill_statistics.list";
$sendfile = "$workdir/send_statistics.list";

$next = 0;
$match_count = 0;

#------- open mail-statistics.list-----------

open (IN,"mailq |")||die "can't open program:mailq\n";
open MAILQ, ">$mqfile" or warn "Can't create $mqfile:$!\n";
open KILLQ, ">$killfile" or warn "Can't create $killfile:$!\n";
open SENDQ, ">$sendfile" or warn "Can't create $sendfile:$!\n";

#------- This is RE to match the fields------
$spam_re = '(MAILER|unknown|specified|refused|reject|Wrong|out|Waitting|look|host not found)';

$qid_re = '^([A-Z]{3}\d+)[*-]?\s+';

$size_re = '^[A-Z]{3}\d+[*-]?\s+(-?\d+) ';

$qtime_re = '((Mon|Tue|Wed|Thu|Fri|Sat|Sun) (Feb|Jen|Mar|Apr|May|Jun|Jul|Aug|Sep
|Oct|Nov|Dec) +[0-9]+ [0-2][0-9]:[0-5][0-9]) ';

$sender_re = ':[0-5][0-9] (MAILER-DAEMON|<.*@.*>|<>)$';

$reason_re = '^\s+.*(\(.*\))$';

$recipient_re = '^\s+(<.*@.*>|<>)$';
#-------------------------------------------
$re = $ARGV[0];
$action = $ARGV[1];
print " RE \t\t= $re\n";
print " ACTION \t= $action\n";

while(<IN>)
{
    $each_line = $_;
    if(/^\s+Mail Queue \(([0-9]+) requests\)/) {
       $progress_count = $1;
       print " Total Evelops \t= $1\n";
       next;
    } elsif (/$qid_re\s+\(no control file\)/) {
       #unlink glob "$mqdir/*$1"; # <----   It's too slow cos of calling shell.
       unlink "$mqdir/xf$1";
       unlink "$mqdir/df$1";
       unlink "$mqdir/qf$1";
       next;
    }
    if(/$qid_re/) {
       if($next == 1) {
           $progress_count--;
           print "                ";
           print "\r progress \t= $progress_count";
           print MAILQ "##########################################\n";
           if ($reason eq '') {
              $reason = "(Waitting to send....)";
           }
           @evelop = ("qid=$qid", "size=$size", "qtime=$qtime", "sender=$sender", "reason=$reason", @recipients);
           @recipients = ();
           undef($qid);
           undef($size);
           undef($qtime);
           undef($sender);
           undef($reason);
           $next = 0;
           foreach (@evelop) {
               print MAILQ "$_\n";
           }
           $evelop_join = join ";", @evelop; 
       #-----------  kill mail queue if match RE--------------------
           if ($action eq 'kill') {
               if ($evelop_join =~ /$re/) {
                   $_ = $evelop[0];
                   s/qid=//;
                   $match_count++;
                   print KILLQ "$_\n";
                   unlink "$mqdir/qf$_";
                   unlink "$mqdir/df$_";
                   unlink "$mqdir/xf$_"; 
               } 
           } elsif ($action eq 'send') {
               if ($evelop_join =~ /$re/) {
                   $_ = $evelop[0];
                   s/qid=//;
                   print "I\'m trying to send:$_ \n";
                   $match_count++;
                   print SENDQ "$_\n";
                   system "/usr/lib/sendmail -v -qI$_ &";
               }
           } elsif ($action eq 'stat') {
           } elsif ($action eq 'spamkill') {
               if ($evelop_join =~ /$spam_re/) {
                   $_ = $evelop[0];
                   s/qid=//;
                   $match_count++;
                   print KILLQ "$_\n";
                   unlink "$mqdir/qf$_";
                   unlink "$mqdir/df$_";
                   unlink "$mqdir/xf$_"; 
               }
           } else {
               if ($evelop_join !~ /$re/) {
                   $_ = $evelop[0];
                   s/qid=//;
                   print KILLQ "$_\n";
                   unlink "$mqdir/qf$_";
                   unlink "$mqdir/df$_";
                   unlink "$mqdir/xf$_"; 
               } 
           }
       #-----------  Done ----------------------------------------
       }
       $qid = $1;
       $next = 1;
       ($size) = ($each_line =~ /$size_re/); 
       ($qtime) = ($each_line =~ /$qtime_re/);
       ($sender) = ($each_line =~ /$sender_re/);
    }
    if(/$reason_re/) {
            $reason = $1;
    }
    if(/$recipient_re/) {
       push (@recipients, "recipients=$1");
    }
}

print "\n Match \t\t= $match_count\n";
close IN;
close MAILQ;
close KILLQ;
close SENDQ;
