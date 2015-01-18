2010 年 Perl6 圣诞月历(十六) Perl6 里的时间

今天是圣诞月历的第 0x10 天，是时候学习一下 perl6 里的时间了。 S32::Temporal 简介在过去一年中有了大量的修改，今天我们就来介绍一下在 perl6 实现中关于时间的一些基础知识。

time和now

time 和 now 是两个可以返回当前时间（至少是你的系统认为的当前时间）的词。简单的展示一下：

> say time; say now;
1292460064
Instant:2010-12-16T00:41:4.873248Z

第一个明显的区别，前者返回的是 POSIX 格式的数值型的结果；而后者返回的是一个瞬间的对象。如果你想获取秒级以下小数点位或者说闰秒，请用 now ；如果不用，那用 time 获取 POSIX 格式就够了。随你的便。

DateTime和他的伙伴

大多数时候，你要的不是当前时间。这种时候，你需要的是 DateTime 。比如还是获取当前时间：
my $moment = DateTime.new(now); # 或者DateTime.new(time)

你有两种方式来创建 DateTime 对象：
my $dw = DateTime.new(:year(1963), :month(11), :day(23), :hour(17), :minute(15));

这是 UTC 时区，如果你要更改时区的话，再加上 :timezone 就好了。这个格式里，只有 :year 是必须的，其他的默认就是1月1号半夜0点0分。

上面这种写法确实乏味，你可以采用 ISO8601 格式的输入，来创建一个 DateTime 对象：
my $dw = DateTime.new("1963-11-23T17:15:00Z");

其中 Z 表示 UTC ，想改变的话，把 Z 替换成 +hhmm 或者 -hhmm 就好了。hh 表示小时，mm 表示分钟。

此外，还有一个更简略的 Date 对象。只包括年月日的：
my $jfk = Date.new("1963-11-22"); # 你也可以用:year 等的写法

引入 Date 对象，是吸取了 CPAN 上 DateTime 模块的教训：有时候你压根不关心什么时区啊闰秒啊的。 Date 对象非常容易处理，比如它有内置的 .succ 和 .pred 方法，用来简单的递增和递减。
$jfk++; # 肯尼迪遇刺后的第二天

最后…

以上就是关于 Perl6 里的时间的内容了，想了解更多细节，去看看 规范 吧；或者去社区里提问

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2010/%E7%AC%AC%E5%8D%81%E5%85%AD%E5%A4%A9:Perl6%E9%87%8C%E7%9A%84%E6%97%B6%E9%97%B4.markdown >  