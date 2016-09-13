
[原文](http://theperlfisher.blogspot.jp/2016/02/from-regular-expressions-to-grammars-pt.html)

略去啰嗦的前半部分。

## Into the Breach

假设我们 的日志文件中有一个时间戳 **2016-02-06T14:36+02:00**, 我们使用智能匹配:

``` perl6
say $logfile ~~ /2016-02-06T14:36+02:00/;
```

这会报错:

> Unrecognized regex metacharacter - (must be quoted to match literally)

在 Perl 6 的正则表达式中任何非**字母数字字符**('a'..'z', 'A'..'Z', 0..9)都必须用引号引起来:

``` perl6
say $logfile ~~ /2016 '-' 02 '-' 06T14 ':' 36 '+' 02 ':' 00/;
```

现在我们得到等价的奇怪的表达式:

```
｢2016-01-29T13:25+01:00｣
```

这仅仅告诉我们, `~~`智能匹配操作符匹配了一些文本, 这就是它匹配到的文本。**｢｣** 是日语引文标记, 故意和剩余的文本区分开来。

在 Perl 6 中, 默认打印出带有明确标记的匹配对象, 它准确地告诉你匹配从哪里开始, 到哪里结束。

## 归纳

我们想让该正则表达式更具普遍性, 例如匹配 2016 年的日志:

``` perl6
say $logfile ~~ /2015 | 2016 '-' 02 '-' 06T14 ':' 36 '+' 02 ':' 00/;
```

但是这还会匹配到我们不想要的东西, 例如  '/post/2015/02' 或者甚至 '/number/120153'。因为 `|`的优先级没有字符间的连接优先级高。所以:

``` perl6
say $logfile ~~ / [2015 | 2016] '-' 02 '-' 06T14 ':' 36 '+' 02 ':' 00/;
```

问题解决, 但是我们想匹配 '[ 1997 | 1998 | 1999 | 2000... 2015 ]' 这些呢？

### Learning Shorthnd

匹配4位数字的年份好了:

``` perl6
say $logfile ~~ / \d\d\d\d '-' 02 '-' 06T14.../;
```

其它需要数字的地方也可以使用 `\d` 这种便捷形式的数字:

``` perl6
say $logfile ~~ / \d\d\d\d '-' \d\d - \d\d T \d\d ':' \d\d '+' \d\d ':' \d\d/;
```

'+' <digits> : <digits> 只会匹配 +01 和 +12 之间的时区, 还有其它在 -11 到 -01 之间的时区, 所以我们使用 `|` 来匹配 '+' 或 '-', 像这样:

``` perl6
say $logfile ~~ / \d\d\d\d '-' \d\d - \d\d T \d\d ':' \d\d [ '+' | '-' ] \d\d ':' \d\d/;
```

基本正确了, 但是由于历史原因, 时区还能是一个字母 `Z`, 所以, 还有一处要修改:

``` perl6
say $logfile ~~ / \d\d\d\d '-' \d\d - \d\d T \d\d ':' \d\d [ [ '+' | '-' ] \d\d ':' \d\d | Z ] /;
```

## 重构

但是那个 **[ '+' ... Z ]** 表达式太长了, 能重构就更好了。 **regex** 对象来拯救我们了, 它帮助我们清理代码。



**regex** 对象看起来很像匹配表达式, 除了它使用花括号来告诉从哪开始, 到哪结束:

``` perl6
my regex Timezone { Z | ['+' | '-'] \d\d ':' \d\d };
say $logfile ~~ / \d\d\d\d '-' \d\d '-' \d\d T \d\d ':' \d\d <Timezone> /;
```

`<..>` 从外表上看把重构后的表达式和主文本分开了, 而让 Timezone 表达式分离意味着我们能在代码中的任何地方使用它了。事实上我们可以重构其它的正则:

``` perl6
my regex Date { \d\d\d\d '-' \d\d '-' \d\d };
my regex Time { \d\d ':' \d\d              };
my regex Timezone { Z | [ '+' | '-' ] \d\d ':' \d\d };

say $logfile ~~ / <Date> T <Time> <Timezone> /;
```

让所有这些 `\d\d` 坐在一块儿有些碍眼, 所以我们再重构下:

``` perl6
my regex Integer { \d+ };

my regex Date     { <Integer> '-' <Integer> '-' <Integer>     };
my regex Time     { <Integer> ':' <Integer>                   };
my regex Timezone { Z | [ '+' | '-' ] <Integer> ':' <Integer> };

say $logfile ~~ / <Date> T <Time> <Timezone> /;
```

下面的也没啥值得看的。(完)
