
漂亮的格式： `.fmt` 方法

它是sprinf 的小兄弟，作为变量的方法使用。如果那是一个键值对儿或列表，它当然使用跟 sprinf 同样的语法和方式将几个值格式化。

```perl
$result = '5.123456789';
say $result .fmt ('%.2f');  # "5.12\n"
@nr = 1..5;
say @nr.fmt("+%d.");        # " +1. +2.+3.+4.+5.\n"
say @nr.fmt("%d.",',');     # "1.,2.,3.,4.,5.\n"
say @nr.fmt("%d %d");       # ERROR
```
`.fmt` 还有第二个参数，用于指定分隔符：

```perl
%p6c = sorear => 'niecza', fglock => 'perlito';
say %p6c.fmt("%s!");      # "sorear!\nfglock!\n"
say %p6c.fmt("%s", ',' ); # "sorear , fglock!\n"
say %p6c.fmt("%s:%s");    # "sorear:niecza\nfglock:perlito\n"
say %p6c.fmt("%s:%s",);   # "sorear:niecza,fglock:perlito\n"
say %p6c.fmt("%s %s %s"); # ERROR
```
