# ericsson-bp250-stat
This is a very old (since 2005) Perl script to get statistics from the Ericsson BusinessPhone 250 console port.
It was based on some other script from the Internet (I can't find the original now).

This script puts all the data into a mysql database.
Unfortunately, I don't have SQL files to create tables.
But I think if it is useful, you will be able to create tables yourself

## Reports

### Total minutes in day
 SELECT SUM( TIME ) FROM ats_stats WHERE FROM_UNIXTIME( date_time ) LIKE '%2008-01-18%';

### Total minutes for internal cals in day
 SELECT SUM( TIME ) FROM ats_stats WHERE FROM_UNIXTIME( date_time ) LIKE '%2008-01-18%' AND line = '0';

### Total minutes for route
 SELECT sum(time) FROM ats_stats WHERE from_unixtime(date_time) LIKE '%2008-01-18%' AND line>'731' AND line<'737';

### Statistic for route
 SELECT * FROM ats_stats WHERE from_unixtime(date_time) LIKE '%2008-01-18%' AND line>'731' AND line<'737';

### Total minutes for answer number
 SELECT SUM( TIME ) FROM ats_stats WHERE FROM_UNIXTIME( date_time ) LIKE '%2008-01-18%' AND answer_phone = '5140491';

### Statistic for answer number
 SELECT * FROM ats_stats WHERE FROM_UNIXTIME( date_time ) LIKE '%2008-01-18%' AND answer_phone = '5140491';

### Top 10 by duration
 SELECT call_phone, sum(time)
 FROM `ats_stats`
 WHERE from_unixtime(date_time) LIKE '%2008-05-14%' AND (line>629 AND line<732) OR line=737
 GROUP BY call_phone
 ORDER BY sum(time) desc limit 0,10;

### A list of numbers with a connected route
 SELECT distinct `call_phone` FROM `ats_stats` WHERE FROM_UNIXTIME(`date_time`) LIKE '%2008-0%' \
 AND line>"700" AND line<"730" AND line>"0" AND answer_phone<>"5140491" ORDER BY `call_phone`;

### Sample list of call phones
 SELECT answer_phone, sum(time)
 FROM `ats_stats`
 WHERE from_unixtime( date_time ) like '%2008-05-14%' AND (line>629 AND line<732) OR line =737 and call_phone=181
 GROUP BY answer_phone ORDER BY sum( time ) desc;

## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details
