#!/usr/bin/perl

  use strict;
  use Time::Local;
  use DBI;
  use POSIX qw(strftime);



    #print $d;
    #open (DATE,"date +%Y-%m-%d|");
    #while (<DATE>)
    #  {
    #    chomp;
    #    $dat=$_;
    #  };
    #close(DATE);
    #open (CILDATA,">>/var/db/ats/ats.".$dat);
    #print CILDATA $d;
    #close (CILDATA);

#--------------#

  my ($matched,$hour,$min,$date_time,$time,$value1,$internal,$line,$called_phone,$call_phone,$value2,$str,$logfile,%lines,%int_phones,$sth,$dbh,$key,$value);
  my $year = (localtime())[5]+1900;
  my $mon =1+(localtime())[4];
  if ($mon<10) {$mon="0".$mon;}
  my $day = (localtime())[3]-1;
  if ($day<10) {$day="0".$day;}
  my $yesterday_date = join('-',$year,$mon,$day);
#print "$yesterday_date\n";
#  if ($ARGV[0]) {$logfile=$ARGV[0];} else {$logfile="/var/db/ats/ats.$yesterday_date";}
#print "$logfile\n";
 open (PBX,"/dev/ttyS0");
 while (<PBX>)
   {
    $str=$_;
  my $dsn = "dbi:mysql:dbname=ats;host=192.168.1.2;port=3306";
  my $user = "ats";
  my $password = "atspassword";
  $dbh = DBI->connect($dsn,$user,$password,{ RaiseError => 1, AutoCommit => 0 });
  eval {
#    $myquery='INSERT INTO ats_stats(date_time,time,value1,internal_call,line,answer_phone,call_phone,value2) VALUES (?,?,?,?,?,?,?,?)';
    $sth=$dbh->prepare("INSERT INTO ats_stats(date_time,time,value1,internal_call,line,answer_phone,call_phone,value2) VALUES (?,?,?,?,?,?,?,?)") or die $dbh->errstr;

#    open (RAWDATA,"<".$logfile) || die print "$!\n";
#    while (<RAWDATA>) {
      my $internal_call=0;
      #chomp;
      #$str=$d_;
#print length($str);
      #if ( (length($str)==85) ) {
        $year=$year = (localtime())[5]+1900;
        $mon=substr($str,3,2)-1;
        $day=substr($str,5,2);
        $hour=substr($str,7,2);
        $min=substr($str,9,2);
        $time=substr($str,12,4);
        if ($time=~/\s+/) {
	  $time=0;
	}
        $value1=substr($str,17,4);
        $internal=substr($str,22,1);
        if ($internal=~/\s+/) {
          $internal=0;
        } else {
          $internal=1;
        }
        $line=substr($str,24,4);
        if ($line=~/^\s+/) {
	  $line=0;
	}
        $line=~s/\s+//g;
        $called_phone=substr($str,35,20);
        $call_phone=substr($str,56,4);
        $value2=substr($str,83,2);
      if ($called_phone=~/^\s+/) {
        $called_phone=0;
      }
      $called_phone=~s/(\s+)|(\#)|(\*)//g;
      if ($call_phone=~/^\s+/) {
        $call_phone=0;
      }
      $call_phone=~s/\s+//g;
      $date_time=timelocal('00',$min,$hour,$day,$mon,$year);
      $date_time=strftime("%Y-%m-%d %H:%M:%S", gmtime($date_time));
      $sth->execute($date_time,$time,$value1,$internal,$line,$called_phone,$call_phone,$value2) or die $dbh->errstr;
     
# &collect_lines($line) if ($line!=0);
# &collect_phones($call_phone) if ($call_phone!=0);

     # } else {
     #   print "e:$str\n";
     # }


#    }
  #close (RAWDATA);
#&add_misc();
  $dbh->commit;

  };

  if ($@) {
    warn "Transaction aborted because $@";
    $dbh->rollback;
  }
  $dbh->disconnect;

  sub collect_lines
  {
    $lines{$_[0]}++;
  }
  sub collect_phones
  {
    $int_phones{$_[0]}++;
  }

  sub add_misc
  {
    $sth=$dbh->prepare("INSERT INTO lines(line) VALUES (?);");
    while (($key,$value) = each(%lines)) {
      $sth->execute($key);
    }
  $sth=$dbh->prepare("INSERT INTO internal_phones(call_phone) VALUES (?);");
  while (($key,$value) = each(%int_phones)) {
    $sth->execute($key);
  }
}
};
close (PBX);
