### 日期格式化

使用 "2007-11-10" 和 " Sunday, November 10, 2007" 日期格式显式当前日期

```perl
use DateTime::Utils;
 
my $dt = DateTime.now;
 
say strftime('%Y-%m-%d', $dt);
say strftime('%A, %B %d, %Y', $dt);
```
